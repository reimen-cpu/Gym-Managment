#include "DashboardController.h"

namespace GymOS::UI::Controllers {

DashboardController::DashboardController(QObject *parent) : QObject(parent) {
  refresh();
}

void DashboardController::refresh() {
  loadStats();
  loadExpiringSubscriptions();
}

void DashboardController::openMemberDetail(int memberId) {
  emit memberDetailRequested(memberId);
}

void DashboardController::loadStats() {
  auto stats = m_subscriptionManager.getStats();

  bool changed = false;

  if (m_activeCount != stats.activeCount) {
    m_activeCount = stats.activeCount;
    changed = true;
  }

  if (m_expiringCount != stats.expiringCount) {
    m_expiringCount = stats.expiringCount;
    changed = true;
  }

  // Calcular inactivos (miembros totales - activos - por vencer)
  int totalMembers = m_memberRepo.count();
  int newInactiveCount = totalMembers - m_activeCount - m_expiringCount;
  if (newInactiveCount < 0)
    newInactiveCount = 0;

  if (m_inactiveCount != newInactiveCount) {
    m_inactiveCount = newInactiveCount;
    changed = true;
  }

  if (changed) {
    emit statsChanged();
  }
}

void DashboardController::loadExpiringSubscriptions() {
  m_expiringSubscriptions.clear();

  auto subscriptions = m_subscriptionManager.getExpiringSoon(7);

  for (const auto &sub : subscriptions) {
    m_expiringSubscriptions.append(subscriptionToVariant(sub));
  }

  // También agregar algunas suscripciones vencidas recientes
  auto expired = m_subscriptionManager.getExpired();
  for (const auto &sub : expired) {
    if (m_expiringSubscriptions.size() >= 10)
      break;
    m_expiringSubscriptions.append(subscriptionToVariant(sub));
  }

  emit dataChanged();
}

QVariantMap DashboardController::subscriptionToVariant(
    const Core::Models::Subscription &sub) const {
  QVariantMap map;
  map["id"] = static_cast<int>(sub.id);
  map["memberId"] = static_cast<int>(sub.memberId);
  map["name"] = sub.memberName;
  map["plan"] = sub.planName;
  map["startDate"] = sub.startDate.toString("dd/MM/yyyy");
  map["endDate"] = sub.endDate().toString("dd/MM/yyyy");
  map["status"] = sub.statusId();
  map["daysLeft"] = sub.daysUntilExpiry();
  return map;
}

} // namespace GymOS::UI::Controllers
