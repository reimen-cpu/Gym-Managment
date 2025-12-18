#pragma once

#include "../../core/models/Subscription.h"
#include "../database/DatabaseManager.h"
#include <QSqlQuery>
#include <optional>
#include <vector>


namespace GymOS::Infrastructure::Repositories {

using namespace GymOS::Core::Models;
using namespace GymOS::Infrastructure::Database;

/**
 * @brief Repositorio de Suscripciones
 *
 * Utiliza la vista v_subscriptions_with_expiry para obtener
 * los datos calculados dinámicamente.
 */
class SubscriptionRepository {
public:
  SubscriptionRepository();

  [[nodiscard]] int64_t insert(const Subscription &subscription);

  [[nodiscard]] std::optional<Subscription> findById(int64_t id) const;
  [[nodiscard]] std::vector<Subscription> findAll() const;
  [[nodiscard]] std::vector<Subscription> findByMember(int64_t memberId) const;

  /**
   * @brief Obtiene la suscripción más reciente de un miembro
   */
  [[nodiscard]] std::optional<Subscription>
  findLatestByMember(int64_t memberId) const;

  /**
   * @brief Obtiene suscripciones por estado (calculado dinámicamente)
   */
  [[nodiscard]] std::vector<Subscription>
  findByStatus(SubscriptionStatus status) const;

  /**
   * @brief Obtiene suscripciones que vencen en los próximos N días
   */
  [[nodiscard]] std::vector<Subscription> findExpiringSoon(int days = 7) const;

  /**
   * @brief Cuenta suscripciones activas
   */
  [[nodiscard]] int countActive() const;

  /**
   * @brief Cuenta suscripciones vencidas
   */
  [[nodiscard]] int countExpired() const;

  /**
   * @brief Cuenta suscripciones por vencer
   */
  [[nodiscard]] int countExpiringSoon(int days = 7) const;

private:
  [[nodiscard]] Subscription mapRow(QSqlQuery &query) const;
  DatabaseManager &m_db;
};

} // namespace GymOS::Infrastructure::Repositories
