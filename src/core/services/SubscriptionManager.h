#pragma once

#include "../../infrastructure/repositories/FinancialEntryRepository.h"
#include "../../infrastructure/repositories/MemberRepository.h"
#include "../../infrastructure/repositories/PlanRepository.h"
#include "../../infrastructure/repositories/SubscriptionRepository.h"
#include "../models/FinancialEntry.h"
#include "../models/Subscription.h"
#include <QDate>
#include <QObject>
#include <memory>

namespace GymOS::Core::Services {

using namespace GymOS::Core::Models;
using namespace GymOS::Infrastructure::Repositories;

/**
 * @brief Gestor de Suscripciones
 *
 * Maneja la lógica de negocio relacionada con suscripciones:
 * - Crear nuevas suscripciones
 * - Renovar suscripciones existentes
 * - Consultar estados
 */
class SubscriptionManager : public QObject {
  Q_OBJECT

public:
  explicit SubscriptionManager(QObject *parent = nullptr);

  /**
   * @brief Crea una nueva suscripción con pago inicial
   * @param memberId ID del miembro
   * @param planId ID del plan
   * @param startDate Fecha de inicio
   * @param enrollmentFee Cuota de inscripción
   * @return ID de la suscripción creada
   */
  int64_t createSubscription(int64_t memberId, int64_t planId,
                             const QDate &startDate, double enrollmentFee);

  /**
   * @brief Renueva una suscripción existente
   * @param memberId ID del miembro
   * @param planId ID del nuevo plan
   * @param startDate Fecha de inicio (por defecto: fin de la suscripción
   * actual)
   * @return ID de la nueva suscripción
   */
  int64_t renewSubscription(int64_t memberId, int64_t planId,
                            const QDate &startDate = QDate(),
                            double priceOverride = -1.0);

  /**
   * @brief Obtiene suscripciones que vencen pronto
   */
  std::vector<Subscription> getExpiringSoon(int days = 7);

  /**
   * @brief Obtiene suscripciones vencidas
   */
  std::vector<Subscription> getExpired();

  /**
   * @brief Obtiene suscripciones activas
   */
  std::vector<Subscription> getActive();

  /**
   * @brief Obtiene TODAS las suscripciones (historial completo)
   */
  std::vector<Subscription> getAll();

  /**
   * @brief Obtiene estadísticas de suscripciones
   */
  struct Stats {
    int activeCount;
    int expiringCount;
    int expiredCount;
  };
  Stats getStats();

signals:
  void subscriptionCreated(int64_t subscriptionId);
  void subscriptionRenewed(int64_t subscriptionId);
  void error(const QString &message);

private:
  SubscriptionRepository m_subscriptionRepo;
  PlanRepository m_planRepo;
  MemberRepository m_memberRepo;
};

} // namespace GymOS::Core::Services
