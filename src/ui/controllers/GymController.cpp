#include "GymController.h"
#include <QDebug>
#include <QSettings>

namespace GymOS::UI::Controllers {

GymController::GymController(QObject *parent) : QObject(parent) {
  qDebug() << "[GymController] Initialized";
}

// ============================================================================
// Métodos invocables desde QML
// ============================================================================

bool GymController::registerMember(const QString &firstName,
                                   const QString &lastName,
                                   const QString &email, const QString &phone,
                                   int planId, const QDate &startDate,
                                   double enrollmentFee) {
  qDebug() << "[GymController] registerMember called";
  qDebug() << "  - Name:" << firstName << lastName;
  qDebug() << "  - Email:" << email;
  qDebug() << "  - Phone:" << phone;
  qDebug() << "  - Plan ID:" << planId;
  qDebug() << "  - Start Date:" << startDate;
  qDebug() << "  - Enrollment Fee:" << enrollmentFee;

  auto &dbManager =
      GymOS::Infrastructure::Database::DatabaseManager::instance();
  if (!dbManager.beginTransaction()) {
    qCritical() << "[GymController] Failed to begin transaction";
    emit operationError("Error interno: No se pudo iniciar la transacción");
    return false;
  }

  try {
    // 1. Crear el miembro
    Member member;
    member.firstName = firstName;
    member.lastName = lastName;
    if (!email.isEmpty()) {
      member.email = email;
    }
    if (!phone.isEmpty()) {
      member.phone = phone;
    }

    int64_t memberId = m_memberRepo.insert(member);
    qDebug() << "[GymController] Member created with ID:" << memberId;

    // 2. Crear la suscripción
    int64_t subscriptionId = m_subscriptionManager.createSubscription(
        memberId, planId, startDate, enrollmentFee);
    qDebug() << "[GymController] Subscription created with ID:"
             << subscriptionId;

    // 3. Registrar transacción financiera inicial (Enrollment Fee)
    if (enrollmentFee > 0) {
      m_financeEngine.recordCustomIncome(
          enrollmentFee,
          QString("Inscripción - %1 %2").arg(firstName, lastName));
      qDebug() << "[GymController] Financial entry created for enrollment";
    }

    // 4. Confirmar transacción
    if (!dbManager.commitTransaction()) {
      throw std::runtime_error("Failed to commit transaction");
    }
    qDebug() << "[GymController] Transaction committed successfully";

    // 5. Emitir señales de actualización
    emit membersChanged();
    emit subscriptionsChanged();
    emit financialDataChanged();
    emit operationSuccess("Miembro registrado exitosamente");

    return true;
  } catch (const std::exception &e) {
    dbManager.rollbackTransaction();
    qWarning() << "[GymController] Error registering member (Rolled back):"
               << e.what();
    emit operationError(QString("Error al registrar: %1").arg(e.what()));
    return false;
  }
}

bool GymController::recordExpense(const QString &description, double amount) {
  qDebug() << "[GymController] recordExpense called";
  qDebug() << "  - Description:" << description;
  qDebug() << "  - Amount:" << amount;

  try {
    int64_t entryId = m_financeEngine.recordCustomExpense(amount, description);
    qDebug() << "[GymController] Expense recorded with ID:" << entryId;

    emit financialDataChanged();
    emit operationSuccess("Gasto registrado exitosamente");
    return true;
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Error recording expense:" << e.what();
    emit operationError(QString("Error al registrar gasto: %1").arg(e.what()));
    return false;
  }
}

bool GymController::recordIncome(const QString &description, double amount) {
  qDebug() << "[GymController] recordIncome called";
  qDebug() << "  - Description:" << description;
  qDebug() << "  - Amount:" << amount;

  try {
    int64_t entryId = m_financeEngine.recordCustomIncome(amount, description);
    qDebug() << "[GymController] Income recorded with ID:" << entryId;

    emit financialDataChanged();
    emit operationSuccess("Ingreso registrado exitosamente");
    return true;
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Error recording income:" << e.what();
    emit operationError(
        QString("Error al registrar ingreso: %1").arg(e.what()));
    return false;
  }
}

void GymController::setEnrollmentFee(double fee) {
  auto &dbManager =
      GymOS::Infrastructure::Database::DatabaseManager::instance();
  // Upsert enrollment_fee
  dbManager.executeQuery(
      "INSERT INTO settings (key, value, updated_at) VALUES ('enrollment_fee', "
      "?, datetime('now')) "
      "ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = "
      "excluded.updated_at",
      {QString::number(fee)});

  emit settingsChanged();
}

double GymController::getEnrollmentFee() const {
  auto &dbManager =
      GymOS::Infrastructure::Database::DatabaseManager::instance();
  QSqlQuery query = dbManager.executeQuery(
      "SELECT value FROM settings WHERE key = 'enrollment_fee'");
  if (query.next()) {
    return query.value(0).toDouble();
  }
  return 0.0;
}

bool GymController::createPlan(const QString &name, int days, double price) {
  qDebug() << "[GymController] createPlan called";
  qDebug() << "  - Name:" << name;
  qDebug() << "  - Days:" << days;
  qDebug() << "  - Price:" << price;

  try {
    Plan plan;
    plan.name = name;
    plan.durationDays = days;
    plan.price = price;
    plan.isActive = true;

    int64_t planId = m_planRepo.insert(plan);
    qDebug() << "[GymController] Plan created with ID:" << planId;

    emit plansChanged();
    emit operationSuccess("Plan creado exitosamente");
    return true;
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Error creating plan:" << e.what();
    emit operationError(QString("Error al crear plan: %1").arg(e.what()));
    return false;
  }
}

bool GymController::updatePlan(int planId, const QString &name, int days,
                               double price) {
  qDebug() << "[GymController] updatePlan called for ID:" << planId;

  try {
    auto existingPlan = m_planRepo.findById(planId);
    if (!existingPlan) {
      emit operationError("Plan no encontrado");
      return false;
    }

    Plan plan = *existingPlan;
    plan.name = name;
    plan.durationDays = days;
    plan.price = price;

    m_planRepo.update(plan);
    qDebug() << "[GymController] Plan updated";

    emit plansChanged();
    emit operationSuccess("Plan actualizado exitosamente");
    return true;
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Error updating plan:" << e.what();
    emit operationError(QString("Error al actualizar plan: %1").arg(e.what()));
    return false;
  }
}

bool GymController::togglePlanStatus(int id, bool isActive) {
  qDebug() << "[GymController] togglePlanStatus called for ID:" << id
           << " New Status:" << isActive;
  auto &dbManager =
      GymOS::Infrastructure::Database::DatabaseManager::instance();
  QSqlQuery query = dbManager.executeQuery(
      "UPDATE plans SET is_active = ?, updated_at = datetime('now') WHERE id = "
      "?",
      {isActive ? 1 : 0, id});

  if (query.lastError().isValid()) {
    qWarning() << "[GymController] Error toggling plan status:"
               << query.lastError().text();
    emit operationError("Error al cambiar estado del plan");
    return false;
  }

  emit plansChanged();
  return true;
}

bool GymController::deletePlan(int planId) {
  qDebug() << "[GymController] deletePlan called for ID:" << planId;

  try {
    if (m_planRepo.remove(planId)) {
      emit plansChanged();
      emit operationSuccess("Plan eliminado exitosamente");
      return true;
    } else {
      emit operationError("No se pudo eliminar el plan");
      return false;
    }
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Error deleting plan:" << e.what();
    emit operationError(QString("Error al eliminar plan: %1").arg(e.what()));
    return false;
  }
}

void GymController::refreshData() {
  qDebug() << "[GymController] refreshData called";
  emit plansChanged();
  emit membersChanged();
  emit subscriptionsChanged();
  emit financialDataChanged();
  qDebug() << "[GymController] Data refreshed manually";
}

bool GymController::updateMember(int memberId, const QString &firstName,
                                 const QString &lastName, const QString &email,
                                 const QString &phone, const QString &instagram,
                                 double weight, double height,
                                 const QString &healthNotes,
                                 const QString &observations) {
  qDebug() << "[GymController] updateMember called for ID:" << memberId;

  try {
    auto existingMember = m_memberRepo.findById(memberId);
    if (!existingMember) {
      emit operationError("Miembro no encontrado");
      return false;
    }

    Member member = *existingMember;
    member.firstName = firstName;
    member.lastName = lastName;

    if (!email.isEmpty())
      member.email = email;
    else
      member.email = std::nullopt;

    if (!phone.isEmpty())
      member.phone = phone;
    else
      member.phone = std::nullopt;

    // Handle Social Media (Instagram)
    if (!instagram.isEmpty()) {
      QJsonObject social;
      social["instagram"] = instagram;
      member.socialMedia = social;
    } else {
      member.socialMedia = QJsonObject();
    }

    if (weight > 0)
      member.weightKg = weight;
    else
      member.weightKg = std::nullopt;

    if (height > 0)
      member.heightCm = height;
    else
      member.heightCm = std::nullopt;

    if (!healthNotes.isEmpty())
      member.healthNotes = healthNotes;
    else
      member.healthNotes = std::nullopt;

    if (!observations.isEmpty())
      member.observations = observations;
    else
      member.observations = std::nullopt;

    m_memberRepo.update(member);
    qDebug() << "[GymController] Member updated successfully";

    emit membersChanged();
    emit operationSuccess("Perfil actualizado correctamente");
    return true;
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Error updating member:" << e.what();
    emit operationError(QString("Error al actualizar: %1").arg(e.what()));
    return false;
  }
}

QVariantMap GymController::getMemberDetails(int memberId) {
  auto member = m_memberRepo.findById(memberId);
  if (!member)
    return {};

  QVariantMap map;
  map["id"] = static_cast<int>(member->id);
  map["firstName"] = member->firstName;
  map["lastName"] = member->lastName;
  map["fullName"] = member->fullName();
  map["email"] = member->email.value_or("");
  map["phone"] = member->phone.value_or("");
  map["instagram"] = member->socialMedia.value("instagram").toString();
  map["weight"] = member->weightKg.value_or(0.0);
  map["height"] = member->heightCm.value_or(0.0);
  map["healthNotes"] = member->healthNotes.value_or("");
  map["observations"] = member->observations.value_or("");
  map["registerDate"] = member->createdAt;

  return map;
}

bool GymController::renewSubscription(int memberId, int planId,
                                      double priceOverride) {
  qDebug() << "[GymController] Renewing subscription for member" << memberId
           << "Plan" << planId << "Price:" << priceOverride;

  try {
    int64_t newSubId = m_subscriptionManager.renewSubscription(
        memberId, planId, QDate(), priceOverride);

    qDebug() << "[GymController] renewSubscription returned:" << newSubId;

    if (newSubId != -1) {
      qDebug() << "[GymController] Subscription renewed successfully!";
      emit subscriptionsChanged();
      emit financialDataChanged();
      emit operationSuccess("Suscripción renovada exitosamente");
      return true;
    } else {
      qWarning() << "[GymController] renewSubscription returned -1 (failure)";
      emit operationError("Falló la renovación de la suscripción");
      return false;
    }
  } catch (const std::exception &e) {
    qWarning() << "[GymController] Exception in renewSubscription:" << e.what();
    emit operationError(QString("Error: %1").arg(e.what()));
    return false;
  }
}

QVariantList GymController::getMemberSubscriptionHistory(int memberId) {
  qDebug() << "[GymController] getMemberSubscriptionHistory called for member:"
           << memberId;
  QVariantList result;

  // Necesitamos acceso al repositorio de suscripciones
  // El SubscriptionManager no expone findByMember directamente, así que usamos
  // el repo
  auto &db = GymOS::Infrastructure::Database::DatabaseManager::instance();

  QVariantList params;
  params << memberId;

  QSqlQuery query = db.executeQuery(
      "SELECT s.id, s.member_id, s.plan_id, s.start_date, s.enrollment_fee, "
      "s.plan_duration_days, COALESCE(s.plan_duration_days, p.duration_days) "
      "as duration_days, "
      "p.name as plan_name, p.price as plan_price, "
      "date(s.start_date, '+' || COALESCE(s.plan_duration_days, "
      "p.duration_days) || ' days') as end_date "
      "FROM subscriptions s "
      "LEFT JOIN plans p ON s.plan_id = p.id "
      "WHERE s.member_id = ? "
      "ORDER BY s.start_date DESC",
      params);

  qDebug() << "[GymController] Query executed, checking results...";

  while (query.next()) {
    QVariantMap item;
    item["id"] = query.value("id").toInt();
    item["planId"] = query.value("plan_id").toInt();
    item["planName"] = query.value("plan_name").toString();
    item["startDate"] =
        query.value("start_date").toDate().toString("dd/MM/yyyy");
    item["endDate"] = query.value("end_date").toDate().toString("dd/MM/yyyy");
    item["price"] = query.value("plan_price").toDouble();
    item["enrollmentFee"] = query.value("enrollment_fee").toDouble();

    // Calcular el estado basado en la fecha
    QDate endDate = query.value("end_date").toDate();
    QDate today = QDate::currentDate();
    int daysLeft = today.daysTo(endDate);

    QString status;
    if (daysLeft < 0) {
      status = "expired";
    } else if (daysLeft <= 7) {
      status = "expiring";
    } else {
      status = "active";
    }
    item["status"] = status;
    item["daysLeft"] = daysLeft;

    result.append(item);
  }

  return result;
}

QVariantList GymController::getPlans() const {
  QVariantList result;
  auto plans = m_planRepo.findAll();
  for (const auto &plan : plans) {
    QVariantMap item;
    item["id"] = static_cast<int>(plan.id);
    item["name"] = plan.name;
    item["days"] = plan.durationDays;            // Changed from months
    item["duration"] = plan.formattedDuration(); // Optional helper for UI
    item["price"] = plan.price;
    item["isActive"] = plan.isActive;
    result.append(item);
  }
  return result;
}

QVariantList GymController::getMembers() const {
  QVariantList result;
  auto members = m_memberRepo.findAll();
  for (const auto &member : members) {
    QVariantMap item;
    item["id"] = static_cast<int>(member.id);
    item["firstName"] = member.firstName;
    item["lastName"] = member.lastName;
    item["email"] = member.email.value_or("");
    item["phone"] = member.phone.value_or("");
    result.append(item);
  }
  return result;
}

QVariantList GymController::getActiveSubscriptions() const {
  QVariantList result;
  auto subs = m_subscriptionManager.getActive();
  for (const auto &sub : subs) {
    QVariantMap item;
    item["id"] = static_cast<int>(sub.id);
    item["memberId"] = static_cast<int>(sub.memberId);
    item["name"] = sub.memberName;                            // Added
    item["plan"] = sub.planName;                              // Added
    item["startDate"] = sub.startDate.toString("dd/MM/yyyy"); // Formatted
    item["endDate"] = sub.endDate().toString("dd/MM/yyyy");   // Formatted
    item["status"] = sub.statusId(); // "active", "expiring", "expired"
    item["daysLeft"] = sub.daysUntilExpiry();
    result.append(item);
  }
  return result;
}

QVariantList GymController::getAllSubscriptions() const {
  QVariantList result;
  auto subs = m_subscriptionManager.getAll();
  for (const auto &sub : subs) {
    QVariantMap item;
    item["id"] = static_cast<int>(sub.id);
    item["memberId"] = static_cast<int>(sub.memberId);
    item["name"] = sub.memberName;
    item["plan"] = sub.planName;
    item["startDate"] = sub.startDate.toString("dd/MM/yyyy");
    item["endDate"] = sub.endDate().toString("dd/MM/yyyy");
    item["status"] = sub.statusId(); // "active", "expiring", "expired"
    item["daysLeft"] = sub.daysUntilExpiry();
    result.append(item);
  }
  return result;
}

QVariantList GymController::getExpiringSubscriptions() const {
  QVariantList result;
  auto subs = m_subscriptionManager.getExpiringSoon(7);
  for (const auto &sub : subs) {
    QVariantMap item;
    item["id"] = static_cast<int>(sub.id);
    item["memberId"] = static_cast<int>(sub.memberId);
    item["name"] = sub.memberName; // Added
    item["plan"] = sub.planName;   // Added
    item["startDate"] =
        sub.startDate.toString("dd/MM/yyyy");               // Formatted string
    item["endDate"] = sub.endDate().toString("dd/MM/yyyy"); // Formatted string
    item["status"] = "expiring";              // Explicit status for UI style
    item["daysLeft"] = sub.daysUntilExpiry(); // Renamed from daysRemaining
    result.append(item);
  }
  return result;
}

QVariantMap GymController::getFinancialSummary() const {
  auto summary = m_financeEngine.getCurrentMonthSummary();
  QVariantMap result;
  result["totalIncome"] = summary.totalIncome;
  result["totalExpenses"] = summary.totalExpenses;
  result["balance"] = summary.balance();
  return result;
}

QVariantList GymController::getRecentTransactions() const {
  QVariantList result;
  auto transactions = m_financeEngine.getLatestTransactions(10);
  for (const auto &entry : transactions) {
    QVariantMap item;
    item["id"] = static_cast<int>(entry.id);
    item["type"] = entry.entryTypeId();
    item["amount"] = entry.amount;
    item["description"] = entry.description;
    item["date"] = entry.entryDate;
    result.append(item);
  }
  return result;
}

QVariantList GymController::getMonthlyBreakdown() const {
  QVariantList result;
  auto breakdown = m_financeEngine.getMonthlyBreakdown(6);
  for (const auto &item : breakdown) {
    QVariantMap entry;
    entry["month"] = item.monthName();
    entry["income"] = item.income;
    entry["expense"] = item.expenses;
    result.append(entry);
  }
  return result;
}

QVariantList GymController::getMonthlyBreakdownForPeriod(int months) {
  QVariantList result;
  auto breakdown = m_financeEngine.getMonthlyBreakdown(months);
  for (const auto &item : breakdown) {
    QVariantMap entry;
    entry["month"] = item.monthName();
    entry["income"] = item.income;
    entry["expense"] = item.expenses;
    result.append(entry);
  }
  return result;
}

int GymController::getTotalMembers() const { return m_memberRepo.count(); }

int GymController::getActiveSubscriptionsCount() const {
  auto stats = m_subscriptionManager.getStats();
  return stats.activeCount;
}

int GymController::getExpiringSubscriptionsCount() const {
  auto stats = m_subscriptionManager.getStats();
  return stats.expiringCount;
}

bool GymController::getDarkMode() const {
  QSettings settings;
  return settings.value("theme/darkMode", false).toBool();
}

void GymController::setDarkMode(bool dark) {
  QSettings settings;
  if (settings.value("theme/darkMode", false).toBool() != dark) {
    settings.setValue("theme/darkMode", dark);
    emit darkModeChanged();
  }
}

} // namespace GymOS::UI::Controllers
