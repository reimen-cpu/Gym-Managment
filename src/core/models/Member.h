#pragma once

#include <QDateTime>
#include <QJsonObject>
#include <QString>
#include <optional>


namespace GymOS::Core::Models {

/**
 * @brief Entidad de Miembro del gimnasio
 *
 * Representa un cliente registrado en el gimnasio con sus datos personales
 * y de salud opcionales.
 */
struct Member {
  int64_t id = 0;
  QString firstName;
  QString lastName;
  std::optional<QString> email;
  std::optional<QString> phone;
  QJsonObject socialMedia; ///< {"instagram": "@user", "facebook": "url"}
  std::optional<QString> healthNotes;
  std::optional<double> weightKg;
  std::optional<double> heightCm;
  std::optional<QString> observations;
  QDateTime createdAt;
  QDateTime updatedAt;

  /**
   * @brief Obtiene el nombre completo del miembro
   */
  [[nodiscard]] QString fullName() const { return firstName + " " + lastName; }

  /**
   * @brief Obtiene las iniciales del nombre
   */
  [[nodiscard]] QString initials() const {
    QString result;
    if (!firstName.isEmpty()) {
      result += firstName.at(0).toUpper();
    }
    if (!lastName.isEmpty()) {
      result += lastName.at(0).toUpper();
    }
    return result;
  }

  /**
   * @brief Verifica si el miembro tiene datos de contacto
   */
  [[nodiscard]] bool hasContactInfo() const {
    return email.has_value() || phone.has_value();
  }

  /**
   * @brief Verifica si el miembro es nuevo (creado en la última semana)
   */
  [[nodiscard]] bool isNew() const {
    return createdAt.daysTo(QDateTime::currentDateTime()) <= 7;
  }
};

} // namespace GymOS::Core::Models
