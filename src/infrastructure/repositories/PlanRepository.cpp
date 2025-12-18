#include "PlanRepository.h"
#include <QDateTime>

namespace GymOS::Infrastructure::Repositories {

PlanRepository::PlanRepository() : m_db(DatabaseManager::instance()) {}

int64_t PlanRepository::insert(const Plan &plan) {
  QString sql = R"(
        INSERT INTO plans (name, duration_days, price, is_active)
        VALUES (?, ?, ?, ?)
    )";

  QSqlQuery query = m_db.executeQuery(
      sql, {plan.name, plan.durationDays, plan.price, plan.isActive ? 1 : 0});

  return query.lastInsertId().toLongLong();
}

void PlanRepository::update(const Plan &plan) {
  QString sql = R"(
        UPDATE plans SET
            name = ?,
            duration_days = ?,
            price = ?,
            is_active = ?,
            updated_at = datetime('now')
        WHERE id = ?
    )";

  m_db.executeQuery(sql, {plan.name, plan.durationDays, plan.price,
                          plan.isActive ? 1 : 0, plan.id});
}

bool PlanRepository::remove(int64_t id) {
  QString sql = "DELETE FROM plans WHERE id = ?";
  m_db.executeQuery(sql, {id});
  return true;
}

std::optional<Plan> PlanRepository::findById(int64_t id) const {
  QSqlQuery query = m_db.executeQuery("SELECT * FROM plans WHERE id = ?", {id});

  if (query.next()) {
    return mapRow(query);
  }
  return std::nullopt;
}

std::vector<Plan> PlanRepository::findAll() const {
  std::vector<Plan> plans;
  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM plans ORDER BY duration_days");

  while (query.next()) {
    plans.push_back(mapRow(query));
  }
  return plans;
}

std::vector<Plan> PlanRepository::findActive() const {
  std::vector<Plan> plans;
  QSqlQuery query = m_db.executeQuery(
      "SELECT * FROM plans WHERE is_active = 1 ORDER BY duration_days");

  while (query.next()) {
    plans.push_back(mapRow(query));
  }
  return plans;
}

int PlanRepository::count() const {
  QSqlQuery query = m_db.executeQuery("SELECT COUNT(*) FROM plans");
  if (query.next()) {
    return query.value(0).toInt();
  }
  return 0;
}

void PlanRepository::setActive(int64_t id, bool active) {
  QString sql = "UPDATE plans SET is_active = ?, updated_at = datetime('now') "
                "WHERE id = ?";
  m_db.executeQuery(sql, {active ? 1 : 0, id});
}

Plan PlanRepository::mapRow(QSqlQuery &query) const {
  Plan plan;
  plan.id = query.value("id").toLongLong();
  plan.name = query.value("name").toString();
  plan.durationDays = query.value("duration_days").toInt();
  plan.price = query.value("price").toDouble();
  plan.isActive = query.value("is_active").toBool();
  plan.createdAt =
      QDateTime::fromString(query.value("created_at").toString(), Qt::ISODate);
  plan.updatedAt =
      QDateTime::fromString(query.value("updated_at").toString(), Qt::ISODate);
  return plan;
}

} // namespace GymOS::Infrastructure::Repositories
