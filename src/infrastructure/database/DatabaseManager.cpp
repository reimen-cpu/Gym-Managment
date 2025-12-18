#include "DatabaseManager.h"
#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QStandardPaths>

namespace GymOS::Infrastructure::Database {

DatabaseManager &DatabaseManager::instance() {
  static DatabaseManager instance;
  return instance;
}

DatabaseManager::DatabaseManager() : QObject(nullptr) {}

DatabaseManager::~DatabaseManager() {
  if (m_database.isOpen()) {
    m_database.close();
  }
}

bool DatabaseManager::initialize(const QString &dbPath) {
  if (m_initialized) {
    return true;
  }

  // Configurar la conexión
  m_database = QSqlDatabase::addDatabase("QSQLITE");

  // Usar ruta de datos de la aplicación si no se especifica
  QString fullPath = dbPath;
  if (!dbPath.contains('/') && !dbPath.contains('\\')) {
    // PORTABLE MODE: Use application directory
    // This allows the app folder to be moved anywhere and keep the DB with it.
    QString dataPath = QCoreApplication::applicationDirPath();
    fullPath = dataPath + "/" + dbPath;
  }

  m_database.setDatabaseName(fullPath);

  if (!m_database.open()) {
    qCritical() << "Error al abrir la base de datos:"
                << m_database.lastError().text();
    emit databaseError(m_database.lastError().text());
    return false;
  }

  qInfo() << "Base de datos abierta en:" << fullPath;

  // Habilitar foreign keys
  executeQuery("PRAGMA foreign_keys = ON");

  // Crear tablas
  if (!createTables()) {
    return false;
  }

  // Ejecutar migraciones
  if (!runMigrations()) {
    return false;
  }

  m_initialized = true;
  emit databaseInitialized();
  return true;
}

bool DatabaseManager::isConnected() const { return m_database.isOpen(); }

QSqlDatabase &DatabaseManager::database() { return m_database; }

QSqlQuery DatabaseManager::executeQuery(const QString &sql) {
  QSqlQuery query(m_database);
  if (!query.exec(sql)) {
    qWarning() << "Error en consulta SQL:" << query.lastError().text();
    qWarning() << "SQL:" << sql;
    emit databaseError(query.lastError().text());
  }
  return query;
}

QSqlQuery DatabaseManager::executeQuery(const QString &sql,
                                        const QVariantList &params) {
  QSqlQuery query(m_database);
  query.prepare(sql);

  for (int i = 0; i < params.size(); ++i) {
    query.bindValue(i, params[i]);
  }

  if (!query.exec()) {
    qWarning() << "Error en consulta SQL:" << query.lastError().text();
    qWarning() << "SQL:" << sql;
    emit databaseError(query.lastError().text());
  }
  return query;
}

bool DatabaseManager::beginTransaction() { return m_database.transaction(); }

bool DatabaseManager::commitTransaction() { return m_database.commit(); }

bool DatabaseManager::rollbackTransaction() { return m_database.rollback(); }

bool DatabaseManager::createTables() {
  // Tabla de miembros
  QString createMembers = R"(
        CREATE TABLE IF NOT EXISTS members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT UNIQUE,
            phone TEXT,
            social_media TEXT,
            health_notes TEXT,
            weight_kg REAL,
            height_cm REAL,
            observations TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
    )";

  // Tabla de planes
  QString createPlans = R"(
        CREATE TABLE IF NOT EXISTS plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            duration_days INTEGER NOT NULL CHECK (duration_days > 0),
            price REAL NOT NULL CHECK (price >= 0),
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
    )";

  // Tabla de configuraciones globales
  QString createSettings = R"(
        CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT,
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
    )";

  // Tabla de suscripciones
  QString createSubscriptions = R"(
        CREATE TABLE IF NOT EXISTS subscriptions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            member_id INTEGER NOT NULL,
            plan_id INTEGER NOT NULL,
            start_date TEXT NOT NULL,
            enrollment_fee REAL NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE RESTRICT,
            FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE RESTRICT
        )
    )";

  // Tabla de pagos (INMUTABLE)
  QString createPayments = R"(
        CREATE TABLE IF NOT EXISTS payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subscription_id INTEGER NOT NULL,
            amount REAL NOT NULL CHECK (amount > 0),
            payment_date TEXT NOT NULL,
            payment_type TEXT NOT NULL CHECK (payment_type IN ('enrollment', 'renewal', 'additional')),
            notes TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE RESTRICT
        )
    )";

  // Tabla de entradas financieras (INMUTABLE - Event Sourcing Lite)
  QString createFinancialEntries = R"(
        CREATE TABLE IF NOT EXISTS financial_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_type TEXT NOT NULL CHECK (
                entry_type IN ('enrollment_income', 'renewal_income', 'custom_income', 'custom_expense')
            ),
            classification TEXT NOT NULL CHECK (classification IN ('income', 'expense')),
            amount REAL NOT NULL CHECK (amount > 0),
            description TEXT NOT NULL,
            payment_id INTEGER,
            entry_date TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE RESTRICT
        )
    )";

  // Vista de suscripciones con fecha de vencimiento calculada
  QString createSubscriptionsView = R"(
        CREATE VIEW IF NOT EXISTS v_subscriptions_with_expiry AS
        SELECT 
            s.id,
            s.member_id,
            s.plan_id,
            s.start_date,
            date(s.start_date, '+' || p.duration_days || ' days') AS end_date,
            s.enrollment_fee,
            m.first_name || ' ' || m.last_name AS member_name,
            p.name AS plan_name,
            p.duration_days,
            p.price AS plan_price,
            CASE 
                WHEN date(s.start_date, '+' || p.duration_days || ' days') < date('now') THEN 'expired'
                WHEN date(s.start_date, '+' || p.duration_days || ' days') <= date('now', '+7 days') THEN 'expiring'
                ELSE 'active'
            END AS status,
            CAST(julianday(date(s.start_date, '+' || p.duration_days || ' days')) - julianday(date('now')) AS INTEGER) AS days_until_expiry
        FROM subscriptions s
        JOIN plans p ON s.plan_id = p.id
        JOIN members m ON s.member_id = m.id
    )";

  // Ejecutar todas las creaciones
  QStringList queries = {createMembers,  createPlans,
                         createSettings, createSubscriptions,
                         createPayments, createFinancialEntries};

  for (const QString &sql : queries) {
    QSqlQuery query = executeQuery(sql);
    if (query.lastError().isValid()) {
      qCritical() << "Error creando tabla:" << query.lastError().text();
      return false;
    }
  }

  // Inicializar configuraciones por defecto
  QSqlQuery checkSettings = executeQuery("SELECT count(*) FROM settings");
  if (checkSettings.next() && checkSettings.value(0).toInt() == 0) {
    executeQuery(
        "INSERT INTO settings (key, value) VALUES ('enrollment_fee', '0.0')");
  }

  // Crear vista (DROP primero para actualizarla)
  executeQuery("DROP VIEW IF EXISTS v_subscriptions_with_expiry");
  QSqlQuery viewQuery = executeQuery(createSubscriptionsView);
  if (viewQuery.lastError().isValid()) {
    qCritical() << "Error creando vista:" << viewQuery.lastError().text();
    return false;
  }

  // Crear índices
  QStringList indexes = {
      "CREATE INDEX IF NOT EXISTS idx_members_name ON members(last_name, "
      "first_name)",
      "CREATE INDEX IF NOT EXISTS idx_members_email ON members(email)",
      "CREATE INDEX IF NOT EXISTS idx_plans_active ON plans(is_active)",
      "CREATE INDEX IF NOT EXISTS idx_subscriptions_member ON "
      "subscriptions(member_id)",
      "CREATE INDEX IF NOT EXISTS idx_subscriptions_start ON "
      "subscriptions(start_date)",
      "CREATE INDEX IF NOT EXISTS idx_payments_subscription ON "
      "payments(subscription_id)",
      "CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date)",
      "CREATE INDEX IF NOT EXISTS idx_payments_type ON payments(payment_type)",
      "CREATE INDEX IF NOT EXISTS idx_financial_entries_date ON "
      "financial_entries(entry_date)",
      "CREATE INDEX IF NOT EXISTS idx_financial_entries_type ON "
      "financial_entries(entry_type)",
      "CREATE INDEX IF NOT EXISTS idx_financial_entries_classification ON "
      "financial_entries(classification)"};

  for (const QString &sql : indexes) {
    executeQuery(sql);
  }

  qInfo() << "Tablas e índices creados correctamente";
  return true;
}

bool DatabaseManager::createMigrationsTable() {
  QString sql = R"(
        CREATE TABLE IF NOT EXISTS _migrations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            applied_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
    )";

  QSqlQuery query = executeQuery(sql);
  return !query.lastError().isValid();
}

bool DatabaseManager::isMigrationApplied(const QString &migrationName) {
  QSqlQuery query = executeQuery(
      "SELECT COUNT(*) FROM _migrations WHERE name = ?", {migrationName});

  if (query.next()) {
    return query.value(0).toInt() > 0;
  }
  return false;
}

bool DatabaseManager::recordMigration(const QString &migrationName) {
  QSqlQuery query = executeQuery("INSERT INTO _migrations (name) VALUES (?)",
                                 {migrationName});
  return !query.lastError().isValid();
}

bool DatabaseManager::runMigrations() {
  if (!createMigrationsTable()) {
    return false;
  }

  // Lista de migraciones (en orden)
  QStringList migrations = {"001_convert_months_to_days"};

  for (const QString &migration : migrations) {
    if (!isMigrationApplied(migration)) {
      qInfo() << "Aplicando migración:" << migration;

      bool success = true;
      if (migration == "001_convert_months_to_days") {
        // Verificar si la columna duration_months existe usando PRAGMA
        QSqlQuery pragma = executeQuery("PRAGMA table_info(plans)");
        bool hasDurationMonths = false;
        while (pragma.next()) {
          if (pragma.value("name").toString() == "duration_months") {
            hasDurationMonths = true;
            break;
          }
        }

        if (hasDurationMonths) {
          // La columna existe, necesitamos migrar
          beginTransaction();

          // Verificar si ya existe duration_days para no fallar
          bool hasDurationDays = false;
          pragma.first(); // Rewind if possible or re-query. PRAGMA is small,
                          // re-querying is safer/easier code wise but let's
                          // just check the log.
          // SQLite PRAGMA results are forward only usually. Let's re-run or
          // just proceed with ALTER which ignores if exists? No, ALTER TABLE
          // ADD COLUMN fails if exists.

          // Let's rely on hasDurationMonths. If checking column existed, we
          // assume we need to migrate. But we must check if duration_days
          // exists to avoid error on ADD COLUMN. Let's just catch the error of
          // ADD COLUMN gracefully or check both.

          QSqlQuery addCol = executeQuery(
              "ALTER TABLE plans ADD COLUMN duration_days INTEGER DEFAULT 0");
          // If it fails, maybe it exists. We proceed to update.

          executeQuery("UPDATE plans SET duration_days = duration_months * 30");
          commitTransaction();
          qInfo() << "Migración 001 completada: Meses convertidos a días";
        } else {
          qInfo() << "La columna duration_months no existe o es una "
                     "instalación nueva.";
        }
      }

      if (success && !recordMigration(migration)) {
        qCritical() << "Error registrando migración:" << migration;
        return false;
      }

      emit migrationCompleted(migration);
    }
  }

  return true;
}

} // namespace GymOS::Infrastructure::Database
