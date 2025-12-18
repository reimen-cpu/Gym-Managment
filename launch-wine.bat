@echo off
REM GymOS Wine Launch Script (Windows Batch)
REM This script sets Qt environment variables to fix rendering issues in Wine

echo === GymOS Wine Launcher ===
echo Setting Qt environment for Wine compatibility...

REM Force software rendering (more compatible with Wine)
set QT_QUICK_BACKEND=software

REM Alternative: Use OpenGL if software is too slow
REM set QT_QUICK_BACKEND=opengl

REM Force immediate updates
set QSG_RENDER_LOOP=basic

REM Disable threaded rendering (can cause issues in Wine)
set QSG_THREADED_RENDER_LOOP=0

REM Enable debug output
set QT_LOGGING_RULES=qt.qml.binding=true

REM Disable vsync (can cause lag in Wine)
set QT_XCB_GL_INTEGRATION=none

echo Qt Backend: %QT_QUICK_BACKEND%
echo Render Loop: %QSG_RENDER_LOOP%
echo.
echo Starting GymOS...

REM Run the application
GymOS.exe %*
