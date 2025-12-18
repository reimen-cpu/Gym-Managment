#pragma once

#include "../../core/models/Member.h"
#include "../../core/models/Plan.h"
#include "../../core/services/FinanceEngine.h"
#include "../../core/services/SubscriptionManager.h"
#include "../../infrastructure/repositories/MemberRepository.h"
#include "../../infrastructure/repositories/PlanRepository.h"
#include <QDate>
#include <QObject>
#include <QVariantList>
#include <QVariantMap>

namespace GymOS::UI::Controllers {

using namespace GymOS::Core::Models;
using namespace GymOS::Core::Services;
using namespace GymOS::Infrastructure::Repositories;

/**
 * @brief Controlador principal para la interfaz QML
 *
 * Expone los servicios del backend a QML a través de métodos Q_INVOKABLE.
 */
class GymController : public QObject {
  Q_OBJECT

  // Propiedades para binding en QML
  Q_PROPERTY(QVariantList plans READ getPlans NOTIFY plansChanged)
  Q_PROPERTY(QVariantList members READ getMembers NOTIFY membersChanged)
  Q_PROPERTY(QVariantList activeSubscriptions READ getActiveSubscriptions NOTIFY
                 subscriptionsChanged)
  Q_PROPERTY(QVariantList expiringSubscriptions READ getExpiringSubscriptions
                 NOTIFY subscriptionsChanged)
  Q_PROPERTY(QVariantMap financialSummary READ getFinancialSummary NOTIFY
                 financialDataChanged)
  Q_PROPERTY(QVariantList recentTransactions READ getRecentTransactions NOTIFY
                 financialDataChanged)
  Q_PROPERTY(QVariantList monthlyBreakdown READ getMonthlyBreakdown NOTIFY
                 financialDataChanged)
  Q_PROPERTY(int totalMembers READ getTotalMembers NOTIFY membersChanged)
  Q_PROPERTY(int activeSubscriptionsCount READ getActiveSubscriptionsCount
                 NOTIFY subscriptionsChanged)
  Q_PROPERTY(int expiringSubscriptionsCount READ getExpiringSubscriptionsCount
                 NOTIFY subscriptionsChanged)
  Q_PROPERTY(double enrollmentFee READ getEnrollmentFee WRITE setEnrollmentFee
                 NOTIFY settingsChanged)

public:
  explicit GymController(QObject *parent = nullptr);

  // ========================================================================
  // Métodos invocables desde QML
  // ========================================================================

  /**
   * @brief Registra un nuevo miembro con suscripción
   */
  Q_INVOKABLE bool registerMember(const QString &firstName,
                                  const QString &lastName, const QString &email,
                                  const QString &phone, int planId,
                                  const QDate &startDate, double enrollmentFee);

  /**
   * @brief Registra un gasto
   */
  Q_INVOKABLE bool recordExpense(const QString &description, double amount);

  /**
   * @brief Registra un ingreso personalizado
   */
  Q_INVOKABLE bool recordIncome(const QString &description, double amount);

  /**
   * @brief Crea un nuevo plan
   */
  Q_INVOKABLE bool createPlan(const QString &name, int days, double price);

  /**
   * @brief Actualiza un plan existente
   */
  Q_INVOKABLE bool updatePlan(int planId, const QString &name, int days,
                              double price);

  /**
   * @brief Elimina un plan
   */
  Q_INVOKABLE bool deletePlan(int planId);

  /**
   * @brief Alterna el estado activo de un plan (activo/inactivo)
   */
  Q_INVOKABLE bool togglePlanStatus(int id, bool isActive);

  /**
   * @brief Actualiza la cuota de inscripción global
   */
  Q_INVOKABLE void setEnrollmentFee(double fee);

  /**
   * @brief Recarga todos los datos
   */
  Q_INVOKABLE void refreshData();

  /**
   * @brief Obtiene detalles completos de un miembro por ID
   */
  Q_INVOKABLE QVariantMap getMemberDetails(int memberId);

  /**
   * @brief Renueva la suscripción de un miembro
   */
  Q_INVOKABLE bool renewSubscription(int memberId, int planId,
                                     double priceOverride = 0);

  // ========================================================================
  // Getters para propiedades
  // ========================================================================

  QVariantList getPlans() const;
  QVariantList getMembers() const;
  QVariantList getActiveSubscriptions() const;
  QVariantList getExpiringSubscriptions() const;
  QVariantMap getFinancialSummary() const;
  QVariantList getRecentTransactions() const;
  QVariantList getMonthlyBreakdown() const;
  int getTotalMembers() const;
  int getActiveSubscriptionsCount() const;
  int getExpiringSubscriptionsCount() const;
  double getEnrollmentFee() const;

signals:
  void plansChanged();
  void membersChanged();
  void subscriptionsChanged();
  void financialDataChanged();
  void settingsChanged();
  void operationSuccess(const QString &message);
  void operationError(const QString &message);

private:
  mutable SubscriptionManager m_subscriptionManager;
  mutable FinanceEngine m_financeEngine;
  mutable MemberRepository m_memberRepo;
  mutable PlanRepository m_planRepo;
};

} // namespace GymOS::UI::Controllers
