#pragma once

#include <QDate>
#include <QDateTime>
#include <QString>
#include <optional>


namespace GymOS::Core::Models {

/**
 * @brief Tipo de entrada financiera
 */
enum class EntryType {
  EnrollmentIncome, ///< Ingreso por inscripción
  RenewalIncome,    ///< Ingreso por renovación
  CustomIncome,     ///< Ingreso personalizado
  CustomExpense     ///< Gasto personalizado
};

/**
 * @brief Clasificación de la entrada (ingreso o gasto)
 */
enum class Classification {
  Income, ///< Ingreso
  Expense ///< Gasto
};

/**
 * @brief Entrada financiera (INMUTABLE - Event Sourcing Lite)
 *
 * Inspirado en el modelo Entry de Maybe Finance.
 * Todas las entradas financieras son inmutables y representan
 * eventos que ya ocurrieron. Los balances y totales se calculan
 * dinámicamente mediante agregación.
 */
struct FinancialEntry {
  int64_t id = 0;
  EntryType entryType;
  Classification classification;
  double amount; ///< Siempre positivo
  QString description;
  std::optional<int64_t> paymentId; ///< Enlace a payments (opcional)
  QDate entryDate;
  QDateTime createdAt;

  /**
   * @brief Obtiene el monto con signo según la clasificación
   */
  [[nodiscard]] double signedAmount() const {
    return classification == Classification::Income ? amount : -amount;
  }

  /**
   * @brief Verifica si es un ingreso
   */
  [[nodiscard]] bool isIncome() const {
    return classification == Classification::Income;
  }

  /**
   * @brief Verifica si es un gasto
   */
  [[nodiscard]] bool isExpense() const {
    return classification == Classification::Expense;
  }

  /**
   * @brief Obtiene el texto del tipo de entrada en español
   */
  [[nodiscard]] QString entryTypeText() const {
    switch (entryType) {
    case EntryType::EnrollmentIncome:
      return "Inscripción";
    case EntryType::RenewalIncome:
      return "Renovación";
    case EntryType::CustomIncome:
      return "Ingreso";
    case EntryType::CustomExpense:
      return "Gasto";
    }
    return "Movimiento";
  }

  /**
   * @brief Obtiene el identificador del tipo para la base de datos
   */
  [[nodiscard]] QString entryTypeId() const {
    switch (entryType) {
    case EntryType::EnrollmentIncome:
      return "enrollment_income";
    case EntryType::RenewalIncome:
      return "renewal_income";
    case EntryType::CustomIncome:
      return "custom_income";
    case EntryType::CustomExpense:
      return "custom_expense";
    }
    return "unknown";
  }

  /**
   * @brief Obtiene el identificador de clasificación para la base de datos
   */
  [[nodiscard]] QString classificationId() const {
    return classification == Classification::Income ? "income" : "expense";
  }

  /**
   * @brief Convierte un string a EntryType
   */
  static EntryType entryTypeFromString(const QString &str) {
    if (str == "enrollment_income")
      return EntryType::EnrollmentIncome;
    if (str == "renewal_income")
      return EntryType::RenewalIncome;
    if (str == "custom_income")
      return EntryType::CustomIncome;
    return EntryType::CustomExpense;
  }

  /**
   * @brief Convierte un string a Classification
   */
  static Classification classificationFromString(const QString &str) {
    return str == "income" ? Classification::Income : Classification::Expense;
  }

  /**
   * @brief Formatea el monto con símbolo y signo
   */
  [[nodiscard]] QString formattedAmount() const {
    QString sign = isIncome() ? "+" : "-";
    return sign + "$" + QString::number(amount, 'f', 2);
  }
};

/**
 * @brief Resumen financiero (calculado dinámicamente)
 *
 * Este struct representa agregaciones calculadas, nunca valores almacenados.
 */
struct FinancialSummary {
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  int transactionCount = 0;

  /**
   * @brief Calcula el balance (ingresos - gastos)
   */
  [[nodiscard]] double balance() const { return totalIncome - totalExpenses; }

  /**
   * @brief Verifica si el balance es positivo
   */
  [[nodiscard]] bool isPositive() const { return balance() >= 0; }

  /**
   * @brief Formatea el balance con símbolo y signo
   */
  [[nodiscard]] QString formattedBalance() const {
    double bal = balance();
    QString sign = bal >= 0 ? "+" : "";
    return sign + "$" + QString::number(bal, 'f', 2);
  }
};

/**
 * @brief Desglose mensual para gráficos
 */
struct MonthlyBreakdown {
  int year;
  int month;
  double income;
  double expenses;

  /**
   * @brief Obtiene el nombre del mes en español
   */
  [[nodiscard]] QString monthName() const {
    static const QStringList months = {"Ene", "Feb", "Mar", "Abr",
                                       "May", "Jun", "Jul", "Ago",
                                       "Sep", "Oct", "Nov", "Dic"};
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return "???";
  }

  /**
   * @brief Calcula el balance del mes
   */
  [[nodiscard]] double balance() const { return income - expenses; }
};

} // namespace GymOS::Core::Models
