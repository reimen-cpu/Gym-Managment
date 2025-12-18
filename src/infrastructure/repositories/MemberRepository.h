#pragma once

#include "../../core/models/Member.h"
#include "../database/DatabaseManager.h"
#include <QSqlQuery>
#include <optional>
#include <vector>


namespace GymOS::Infrastructure::Repositories {

using namespace GymOS::Core::Models;
using namespace GymOS::Infrastructure::Database;

/**
 * @brief Repositorio de Miembros
 *
 * Maneja todas las operaciones CRUD para la entidad Member.
 * No contiene lógica de negocio, solo acceso a datos.
 */
class MemberRepository {
public:
  MemberRepository();

  /**
   * @brief Inserta un nuevo miembro
   * @return ID del miembro insertado
   */
  [[nodiscard]] int64_t insert(const Member &member);

  /**
   * @brief Actualiza un miembro existente
   */
  void update(const Member &member);

  /**
   * @brief Elimina un miembro por ID
   * @note Solo se permite si no tiene suscripciones asociadas
   */
  bool remove(int64_t id);

  /**
   * @brief Busca un miembro por ID
   */
  [[nodiscard]] std::optional<Member> findById(int64_t id) const;

  /**
   * @brief Busca un miembro por email
   */
  [[nodiscard]] std::optional<Member> findByEmail(const QString &email) const;

  /**
   * @brief Obtiene todos los miembros
   */
  [[nodiscard]] std::vector<Member> findAll() const;

  /**
   * @brief Busca miembros por nombre o apellido
   */
  [[nodiscard]] std::vector<Member> search(const QString &query) const;

  /**
   * @brief Cuenta el total de miembros
   */
  [[nodiscard]] int count() const;

private:
  /**
   * @brief Mapea una fila de resultado SQL a un objeto Member
   */
  [[nodiscard]] Member mapRow(QSqlQuery &query) const;

  DatabaseManager &m_db;
};

} // namespace GymOS::Infrastructure::Repositories
