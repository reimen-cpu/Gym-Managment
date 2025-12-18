#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QStringList>
#include <QDebug>
#include <memory>
#include <optional>

namespace GymOS::Infrastructure::Database {

/**
 * @brief Gestor de base de datos SQLite
 * 
 * Maneja la conexión, migraciones y operaciones de base de datos.
 * Implementa el patrón Singleton para una única conexión.
 */
class DatabaseManager : public QObject {
    Q_OBJECT
    
public:
    /**
     * @brief Obtiene la instancia única del gestor de base de datos
     */
    static DatabaseManager& instance();
    
    /**
     * @brief Inicializa la base de datos
     * @param dbPath Ruta al archivo de base de datos
     * @return true si la inicialización fue exitosa
     */
    bool initialize(const QString& dbPath = "gymos.db");
    
    /**
     * @brief Verifica si la base de datos está conectada
     */
    bool isConnected() const;
    
    /**
     * @brief Obtiene la conexión a la base de datos
     */
    QSqlDatabase& database();
    
    /**
     * @brief Ejecuta una consulta SQL
     * @param sql Consulta SQL
     * @return QSqlQuery con el resultado
     */
    QSqlQuery executeQuery(const QString& sql);
    
    /**
     * @brief Ejecuta una consulta SQL con parámetros
     * @param sql Consulta SQL con placeholders
     * @param params Lista de parámetros
     * @return QSqlQuery con el resultado
     */
    QSqlQuery executeQuery(const QString& sql, const QVariantList& params);
    
    /**
     * @brief Ejecuta las migraciones pendientes
     * @return true si todas las migraciones fueron exitosas
     */
    bool runMigrations();
    
    /**
     * @brief Inicia una transacción
     */
    bool beginTransaction();
    
    /**
     * @brief Confirma una transacción
     */
    bool commitTransaction();
    
    /**
     * @brief Revierte una transacción
     */
    bool rollbackTransaction();
    
signals:
    void databaseInitialized();
    void migrationCompleted(const QString& migrationName);
    void databaseError(const QString& error);
    
private:
    DatabaseManager();
    ~DatabaseManager();
    
    // Prevenir copia
    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;
    
    /**
     * @brief Crea las tablas de la base de datos
     */
    bool createTables();
    
    /**
     * @brief Crea la tabla de migraciones si no existe
     */
    bool createMigrationsTable();
    
    /**
     * @brief Verifica si una migración ya fue aplicada
     */
    bool isMigrationApplied(const QString& migrationName);
    
    /**
     * @brief Registra una migración como aplicada
     */
    bool recordMigration(const QString& migrationName);
    
    QSqlDatabase m_database;
    bool m_initialized = false;
};

} // namespace GymOS::Infrastructure::Database
