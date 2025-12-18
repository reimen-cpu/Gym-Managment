#include "MemberRepository.h"
#include <QDateTime>
#include <QJsonDocument>

namespace GymOS::Infrastructure::Repositories {

MemberRepository::MemberRepository() : m_db(DatabaseManager::instance()) {}

int64_t MemberRepository::insert(const Member &member) {
  QString sql = R"(
        INSERT INTO members (first_name, last_name, email, phone, social_media,
                           health_notes, weight_kg, height_cm, observations)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    )";

  QVariantList params = {
      member.firstName,
      member.lastName,
      member.email.has_value() ? QVariant(member.email.value()) : QVariant(),
      member.phone.has_value() ? QVariant(member.phone.value()) : QVariant(),
      member.socialMedia.isEmpty()
          ? QVariant()
          : QString(QJsonDocument(member.socialMedia)
                        .toJson(QJsonDocument::Compact)),
      member.healthNotes.has_value() ? QVariant(member.healthNotes.value())
                                     : QVariant(),
      member.weightKg.has_value() ? QVariant(member.weightKg.value())
                                  : QVariant(),
      member.heightCm.has_value() ? QVariant(member.heightCm.value())
                                  : QVariant(),
      member.observations.has_value() ? QVariant(member.observations.value())
                                      : QVariant()};

  QSqlQuery query = m_db.executeQuery(sql, params);
  return query.lastInsertId().toLongLong();
}

void MemberRepository::update(const Member &member) {
  QString sql = R"(
        UPDATE members SET
            first_name = ?,
            last_name = ?,
            email = ?,
            phone = ?,
            social_media = ?,
            health_notes = ?,
            weight_kg = ?,
            height_cm = ?,
            observations = ?,
            updated_at = datetime('now')
        WHERE id = ?
    )";

  QVariantList params = {
      member.firstName,
      member.lastName,
      member.email.has_value() ? QVariant(member.email.value()) : QVariant(),
      member.phone.has_value() ? QVariant(member.phone.value()) : QVariant(),
      member.socialMedia.isEmpty()
          ? QVariant()
          : QString(QJsonDocument(member.socialMedia)
                        .toJson(QJsonDocument::Compact)),
      member.healthNotes.has_value() ? QVariant(member.healthNotes.value())
                                     : QVariant(),
      member.weightKg.has_value() ? QVariant(member.weightKg.value())
                                  : QVariant(),
      member.heightCm.has_value() ? QVariant(member.heightCm.value())
                                  : QVariant(),
      member.observations.has_value() ? QVariant(member.observations.value())
                                      : QVariant(),
      member.id};

  m_db.executeQuery(sql, params);
}

bool MemberRepository::remove(int64_t id) {
  // Verificar si tiene suscripciones
  QSqlQuery checkQuery = m_db.executeQuery(
      "SELECT COUNT(*) FROM subscriptions WHERE member_id = ?", {id});

  if (checkQuery.next() && checkQuery.value(0).toInt() > 0) {
    qWarning()
        << "No se puede eliminar el miembro: tiene suscripciones asociadas";
    return false;
  }

  m_db.executeQuery("DELETE FROM members WHERE id = ?", {id});
  return true;
}

std::optional<Member> MemberRepository::findById(int64_t id) const {
  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM members WHERE id = ?", {id});

  if (query.next()) {
    return mapRow(query);
  }
  return std::nullopt;
}

std::optional<Member>
MemberRepository::findByEmail(const QString &email) const {
  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM members WHERE email = ?", {email});

  if (query.next()) {
    return mapRow(query);
  }
  return std::nullopt;
}

std::vector<Member> MemberRepository::findAll() const {
  std::vector<Member> members;
  QSqlQuery query =
      m_db.executeQuery("SELECT * FROM members ORDER BY last_name, first_name");

  while (query.next()) {
    members.push_back(mapRow(query));
  }
  return members;
}

std::vector<Member> MemberRepository::search(const QString &searchQuery) const {
  std::vector<Member> members;
  QString pattern = "%" + searchQuery + "%";

  QSqlQuery query = m_db.executeQuery(
      R"(SELECT * FROM members 
           WHERE first_name LIKE ? OR last_name LIKE ? OR email LIKE ?
           ORDER BY last_name, first_name)",
      {pattern, pattern, pattern});

  while (query.next()) {
    members.push_back(mapRow(query));
  }
  return members;
}

int MemberRepository::count() const {
  QSqlQuery query = m_db.executeQuery("SELECT COUNT(*) FROM members");
  if (query.next()) {
    return query.value(0).toInt();
  }
  return 0;
}

Member MemberRepository::mapRow(QSqlQuery &query) const {
  Member member;
  member.id = query.value("id").toLongLong();
  member.firstName = query.value("first_name").toString();
  member.lastName = query.value("last_name").toString();

  if (!query.value("email").isNull()) {
    member.email = query.value("email").toString();
  }
  if (!query.value("phone").isNull()) {
    member.phone = query.value("phone").toString();
  }
  if (!query.value("social_media").isNull()) {
    member.socialMedia =
        QJsonDocument::fromJson(query.value("social_media").toString().toUtf8())
            .object();
  }
  if (!query.value("health_notes").isNull()) {
    member.healthNotes = query.value("health_notes").toString();
  }
  if (!query.value("weight_kg").isNull()) {
    member.weightKg = query.value("weight_kg").toDouble();
  }
  if (!query.value("height_cm").isNull()) {
    member.heightCm = query.value("height_cm").toDouble();
  }
  if (!query.value("observations").isNull()) {
    member.observations = query.value("observations").toString();
  }

  member.createdAt =
      QDateTime::fromString(query.value("created_at").toString(), Qt::ISODate);
  member.updatedAt =
      QDateTime::fromString(query.value("updated_at").toString(), Qt::ISODate);

  return member;
}

} // namespace GymOS::Infrastructure::Repositories
