# 🏋️ GymOS - Sistema de Gestión de Gimnasios

<!-- Screenshots Gallery - Instagram Style Carousel -->
<div align="center">

<h3>📸 Vista Previa de la Aplicación</h3>

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214339.png?raw=true" width="400" alt="Dashboard"/>
      <br><sub><b>Dashboard</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214349.png?raw=true" width="400" alt="Suscripciones"/>
      <br><sub><b>Suscripciones</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214548.png?raw=true" width="400" alt="Nueva Suscripción"/>
      <br><sub><b>Nueva Suscripción</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214610.png?raw=true" width="400" alt="Gestión de Planes"/>
      <br><sub><b>Gestión de Planes</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214618.png?raw=true" width="400" alt="Finanzas"/>
      <br><sub><b>Finanzas</b></sub>
    </td>
    <td align="center">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214734.png?raw=true" width="400" alt="Gráficos"/>
      <br><sub><b>Gráficos</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <img src="https://github.com/reimen-cpu/Gym-Managment/blob/main/readme%20images/Captura%20de%20pantalla%202025-12-18%20214824.png?raw=true" width="400" alt="Modo Oscuro"/>
      <br><sub><b>Modo Oscuro</b></sub>
    </td>
  </tr>
</table>

</div>

---

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Qt](https://img.shields.io/badge/Qt-6.5+-green.svg)
![C++](https://img.shields.io/badge/C++-17-orange.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-purple.svg)

**Sistema moderno y portable para la gestión integral de gimnasios.**

[Características](#-características) • [Requisitos](#-requisitos) • [Instalación](#-instalación-rápida) • [Uso](#-guía-de-uso) • [Compilación](#%EF%B8%8F-compilación-desde-código-fuente) • [Soporte](#-soporte)

</div>

---

## 📋 Descripción

**GymOS** es una aplicación de escritorio diseñada para gestionar todas las operaciones de un gimnasio de manera eficiente. Construida con **C++17** y **Qt 6.5+**, ofrece una interfaz moderna y fluida mientras mantiene un alto rendimiento.

### ¿Por qué GymOS?

- ✅ **100% Portable**: Ejecuta desde cualquier carpeta o USB sin instalación
- ✅ **Sin conexión a internet**: Todos los datos se almacenan localmente
- ✅ **Interfaz intuitiva**: Diseño moderno con soporte para modo claro/oscuro
- ✅ **Datos seguros**: Base de datos SQLite integrada

---

## ✨ Características

### 📊 Panel de Control (Dashboard)
Vista general con métricas clave del gimnasio:
- Miembros activos y nuevas inscripciones
- Ingresos del mes actual
- Suscripciones próximas a vencer
- Gráficos interactivos de tendencias

### 👥 Gestión de Miembros
- Registro completo de socios con foto de perfil
- Búsqueda y filtrado avanzado
- Historial de suscripciones por miembro
- Edición y actualización de datos personales

### 📋 Planes y Tarifas
- Creación de planes personalizados (mensual, trimestral, anual, etc.)
- Configuración de duración en días
- Tarifas de inscripción opcionales
- Gestión de precios flexible

### 💳 Suscripciones
- Alta de nuevas suscripciones
- Renovación con un clic
- Control de fechas de inicio y vencimiento
- Indicadores visuales de estado (activo, vencido, por vencer)

### 💰 Módulo Financiero
- Registro detallado de ingresos y gastos
- Gráficos de barras y líneas interactivos
- Filtros por período (día, semana, mes, año)
- Balance y control de caja

---

## 💻 Requisitos

### Para Usuarios (Ejecutable Pre-compilado)
| Componente | Requisito |
|------------|-----------|
| **Sistema Operativo** | Windows 10 o superior (64-bit) |
| **RAM** | Mínimo 2 GB |
| **Espacio en disco** | 150 MB |

### Para Desarrolladores (Compilación)
| Componente | Versión Mínima |
|------------|----------------|
| **Qt Framework** | 6.5 o superior |
| **CMake** | 3.21 o superior |
| **Compilador** | MinGW 11.2+ / MSVC 2022+ |
| **Módulos Qt requeridos** | Core, Quick, QuickControls2, Sql, Charts, Qml |

---

## 🚀 Instalación Rápida

### Opción 1: Ejecutable Pre-compilado (Recomendado)

1. **Descarga** la última versión desde la carpeta `Build/`
2. **Extrae** el contenido en cualquier ubicación
3. **Ejecuta** `GymOS.exe`

> 💡 **Tip**: Puedes copiar toda la carpeta a una memoria USB para usarlo en cualquier PC.

### Opción 2: Desde Código Fuente

Consulta la sección [Compilación desde Código Fuente](#%EF%B8%8F-compilación-desde-código-fuente).

---

## 📖 Guía de Uso

### Primer Inicio

Al ejecutar GymOS por primera vez:

1. Se crea automáticamente la base de datos `gymos.db` en la misma carpeta del ejecutable
2. Se muestra el **Panel de Control** vacío, listo para agregar datos

### Flujo de Trabajo Típico

```
1. Crear Planes → 2. Registrar Miembros → 3. Asignar Suscripciones → 4. Gestionar Finanzas
```

### Navegación Principal

| Sección | Función | Acceso |
|---------|---------|--------|
| **Dashboard** | Vista general y estadísticas | Barra lateral izquierda |
| **Suscripciones** | Ver y gestionar suscripciones activas | Barra lateral izquierda |
| **Nueva Suscripción** | Registrar nuevo miembro o renovar | Barra lateral izquierda |
| **Planes** | Configurar tipos de membresías | Barra lateral izquierda |
| **Finanzas** | Control de ingresos y gastos | Barra lateral izquierda |

### Operaciones Comunes

#### ➕ Registrar un Nuevo Miembro
1. Ve a **"Nueva Suscripción"** desde la barra lateral
2. Completa los datos personales (nombre, teléfono, email, etc.)
3. Opcionalmente agrega una foto haciendo clic en el área de imagen
4. Selecciona un plan de suscripción
5. Confirma la fecha de inicio
6. Haz clic en **"Guardar"**

#### 🔄 Renovar una Suscripción
1. Ve a **"Suscripciones"**
2. Busca al miembro usando la barra de búsqueda
3. Haz clic en el botón de renovación (🔄)
4. Confirma la renovación

#### � Registrar un Ingreso/Gasto
1. Ve a **"Finanzas"**
2. Haz clic en **"Nuevo Registro"**
3. Selecciona el tipo (Ingreso o Gasto)
4. Completa el monto y descripción
5. Guarda el registro

---

## 🛠️ Compilación desde Código Fuente

### Paso 1: Preparar el Entorno

Asegúrate de tener instalado:
- [Qt 6.5+](https://www.qt.io/download) con los módulos: Core, Quick, QuickControls2, Sql, Charts, Qml
- [CMake 3.21+](https://cmake.org/download/)
- Un compilador compatible (MinGW o MSVC)

### Paso 2: Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd Gym-Managment
```

### Paso 3: Configurar el Proyecto

**Con MinGW:**
```bash
cmake -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/mingw_64"
```

**Con MSVC (Visual Studio):**
```bash
cmake -B build -G "Visual Studio 17 2022" -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"
```

> ⚠️ **Importante**: Reemplaza `C:/Qt/6.x.x/...` con la ruta real de tu instalación de Qt.

### Paso 4: Compilar

```bash
cmake --build build --config Release
```

### Paso 5: Desplegar Dependencias

Copia las DLLs de Qt necesarias usando `windeployqt`:

```bash
# Ajusta la ruta según tu instalación de Qt
C:/Qt/6.x.x/mingw_64/bin/windeployqt.exe build/GymOS.exe --qmldir qml
```

### Paso 6: Ejecutar

```bash
cd build
./GymOS.exe
```

---

## 📂 Estructura del Proyecto

```
Gym-Managment/
├── 📁 src/                    # Código fuente C++
│   ├── 📁 core/
│   │   ├── 📁 models/         # Modelos de datos (Member, Plan, Subscription, etc.)
│   │   └── 📁 services/       # Lógica de negocio (SubscriptionManager, FinanceEngine)
│   ├── 📁 infrastructure/
│   │   ├── 📁 database/       # Gestión de conexión SQLite
│   │   └── 📁 repositories/   # Acceso a datos (CRUD)
│   └── 📁 ui/
│       └── 📁 controllers/    # Controladores expuestos a QML
├── 📁 qml/                    # Interfaz de usuario
│   ├── Main.qml               # Ventana principal
│   ├── Theme.qml              # Sistema de temas (claro/oscuro)
│   ├── 📁 views/              # Pantallas principales
│   └── 📁 components/         # Componentes reutilizables
├── 📁 assets/                 # Recursos gráficos
│   ├── 📁 icons/              # Iconos (modo oscuro)
│   └── 📁 icons-light/        # Iconos (modo claro)
├── 📁 Build/                  # Ejecutable pre-compilado
├── CMakeLists.txt             # Configuración de compilación
├── resources.qrc              # Recursos embebidos de Qt
└── seed_data.sql              # Datos de ejemplo para desarrollo
```

---

## 💾 Base de Datos

GymOS utiliza **SQLite** como motor de base de datos, lo que garantiza:

- **Portabilidad**: El archivo `gymos.db` se guarda junto al ejecutable
- **Sin configuración**: No requiere servidor ni instalación adicional
- **Respaldos fáciles**: Solo copia el archivo `.db` para hacer backup

### Ubicación del Archivo

| Modo | Ubicación |
|------|-----------|
| **Portable** | Misma carpeta que `GymOS.exe` |
| **Desarrollo** | Directorio de trabajo del proyecto |

### Respaldo de Datos

Para respaldar tus datos, simplemente copia el archivo `gymos.db` a otro lugar seguro.

---

## ❓ Solución de Problemas

### La aplicación no inicia

1. **Verifica** que todas las DLLs estén en la misma carpeta que el ejecutable
2. **Ejecuta** `windeployqt` nuevamente si compilaste desde el código fuente
3. **Comprueba** que tienes los Visual C++ Redistributables instalados

### "No se puede encontrar la base de datos"

- Asegúrate de tener **permisos de escritura** en la carpeta donde está el ejecutable
- Evita ejecutar desde rutas protegidas del sistema (como `C:\Program Files`)

### La interfaz se ve incorrectamente

- Verifica que tu versión de Qt incluye el módulo **QuickControls2**
- Actualiza los drivers de tu tarjeta gráfica

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si deseas mejorar GymOS:

1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Realiza tus cambios y haz commit (`git commit -m 'Añade nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📞 Soporte

Si encuentras algún problema o tienes sugerencias:

- 🐛 **Reporta bugs**: Abre un issue en el repositorio
- 💡 **Sugerencias**: Abre un issue con la etiqueta "enhancement"
- 📧 **Contacto**: [Incluir email de contacto si aplica]

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

<div align="center">

**Desarrollado con ❤️ usando Qt y C++**

</div>
