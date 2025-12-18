#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QIcon>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlError>
#include <QQuickStyle>
#include <QTextStream>
#include <iostream>

#include "core/services/FinanceEngine.h"
#include "core/services/SubscriptionManager.h"
#include "infrastructure/database/DatabaseManager.h"
#include "ui/controllers/DashboardController.h"
#include "ui/controllers/GymController.h"

using namespace GymOS::Infrastructure::Database;
using namespace GymOS::Core::Services;
using namespace GymOS::UI::Controllers;

// Global log file
QFile *g_logFile = nullptr;
QFile *g_runtimeLogFile = nullptr;

void writeLog(const QString &level, const QString &msg,
              bool isRuntime = false) {
  QString timestamp = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
  QString line = QString("%1 [%2] %3\n").arg(timestamp, level, msg);

  // Write to startup log
  if (g_logFile && g_logFile->isOpen()) {
    QTextStream out(g_logFile);
    out << line;
    out.flush();
  }

  // Write to runtime log if flagged or if it's not just startup info
  if (isRuntime && g_runtimeLogFile && g_runtimeLogFile->isOpen()) {
    QTextStream out(g_runtimeLogFile);
    out << line;
    out.flush();
  }

  // Also write to stderr for immediate feedback
  std::cerr << line.toStdString();
}

void logInfo(const QString &msg) { writeLog("INFO ", msg); }
void logError(const QString &msg) { writeLog("ERROR", msg, true); }
void logWarn(const QString &msg) { writeLog("WARN ", msg, true); }
void logDebug(const QString &msg) { writeLog("DEBUG", msg, true); }

// Custom message handler for Qt messages
void messageHandler(QtMsgType type, const QMessageLogContext &context,
                    const QString &msg) {
  QString formattedMsg = msg;

  // Add context info if available
  if (context.file && context.line > 0) {
    formattedMsg = QString("%1 (%2:%3)")
                       .arg(msg, context.file, QString::number(context.line));
  }

  switch (type) {
  case QtDebugMsg:
    // Filter out verbose Qt internal messages but keep QML and GymController
    // logs
    if (msg.contains("qml:") || msg.startsWith("[QML]") ||
        msg.startsWith("[GymController]")) {
      logDebug(formattedMsg);
    }
    break;
  case QtInfoMsg:
    logInfo(formattedMsg);
    break;
  case QtWarningMsg:
    logWarn(formattedMsg);
    break;
  case QtCriticalMsg:
  case QtFatalMsg:
    logError(formattedMsg);
    break;
  }
}

int main(int argc, char *argv[]) {
  // Create runtime-logs directory
  QDir dir;
  if (!dir.exists("runtime-logs")) {
    dir.mkpath("runtime-logs");
  }

  // Open startup log file
  g_logFile = new QFile("runtime-logs/startup.txt");
  g_logFile->open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text);

  // Open runtime log file (append mode to keep history)
  QString runtimeLogName =
      QString("runtime-logs/runtime_%1.txt")
          .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss"));
  g_runtimeLogFile = new QFile(runtimeLogName);
  g_runtimeLogFile->open(QIODevice::WriteOnly | QIODevice::Truncate |
                         QIODevice::Text);

  // Write header to runtime log
  if (g_runtimeLogFile->isOpen()) {
    QTextStream out(g_runtimeLogFile);
    out << "=============================================================\n";
    out << "  GYMOS RUNTIME LOG - " << QDateTime::currentDateTime().toString()
        << "\n";
    out << "=============================================================\n\n";
    out.flush();
  }

  // Install custom message handler
  qInstallMessageHandler(messageHandler);

  logInfo("==============================================");
  logInfo("           GYMOS APPLICATION START            ");
  logInfo("==============================================");

  QGuiApplication app(argc, argv);
  logInfo("QGuiApplication created");

  // Configuración de la aplicación
  app.setApplicationName("GymOS");
  app.setApplicationVersion("1.0.0");
  app.setOrganizationName("GymOS");
  app.setOrganizationDomain("gymos.local");
  logInfo("App configuration set");

  // Configurar locale español
  QLocale::setDefault(QLocale(QLocale::Spanish, QLocale::Argentina));
  logInfo("Locale set to Spanish Argentina");

  // Estilo de Qt Quick Controls
  QQuickStyle::setStyle("Basic");
  logInfo("Style set to Basic");

  // Inicializar base de datos
  logInfo("Initializing database...");
  auto &db = DatabaseManager::instance();
  if (!db.initialize("gymos.db")) {
    logError("FATAL: Failed to initialize database!");
    return -1;
  }
  logInfo("Database initialized successfully");
  logInfo(
      QString("Database connected: %1").arg(db.isConnected() ? "YES" : "NO"));

  // Crear el controlador principal (incluye todos los servicios)
  logInfo("Creating GymController...");
  GymController *gymController = new GymController(&app);
  logInfo("GymController created");

  // Insertar planes por defecto si la base de datos está vacía
  if (gymController->getPlans().isEmpty()) {
    logInfo("Database is empty, inserting default plans...");
    gymController->createPlan("Mensual", 1, 5000);
    gymController->createPlan("Trimestral", 3, 12000);
    gymController->createPlan("Semestral", 6, 20000);
    gymController->createPlan("Anual", 12, 35000);
    gymController->createPlan("Quincenal", 15, 3000); // 15 días
    logInfo("Default plans inserted");
  }

  // Motor QML
  logInfo("Creating QML engine...");
  QQmlApplicationEngine engine;
  logInfo("QML engine created");

  // Conexión para capturar errores de QML
  QObject::connect(&engine, &QQmlApplicationEngine::warnings,
                   [](const QList<QQmlError> &warnings) {
                     for (const auto &warning : warnings) {
                       logWarn(
                           QString("QML Warning: %1").arg(warning.toString()));
                     }
                   });
  logInfo("Warning handler connected");

  // Exponer el controlador a QML
  logInfo("Setting context properties...");
  QQmlContext *context = engine.rootContext();
  context->setContextProperty("gymController", gymController);
  logInfo("Context properties set");

  // Agregar ruta de importación para módulos QML
  engine.addImportPath("qrc:/");
  logInfo("Import path added: qrc:/");
  logInfo(
      QString("All import paths: %1").arg(engine.importPathList().join("; ")));

  // Test if QML file exists in resources
  logInfo("Checking if QML resource exists...");
  QFile qmlFile(":/qml/Main.qml");
  if (qmlFile.exists()) {
    logInfo("Main.qml found in resources");
  } else {
    logError("Main.qml NOT FOUND in resources!");
  }

  // Create component to check for errors before loading
  logInfo("Creating QQmlComponent to test Main.qml...");
  const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));

  QQmlComponent component(&engine, url);
  logInfo(QString("Component status: %1").arg(component.status()));

  if (component.isError()) {
    logError("QML Component has errors:");
    for (const QQmlError &error : component.errors()) {
      logError(QString("  - %1").arg(error.toString()));
    }
    g_logFile->close();
    g_runtimeLogFile->close();
    delete g_logFile;
    delete g_runtimeLogFile;
    return -1;
  }

  // Now load with engine
  logInfo("Loading QML with engine.load()...");

  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      [](const QUrl &objUrl) {
        logError(QString("FATAL: QML object creation failed for: %1")
                     .arg(objUrl.toString()));
        QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);

  engine.load(url);
  logInfo("engine.load() completed");

  // Verificar si se cargó correctamente
  logInfo(QString("Root objects count: %1").arg(engine.rootObjects().size()));

  if (engine.rootObjects().isEmpty()) {
    logError("FATAL: No root objects created!");
    g_logFile->close();
    g_runtimeLogFile->close();
    delete g_logFile;
    delete g_runtimeLogFile;
    return -1;
  }

  logInfo("==============================================");
  logInfo("    GYMOS QML LOADED - STARTING EVENT LOOP    ");
  logInfo("==============================================");

  // Log to runtime file that app is ready
  if (g_runtimeLogFile->isOpen()) {
    QTextStream out(g_runtimeLogFile);
    out << "\n>>> APPLICATION READY - Runtime logs start here <<<\n\n";
    out.flush();
  }

  int result = app.exec();

  logInfo("Application exited with code: " + QString::number(result));

  g_logFile->close();
  g_runtimeLogFile->close();
  delete g_logFile;
  delete g_runtimeLogFile;

  return result;
}
