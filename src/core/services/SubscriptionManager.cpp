#include "SubscriptionManager.h"
#include "../../infrastructure/database/DatabaseManager.h"
#include "FinanceEngine.h"

namespace GymOS::Core::Services {

using namespace GymOS::Infrastructure::Database;

SubscriptionManager::SubscriptionManager(QObject *parent) : QObject(parent) {}

int64_t SubscriptionManager::createSubscription(int64_t memberId,
                                                int64_t planId,
                                                const QDate &startDate,
                                                double enrollmentFee) {
  // Verificar que el miembro existe
  auto member = m_memberRepo.findById(memberId);
  if (!member) {
    emit error("El miembro no existe");
    return -1;
  }

  // Verificar que el plan existe y está activo
  auto plan = m_planRepo.findById(planId);
  if (!plan || !plan->isActive) {
    emit error("El plan no existe o no está activo");
    return -1;
  }

  // Transaction managed by caller (GymController)

  try {
    // Crear la suscripción
    Subscription subscription;
    subscription.memberId = memberId;
    subscription.planId = planId;
    subscription.startDate = startDate;
    subscription.enrollmentFee = enrollmentFee;
    subscription.planDurationDays = plan->durationDays;

    int64_t subscriptionId = m_subscriptionRepo.insert(subscription);

    // Registrar el ingreso en finanzas
    FinanceEngine financeEngine;
    financeEngine.recordEnrollmentIncome(
        plan->price, member->fullName() + " - " + plan->name, startDate);

    emit subscriptionCreated(subscriptionId);
    return subscriptionId;

  } catch (const std::exception &e) {
    emit error(QString("Error al crear suscripción: %1").arg(e.what()));
    throw; // Propagate exception to trigger rollback in caller
  }
}

int64_t SubscriptionManager::renewSubscription(int64_t memberId, int64_t planId,
                                               const QDate &startDate,
                                               double priceOverride) {
  qDebug() << "[SubscriptionManager] renewSubscription called for member:"
           << memberId;

  // Obtener la suscripción actual
  auto currentSub = m_subscriptionRepo.findLatestByMember(memberId);

  // Calcular días restantes de la suscripción actual (si todavía está activa)
  int remainingDays = 0;
  if (currentSub && currentSub->endDate() > QDate::currentDate()) {
    remainingDays = QDate::currentDate().daysTo(currentSub->endDate());
    qDebug() << "[SubscriptionManager] Current subscription has"
             << remainingDays << "days remaining";
  }

  // La nueva suscripción SIEMPRE empieza HOY (o en la fecha especificada)
  QDate newStartDate = startDate.isValid() ? startDate : QDate::currentDate();

  // Verificar que el plan existe
  auto plan = m_planRepo.findById(planId);
  if (!plan || !plan->isActive) {
    emit error("El plan no existe o no está activo");
    return -1;
  }

  // ACUMULAR: nueva duración = días del plan + días restantes de la suscripción
  // actual
  int totalDurationDays = plan->durationDays + remainingDays;

  qDebug() << "[SubscriptionManager] Day accumulation:" << plan->durationDays
           << "(plan) +" << remainingDays
           << "(remaining) =" << totalDurationDays << "days";
  qDebug() << "[SubscriptionManager] New subscription: Start:"
           << newStartDate.toString("dd/MM/yyyy") << "End:"
           << newStartDate.addDays(totalDurationDays).toString("dd/MM/yyyy");

  auto &db = DatabaseManager::instance();
  db.beginTransaction();

  try {
    // Crear nueva suscripción con duración acumulada
    Subscription subscription;
    subscription.memberId = memberId;
    subscription.planId = planId;
    subscription.startDate = newStartDate;
    subscription.enrollmentFee = 0;
    subscription.planDurationDays = totalDurationDays; // ← Duración ACUMULADA

    int64_t subscriptionId = m_subscriptionRepo.insert(subscription);

    // Registrar el ingreso
    double finalPrice = (priceOverride >= 0) ? priceOverride : plan->price;

    auto member = m_memberRepo.findById(memberId);
    FinanceEngine financeEngine;
    financeEngine.recordRenewalIncome(
        finalPrice,
        (member ? member->fullName() : "Miembro") + " - Renovación " +
            plan->name,
        newStartDate);

    db.commitTransaction();
    emit subscriptionRenewed(subscriptionId);
    return subscriptionId;

  } catch (const std::exception &e) {
    db.rollbackTransaction();
    emit error(QString("Error al renovar suscripción: %1").arg(e.what()));
    return -1;
  }
}

std::vector<Subscription> SubscriptionManager::getExpiringSoon(int days) {
  auto expiring = m_subscriptionRepo.findExpiringSoon(days);
  std::vector<Subscription> filtered;

  for (const auto &sub : expiring) {
    auto latest = m_subscriptionRepo.findLatestByMember(sub.memberId);
    // Si existe una suscripción posterior (ej: renovada), ignoramos la que
    // vence
    if (latest && latest->endDate() > sub.endDate()) {
      continue;
    }
    filtered.push_back(sub);
  }
  return filtered;
}

std::vector<Subscription> SubscriptionManager::getExpired() {
  auto expired = m_subscriptionRepo.findByStatus(SubscriptionStatus::Expired);
  std::vector<Subscription> filtered;

  for (const auto &sub : expired) {
    auto latest = m_subscriptionRepo.findLatestByMember(sub.memberId);
    // Si el miembro tiene una suscripción más reciente (activa o futura),
    // ignoramos la expirada
    if (latest && latest->endDate() > sub.endDate()) {
      continue;
    }
    filtered.push_back(sub);
  }
  return filtered;
}

std::vector<Subscription> SubscriptionManager::getActive() {
  return m_subscriptionRepo.findByStatus(SubscriptionStatus::Active);
}

std::vector<Subscription> SubscriptionManager::getAll() {
  auto all = m_subscriptionRepo.findAll();
  std::vector<Subscription> filtered;

  for (const auto &sub : all) {
    // Para cada suscripción, verificar si es la más reciente del miembro
    auto latest = m_subscriptionRepo.findLatestByMember(sub.memberId);

    if (latest && latest->id != sub.id) {
      // Esta no es la suscripción más reciente del miembro, ocultarla
      continue;
    }

    filtered.push_back(sub);
  }
  return filtered;
}

SubscriptionManager::Stats SubscriptionManager::getStats() {
  Stats stats;
  stats.activeCount = m_subscriptionRepo.countActive();
  stats.expiringCount = m_subscriptionRepo.countExpiringSoon(7);
  stats.expiredCount = m_subscriptionRepo.countExpired();
  return stats;
}

} // namespace GymOS::Core::Services
