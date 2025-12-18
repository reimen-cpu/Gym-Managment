#pragma once

#include "../../infrastructure/repositories/FinancialEntryRepository.h"
#include "../models/FinancialEntry.h"
#include <QDate>
#include <QObject>
#include <vector>


namespace GymOS::Core::Services {

using namespace GymOS::Core::Models;
using namespace GymOS::Infrastructure::Repositories;

/**
 * @brief Motor Financiero
 *
 * Inspirado en Maybe Finance. Maneja el registro de movimientos
 * financieros y el cálculo dinámico de resúmenes.
 *
 * IMPORTANTE: Todas las entradas son inmutables (append-only).
 * Los balances y totales se calculan dinámicamente.
 */
class FinanceEngine : public QObject {
  Q_OBJECT

public:
  explicit FinanceEngine(QObject *parent = nullptr);

  // ========================================================================
  // Registro de Movimientos (append-only)
  // ========================================================================

  /**
   * @brief Registra un ingreso por inscripción
   */
  int64_t recordEnrollmentIncome(double amount, const QString &description,
                                 const QDate &date = QDate::currentDate());

  /**
   * @brief Registra un ingreso por renovación
   */
  int64_t recordRenewalIncome(double amount, const QString &description,
                              const QDate &date = QDate::currentDate());

  /**
   * @brief Registra un ingreso personalizado
   */
  int64_t recordCustomIncome(double amount, const QString &description,
                             const QDate &date = QDate::currentDate());

  /**
   * @brief Registra un gasto personalizado
   */
  int64_t recordCustomExpense(double amount, const QString &description,
                              const QDate &date = QDate::currentDate());

  // ========================================================================
  // Consultas y Cálculos Dinámicos
  // ========================================================================

  /**
   * @brief Obtiene el resumen financiero de un período
   */
  FinancialSummary getSummary(const QDate &startDate,
                              const QDate &endDate) const;

  /**
   * @brief Obtiene el resumen financiero total
   */
  FinancialSummary getTotalSummary() const;

  /**
   * @brief Obtiene el resumen del mes actual
   */
  FinancialSummary getCurrentMonthSummary() const;

  /**
   * @brief Obtiene el resumen del año actual
   */
  FinancialSummary getCurrentYearSummary() const;

  /**
   * @brief Obtiene las últimas N transacciones
   */
  std::vector<FinancialEntry> getLatestTransactions(int limit = 10) const;

  /**
   * @brief Obtiene el desglose mensual para gráficos
   */
  std::vector<MonthlyBreakdown> getMonthlyBreakdown(int months = 6) const;

signals:
  void incomeRecorded(int64_t entryId, double amount);
  void expenseRecorded(int64_t entryId, double amount);

private:
  int64_t recordEntry(EntryType type, Classification classification,
                      double amount, const QString &description,
                      const QDate &date);

  FinancialEntryRepository m_repo;
};

} // namespace GymOS::Core::Services
