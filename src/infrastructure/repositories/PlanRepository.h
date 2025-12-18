#pragma once

#include "../../core/models/Plan.h"
#include "../database/DatabaseManager.h"
#include <QSqlQuery>
#include <optional>
#include <vector>


namespace GymOS::Infrastructure::Repositories {

using namespace GymOS::Core::Models;
using namespace GymOS::Infrastructure::Database;

/**
 * @brief Repositorio de Planes
 */
class PlanRepository {
public:
  PlanRepository();

  [[nodiscard]] int64_t insert(const Plan &plan);
  void update(const Plan &plan);
  bool remove(int64_t id);

  [[nodiscard]] std::optional<Plan> findById(int64_t id) const;
  [[nodiscard]] std::vector<Plan> findAll() const;
  [[nodiscard]] std::vector<Plan> findActive() const;
  [[nodiscard]] int count() const;

  /**
   * @brief Activa o desactiva un plan
   */
  void setActive(int64_t id, bool active);

private:
  [[nodiscard]] Plan mapRow(QSqlQuery &query) const;
  DatabaseManager &m_db;
};

} // namespace GymOS::Infrastructure::Repositories
