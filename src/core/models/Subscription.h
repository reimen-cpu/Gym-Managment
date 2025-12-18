#pragma once

#include <QDate>
#include <QDateTime>
#include <QString>

namespace GymOS::Core::Models {

/**
 * @brief Estado de la suscripción (calculado dinámicamente)
 */
enum class SubscriptionStatus {
  Active,       ///< Suscripción vigente
  ExpiringSoon, ///< Vence en los próximos 7 días
  Expired       ///< Ya venció
};

/**
 * @brief Suscripción de un miembro
 *
 * Representa la relación entre un miembro y un plan de pago.
 * La fecha de vencimiento se calcula dinámicamente basada en el plan.
 */
struct Subscription {
  int64_t id = 0;
  int64_t memberId;
  int64_t planId;
  QDate startDate;
  double enrollmentFee = 0.0;
  QDateTime createdAt;

  // Datos asociados (cargados vía JOIN, usados en vistas)
  QString memberName;
  QString planName;
  int planDurationDays = 0;
  double planPrice = 0.0;

  /**
   * @brief Calcula la fecha de vencimiento
   *
   * IMPORTANTE: Este valor NUNCA se almacena en la base de datos.
   * Siempre se calcula dinámicamente.
   */
  [[nodiscard]] QDate endDate() const {
    return startDate.addDays(planDurationDays);
  }

  /**
   * @brief Calcula el estado actual de la suscripción
   */
  [[nodiscard]] SubscriptionStatus status() const {
    const QDate today = QDate::currentDate();
    const QDate expiry = endDate();

    if (expiry < today) {
      return SubscriptionStatus::Expired;
    }
    if (expiry <= today.addDays(7)) {
      return SubscriptionStatus::ExpiringSoon;
    }
    return SubscriptionStatus::Active;
  }

  /**
   * @brief Calcula los días hasta el vencimiento
   * @return Días restantes (negativo si ya venció)
   */
  [[nodiscard]] int daysUntilExpiry() const {
    return QDate::currentDate().daysTo(endDate());
  }

  /**
   * @brief Verifica si la suscripción está activa
   */
  [[nodiscard]] bool isActive() const {
    return status() != SubscriptionStatus::Expired;
  }

  /**
   * @brief Obtiene el texto del estado en español
   */
  [[nodiscard]] QString statusText() const {
    switch (status()) {
    case SubscriptionStatus::Active:
      return "Activo";
    case SubscriptionStatus::ExpiringSoon:
      return "Por Vencer";
    case SubscriptionStatus::Expired:
      return "Vencido";
    }
    return "Desconocido";
  }

  /**
   * @brief Obtiene el identificador de estado para QML
   */
  [[nodiscard]] QString statusId() const {
    switch (status()) {
    case SubscriptionStatus::Active:
      return "active";
    case SubscriptionStatus::ExpiringSoon:
      return "expiring";
    case SubscriptionStatus::Expired:
      return "expired";
    }
    return "unknown";
  }
};

} // namespace GymOS::Core::Models
