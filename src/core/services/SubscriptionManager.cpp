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
                                               const QDate &startDate) {
  // Obtener la suscripción actual
  auto currentSub = m_subscriptionRepo.findLatestByMember(memberId);

  // Determinar fecha de inicio
  QDate newStartDate = startDate;
  if (!newStartDate.isValid()) {
    if (currentSub && currentSub->endDate() > QDate::currentDate()) {
      // Si la suscripción actual aún no venció, iniciar desde su fin
      newStartDate = currentSub->endDate();
    } else {
      // Si ya venció o no tiene, iniciar hoy
      newStartDate = QDate::currentDate();
    }
  }

  // Verificar que el plan existe
  auto plan = m_planRepo.findById(planId);
  if (!plan || !plan->isActive) {
    emit error("El plan no existe o no está activo");
    return -1;
  }

  auto &db = DatabaseManager::instance();
  db.beginTransaction();

  try {
    // Crear nueva suscripción (sin cuota de inscripción en renovación)
    Subscription subscription;
    subscription.memberId = memberId;
    subscription.planId = planId;
    subscription.startDate = newStartDate;
    subscription.enrollmentFee = 0;
    subscription.planDurationDays = plan->durationDays;

    int64_t subscriptionId = m_subscriptionRepo.insert(subscription);

    // Registrar el ingreso
    auto member = m_memberRepo.findById(memberId);
    FinanceEngine financeEngine;
    financeEngine.recordRenewalIncome(
        plan->price,
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
  return m_subscriptionRepo.findExpiringSoon(days);
}

std::vector<Subscription> SubscriptionManager::getExpired() {
  return m_subscriptionRepo.findByStatus(SubscriptionStatus::Expired);
}

std::vector<Subscription> SubscriptionManager::getActive() {
  return m_subscriptionRepo.findByStatus(SubscriptionStatus::Active);
}

std::vector<Subscription> SubscriptionManager::getAll() {
  return m_subscriptionRepo.findAll();
}

SubscriptionManager::Stats SubscriptionManager::getStats() {
  Stats stats;
  stats.activeCount = m_subscriptionRepo.countActive();
  stats.expiringCount = m_subscriptionRepo.countExpiringSoon(7);
  stats.expiredCount = m_subscriptionRepo.countExpired();
  return stats;
}

} // namespace GymOS::Core::Services
