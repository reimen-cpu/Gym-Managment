#!/bin/bash
# GymOS Wine Launch Script
# This script sets Qt environment variables to fix rendering issues in Wine

echo "=== GymOS Wine Launcher ==="
echo "Setting Qt environment for Wine compatibility..."

# Force software rendering (more compatible with Wine)
export QT_QUICK_BACKEND=software

# Alternative: Use OpenGL if software is too slow
# export QT_QUICK_BACKEND=opengl

# Force immediate updates
export QSG_RENDER_LOOP=basic

# Disable threaded rendering (can cause issues in Wine)
export QSG_THREADED_RENDER_LOOP=0

# Enable debug output
export QT_LOGGING_RULES="qt.qml.binding=true"

# Disable vsync (can cause lag in Wine)
export QT_XCB_GL_INTEGRATION=none

echo "Qt Backend: $QT_QUICK_BACKEND"
echo "Render Loop: $QSG_RENDER_LOOP"
echo ""
echo "Starting GymOS..."

# Run the application
./GymOS.exe "$@"
