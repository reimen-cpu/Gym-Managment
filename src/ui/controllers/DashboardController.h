#pragma once

#include "../../core/services/FinanceEngine.h"
#include "../../core/services/SubscriptionManager.h"
#include "../../infrastructure/repositories/MemberRepository.h"
#include <QObject>
#include <QVariantList>
#include <QVariantMap>


namespace GymOS::UI::Controllers {

using namespace GymOS::Core::Services;
using namespace GymOS::Infrastructure::Repositories;

/**
 * @brief Controlador del Dashboard
 *
 * Expone datos y acciones del dashboard a QML.
 */
class DashboardController : public QObject {
  Q_OBJECT

  // Propiedades expuestas a QML
  Q_PROPERTY(int activeCount READ activeCount NOTIFY statsChanged)
  Q_PROPERTY(int inactiveCount READ inactiveCount NOTIFY statsChanged)
  Q_PROPERTY(int expiringCount READ expiringCount NOTIFY statsChanged)
  Q_PROPERTY(QVariantList expiringSubscriptions READ expiringSubscriptions
                 NOTIFY dataChanged)

public:
  explicit DashboardController(QObject *parent = nullptr);

  // Getters
  int activeCount() const { return m_activeCount; }
  int inactiveCount() const { return m_inactiveCount; }
  int expiringCount() const { return m_expiringCount; }
  QVariantList expiringSubscriptions() const { return m_expiringSubscriptions; }

  // Métodos invocables desde QML
  Q_INVOKABLE void refresh();
  Q_INVOKABLE void openMemberDetail(int memberId);

signals:
  void statsChanged();
  void dataChanged();
  void memberDetailRequested(int memberId);

private:
  void loadStats();
  void loadExpiringSubscriptions();
  QVariantMap
  subscriptionToVariant(const Core::Models::Subscription &sub) const;

  SubscriptionManager m_subscriptionManager;
  MemberRepository m_memberRepo;

  int m_activeCount = 0;
  int m_inactiveCount = 0;
  int m_expiringCount = 0;
  QVariantList m_expiringSubscriptions;
};

} // namespace GymOS::UI::Controllers
