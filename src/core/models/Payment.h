#pragma once

#include <QDate>
#include <QDateTime>
#include <QString>


namespace GymOS::Core::Models {

/**
 * @brief Tipo de pago
 */
enum class PaymentType {
  Enrollment, ///< Pago de inscripción
  Renewal,    ///< Pago de renovación
  Additional  ///< Pago adicional
};

/**
 * @brief Registro de pago (INMUTABLE)
 *
 * Los pagos son registros inmutables que no pueden ser modificados
 * ni eliminados una vez creados. Esto garantiza la integridad del
 * historial financiero.
 */
struct Payment {
  int64_t id = 0;
  int64_t subscriptionId;
  double amount;
  QDate paymentDate;
  PaymentType paymentType;
  QString notes;
  QDateTime createdAt;

  /**
   * @brief Obtiene el texto del tipo de pago en español
   */
  [[nodiscard]] QString paymentTypeText() const {
    switch (paymentType) {
    case PaymentType::Enrollment:
      return "Inscripción";
    case PaymentType::Renewal:
      return "Renovación";
    case PaymentType::Additional:
      return "Adicional";
    }
    return "Desconocido";
  }

  /**
   * @brief Obtiene el identificador del tipo para la base de datos
   */
  [[nodiscard]] QString paymentTypeId() const {
    switch (paymentType) {
    case PaymentType::Enrollment:
      return "enrollment";
    case PaymentType::Renewal:
      return "renewal";
    case PaymentType::Additional:
      return "additional";
    }
    return "unknown";
  }

  /**
   * @brief Convierte un string a PaymentType
   */
  static PaymentType paymentTypeFromString(const QString &str) {
    if (str == "enrollment")
      return PaymentType::Enrollment;
    if (str == "renewal")
      return PaymentType::Renewal;
    return PaymentType::Additional;
  }

  /**
   * @brief Formatea el monto con símbolo de moneda
   */
  [[nodiscard]] QString formattedAmount() const {
    return "$" + QString::number(amount, 'f', 2);
  }
};

} // namespace GymOS::Core::Models
