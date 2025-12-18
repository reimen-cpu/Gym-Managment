# Gym Management System (GymOS) 🏋️‍♂️

Aplicación moderna de gestión de gimnasios construida con C++ (Qt) y QML. Diseñada para ser rápida, eficiente y totalmente portable.

## 🌟 Características Principales

- **Gestión de Miembros**: Registro completo, perfiles detallados, fotos.
- **Suscripciones Flexibles**: Planes por días, renovaciones personalizadas, tarifas de inscripción.
- **Panel Financiero**: Gráficos interactivos de ingresos/gastos, control de caja.
- **Arquitectura Robusta**: Backend en C++17, Frontend en QML (Qt 6.x), Base de datos SQLite.
- **Portable**: La base de datos viaja con el ejecutable.

## 🛠️ Requisitos de Compilación

- **Compilador**: MinGW 8.1.0+ (gcc/g++) o MSVC 2019+
- **Qt Framework**: Qt 6.2 o superior
- **CMake**: 3.16 o superior
- **Herramientas**: Ninja o Make

## 🚀 Instrucciones de Compilación (Portable)

Para generar una versión ejecutable y portable:

1.  **Configurar**:
    ```bash
    cmake -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
    ```

2.  **Compilar**:
    ```bash
    cmake --build build --config Release
    ```

3.  **Desplegar (Importante)**:
    Qt requiere que las DLLs estén junto al ejecutable. Usa `windeployqt`:
    ```bash
    # Ejemplo (ajusta la ruta a tu instalación de Qt)
    C:/Qt/6.x.x/mingw_64/bin/windeployqt.exe build/GymOS.exe --qmldir qml
    ```

4.  **Ejecutar**:
    Ve a la carpeta `build` (o donde esté el .exe) y ejecuta `GymOS.exe`.
    *Nota: La base de datos `gymos.db` se creará automáticamente en la misma carpeta que el ejecutable.*

## 📂 Estructura del Proyecto

*   `src/`: Código fuente C++ (Backend)
    *   `core/`: Lógica de negocio y modelos.
    *   `infrastructure/`: Base de datos y repositorios.
    *   `ui/`: Controladores que exponen la lógica a QML.
*   `qml/`: Interfaz de usuario (Frontend).
*   `assets/`: Iconos e imágenes.
*   `resources.qrc`: Sistema de recursos de Qt.

## 💾 Base de Datos

El sistema utiliza **SQLite**. En modo portable, el archivo `gymos.db` se almacena en el **directorio de trabajo del ejecutable** (habitualmente junto al `.exe`). Esto permite mover la carpeta completa del programa a otro PC o memoria USB sin perder datos.
