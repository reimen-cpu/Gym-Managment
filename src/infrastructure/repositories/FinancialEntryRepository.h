#pragma once

#include "../../core/models/FinancialEntry.h"
#include "../database/DatabaseManager.h"
#include <QDate>
#include <QSqlQuery>
#include <optional>
#include <vector>


namespace GymOS::Infrastructure::Repositories {

using namespace GymOS::Core::Models;
using namespace GymOS::Infrastructure::Database;

/**
 * @brief Repositorio de Entradas Financieras
 *
 * IMPORTANTE: Este repositorio NO tiene métodos de update o delete.
 * Las entradas financieras son inmutables (Event Sourcing Lite).
 */
class FinancialEntryRepository {
public:
  FinancialEntryRepository();

  /**
   * @brief Inserta una nueva entrada financiera (inmutable)
   */
  [[nodiscard]] int64_t insert(const FinancialEntry &entry);

  /**
   * @brief Obtiene todas las entradas en un rango de fechas
   */
  [[nodiscard]] std::vector<FinancialEntry>
  findByDateRange(const QDate &startDate, const QDate &endDate) const;

  /**
   * @brief Obtiene las últimas N entradas
   */
  [[nodiscard]] std::vector<FinancialEntry> findLatest(int limit = 10) const;

  /**
   * @brief Obtiene entradas por clasificación
   */
  [[nodiscard]] std::vector<FinancialEntry>
  findByClassification(Classification classification, const QDate &startDate,
                       const QDate &endDate) const;

  /**
   * @brief Calcula el resumen financiero (totales dinámicos)
   */
  [[nodiscard]] FinancialSummary getSummary(const QDate &startDate,
                                            const QDate &endDate) const;

  /**
   * @brief Calcula el resumen financiero total (sin filtro de fecha)
   */
  [[nodiscard]] FinancialSummary getTotalSummary() const;

  /**
   * @brief Obtiene el desglose mensual para gráficos
   */
  [[nodiscard]] std::vector<MonthlyBreakdown>
  getMonthlyBreakdown(const QDate &startDate, const QDate &endDate) const;

private:
  [[nodiscard]] FinancialEntry mapRow(QSqlQuery &query) const;
  DatabaseManager &m_db;
};

} // namespace GymOS::Infrastructure::Repositories
