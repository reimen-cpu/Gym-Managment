#pragma once

#include <QDateTime>
#include <QString>

namespace GymOS::Core::Models {

/**
 * @brief Plan de suscripción
 *
 * Define un tipo de membresía con duración y precio fijos.
 */
struct Plan {
  int64_t id = 0;
  QString name;
  int durationDays;
  double price;
  bool isActive = true;
  QDateTime createdAt;
  QDateTime updatedAt;

  /**
   * @brief Formatea la duración en texto legible
   */
  [[nodiscard]] QString formattedDuration() const {
    if (durationDays % 30 == 0) {
      int months = durationDays / 30;
      return months == 1 ? "1 mes" : QString::number(months) + " meses";
    }
    return QString::number(durationDays) + " días";
  }

  /**
   * @brief Formatea el precio con símbolo de moneda
   */
  [[nodiscard]] QString formattedPrice() const {
    return "$" + QString::number(price, 'f', 2);
  }

  /**
   * @brief Calcula precio diario referencia
   */
  [[nodiscard]] double pricePerDay() const {
    if (durationDays <= 0)
      return 0;
    return price / durationDays;
  }
};

} // namespace GymOS::Core::Models
