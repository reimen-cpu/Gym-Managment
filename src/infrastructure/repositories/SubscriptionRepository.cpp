#include "SubscriptionRepository.h"
#include <QDate>

namespace GymOS::Infrastructure::Repositories {

SubscriptionRepository::SubscriptionRepository()
    : m_db(DatabaseManager::instance()) {}

int64_t SubscriptionRepository::insert(const Subscription &subscription) {
  QString sql = R"(
        INSERT INTO subscriptions (member_id, plan_id, start_date, enrollment_fee)
        VALUES (?, ?, ?, ?)
    )";

  QSqlQuery query =
      m_db.executeQuery(sql, {subscription.memberId, subscription.planId,
                              subscription.startDate.toString(Qt::ISODate),
                              subscription.enrollmentFee});

  return query.lastInsertId().toLongLong();
}

std::optional<Subscription> SubscriptionRepository::findById(int64_t id) const {
  QSqlQuery query = m_db.executeQuery(
      "SELECT * FROM v_subscriptions_with_expiry WHERE id = ?", {id});

  if (query.next()) {
    return mapRow(query);
  }
  return std::nullopt;
}

std::vector<Subscription> SubscriptionRepository::findAll() const {
  std::vector<Subscription> subscriptions;
  QSqlQuery query = m_db.executeQuery(
      "SELECT * FROM v_subscriptions_with_expiry ORDER BY end_date");

  while (query.next()) {
    subscriptions.push_back(mapRow(query));
  }
  return subscriptions;
}

std::vector<Subscription>
SubscriptionRepository::findByMember(int64_t memberId) const {
  std::vector<Subscription> subscriptions;
  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM v_subscriptions_with_expiry WHERE "
                        "member_id = ? ORDER BY start_date DESC",
                        {memberId});

  while (query.next()) {
    subscriptions.push_back(mapRow(query));
  }
  return subscriptions;
}

std::optional<Subscription>
SubscriptionRepository::findLatestByMember(int64_t memberId) const {
  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM v_subscriptions_with_expiry WHERE "
                        "member_id = ? ORDER BY start_date DESC LIMIT 1",
                        {memberId});

  if (query.next()) {
    return mapRow(query);
  }
  return std::nullopt;
}

std::vector<Subscription>
SubscriptionRepository::findByStatus(SubscriptionStatus status) const {
  std::vector<Subscription> subscriptions;

  if (status == SubscriptionStatus::Active) {
    // STRICT DATE LOGIC for Active
    // User Requirement: "A user is 'Active' if CURRENT_DATE is between
    // start_date and end_date"
    QString sql = R"(
        SELECT * FROM v_subscriptions_with_expiry 
        WHERE date('now') BETWEEN start_date AND end_date
        ORDER BY end_date
      )";
    QSqlQuery query = m_db.executeQuery(sql);
    while (query.next()) {
      subscriptions.push_back(mapRow(query));
    }
    return subscriptions;
  }

  QString statusStr;
  switch (status) {
  // Active handled above
  case SubscriptionStatus::ExpiringSoon:
    statusStr = "expiring";
    break;
  case SubscriptionStatus::Expired:
    statusStr = "expired";
    break;
  default:
    return subscriptions;
  }

  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM v_subscriptions_with_expiry WHERE "
                        "status = ? ORDER BY end_date",
                        {statusStr});

  while (query.next()) {
    subscriptions.push_back(mapRow(query));
  }
  return subscriptions;
}

std::vector<Subscription>
SubscriptionRepository::findExpiringSoon(int days) const {
  std::vector<Subscription> subscriptions;

  // Obtener suscripciones que vencen en los próximos N días pero no han vencido
  // aún
  QString sql = R"(
        SELECT * FROM v_subscriptions_with_expiry 
        WHERE end_date >= date('now') 
          AND end_date <= date('now', '+' || ? || ' days')
        ORDER BY end_date
    )";

  QSqlQuery query = m_db.executeQuery(sql, {days});

  while (query.next()) {
    subscriptions.push_back(mapRow(query));
  }
  return subscriptions;
}

int SubscriptionRepository::countActive() const {
  // STRICT DATE LOGIC: Active if current date is between start and end date
  // This replaces the previous reliance on the view's 'status' column which
  // might exclude 'expiring' members
  QString sql = R"(
        SELECT COUNT(*) FROM v_subscriptions_with_expiry 
        WHERE date('now') BETWEEN start_date AND end_date
    )";

  QSqlQuery query = m_db.executeQuery(sql);
  if (query.next()) {
    return query.value(0).toInt();
  }
  return 0;
}

int SubscriptionRepository::countExpired() const {
  QSqlQuery query =
      m_db.executeQuery("SELECT COUNT(*) FROM v_subscriptions_with_expiry "
                        "WHERE end_date < date('now')");
  if (query.next()) {
    return query.value(0).toInt();
  }
  return 0;
}

int SubscriptionRepository::countExpiringSoon(int days) const {
  QString sql = R"(
        SELECT COUNT(*) FROM v_subscriptions_with_expiry 
        WHERE end_date >= date('now') 
          AND end_date <= date('now', '+' || ? || ' days')
    )";

  QSqlQuery query = m_db.executeQuery(sql, {days});
  if (query.next()) {
    return query.value(0).toInt();
  }
  return 0;
}

Subscription SubscriptionRepository::mapRow(QSqlQuery &query) const {
  Subscription subscription;
  subscription.id = query.value("id").toLongLong();
  subscription.memberId = query.value("member_id").toLongLong();
  subscription.planId = query.value("plan_id").toLongLong();
  subscription.startDate =
      QDate::fromString(query.value("start_date").toString(), Qt::ISODate);
  subscription.enrollmentFee = query.value("enrollment_fee").toDouble();

  // Datos asociados desde la vista
  subscription.memberName = query.value("member_name").toString();
  subscription.planName = query.value("plan_name").toString();
  subscription.planDurationDays = query.value("duration_days").toInt();
  subscription.planPrice = query.value("plan_price").toDouble();

  return subscription;
}

} // namespace GymOS::Infrastructure::Repositories
