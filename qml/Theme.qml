pragma Singleton
import QtQuick 2.15

/**
 * GymOS Design System - Tema Global
 * 
 * Sistema de tokens de diseño para mantener consistencia visual
 * en toda la aplicación.
 */
QtObject {
    // ========================================================================
    // Dark Mode Toggle
    // ========================================================================
    property bool darkMode: false
    
    // ========================================================================
    // Colores Principales (Responsivos al tema)
    // ========================================================================
    
    // Fondos
    readonly property color background: darkMode ? "#121212" : "#f5f5f5"
    readonly property color surface: darkMode ? "#1e1e1e" : "#ffffff"
    readonly property color surfaceVariant: darkMode ? "#2a2a2a" : "#fafafa"
    
    // Texto
    readonly property color textPrimary: darkMode ? "#e0e0e0" : "#212121"
    readonly property color textSecondary: darkMode ? "#a0a0a0" : "#757575"
    readonly property color textDisabled: darkMode ? "#616161" : "#9e9e9e"
    readonly property color textOnPrimary: "#ffffff"
    
    // Colores de acento (ligeramente más vibrantes en modo oscuro)
    readonly property color primary: darkMode ? "#448aff" : "#2979ff"
    readonly property color primaryDark: darkMode ? "#2979ff" : "#1565c0"
    readonly property color primaryLight: darkMode ? "#82b1ff" : "#82b1ff"
    readonly property color success: darkMode ? "#69f0ae" : "#00c853"
    readonly property color successDark: darkMode ? "#00c853" : "#00a844"
    readonly property color error: darkMode ? "#ff5252" : "#d50000"
    readonly property color errorLight: darkMode ? "#ff8a80" : "#ff5252"
    readonly property color warning: darkMode ? "#ffb74d" : "#ff9800"
    readonly property color warningLight: darkMode ? "#ffd54f" : "#ffb74d"
    
    // Estados de suscripción
    readonly property color statusActive: darkMode ? "#69f0ae" : "#00c853"
    readonly property color statusExpiring: darkMode ? "#ffb74d" : "#ff9800"
    readonly property color statusExpired: darkMode ? "#ff5252" : "#d50000"
    
    // Bordes
    readonly property color border: darkMode ? "#424242" : "#e0e0e0"
    readonly property color borderFocus: darkMode ? "#448aff" : "#2979ff"
    
    // Iconos
    readonly property color iconColor: darkMode ? "#e0e0e0" : "#212121"
    readonly property color iconColorSecondary: darkMode ? "#a0a0a0" : "#757575"
    
    // ========================================================================
    // Tipografía
    // ========================================================================
    readonly property string fontFamily: "Roboto, Segoe UI, Open Sans, sans-serif"
    
    // Tamaños de fuente
    readonly property int fontSizeXS: 10
    readonly property int fontSizeS: 12
    readonly property int fontSizeM: 14
    readonly property int fontSizeL: 16
    readonly property int fontSizeXL: 20
    readonly property int fontSizeXXL: 24
    readonly property int fontSizeTitle: 32
    
    // Pesos de fuente
    readonly property int fontWeightLight: Font.Light
    readonly property int fontWeightNormal: Font.Normal
    readonly property int fontWeightMedium: Font.Medium
    readonly property int fontWeightBold: Font.Bold
    
    // Fuentes predefinidas (QtObject no puede tener propiedades de tipo font directamente en Singleton sin QtQuick invocado correctamente a veces, pero probaremos exposed/grouped properties o simplemente devolviendo objetos compatibles si fuera item. 
    // Mejor solución: Usar propiedades grouped o simplemente propiedades QtObject que se usen como fuente. 
    // Sin embargo, en QML estándar 'font' es un grupo.
    // Hack: Definir propiedades que devuelvan el objeto de fuente deseado no funciona directo en QtObject puro a veces.
    // Vamos a usar Qt.font() construction en propiedades var/variant.
    
    property font fontHeader: Qt.font({
        family: fontFamily,
        pixelSize: fontSizeL,
        weight: fontWeightBold
    })
    
    property font fontLabel: Qt.font({
        family: fontFamily,
        pixelSize: fontSizeS,
        weight: fontWeightMedium
    })
    
    // ========================================================================
    // Espaciado
    // ========================================================================
    readonly property int spacingXS: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 12
    readonly property int spacingL: 16
    readonly property int spacingXL: 24
    readonly property int spacingXXL: 32
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    
    // Bordes redondeados
    readonly property int radiusS: 4
    readonly property int radiusM: 6
    readonly property int radiusL: 8
    readonly property int radiusXL: 12
    readonly property int radiusRound: 9999
    
    // Sidebar
    readonly property int sidebarExpandedWidth: 220
    readonly property int sidebarCollapsedWidth: 64
    
    // Tarjetas de estadísticas
    readonly property int statCardHeight: 100
    readonly property int statCardMinWidth: 200
    
    // Campos de entrada
    readonly property int inputHeight: 40
    readonly property int buttonHeight: 40
    
    // ========================================================================
    // Sombras
    // ========================================================================
    // Performance Mode - Set to true on low-end PCs to disable shadows
    readonly property bool performanceMode: false
    readonly property bool enableShadows: !performanceMode
    
    readonly property real shadowOpacity: 0.1
    readonly property int shadowBlur: 6
    readonly property int shadowOffsetY: 2
    
    // ========================================================================
    // Animaciones
    // ========================================================================
    readonly property int animationDurationFast: 150
    readonly property int animationDurationNormal: 250
    readonly property int animationDurationSlow: 400
    
    // ========================================================================
    // Funciones de utilidad
    // ========================================================================
    
    /**
     * Devuelve el color de estado según el estado de suscripción
     */
    function getStatusColor(status) {
        switch(status) {
            case "active": return statusActive;
            case "expiring": return statusExpiring;
            case "expired": return statusExpired;
            default: return textSecondary;
        }
    }
    
    /**
     * Devuelve el texto de estado en español
     */
    function getStatusText(status) {
        switch(status) {
            case "active": return "Activo";
            case "expiring": return "Por Vencer";
            case "expired": return "Vencido";
            default: return "Desconocido";
        }
    }
    
    /**
     * Devuelve la ruta del ícono según el tema actual
     * @param iconName - nombre del ícono sin extensión (ej: "menu", "dashboard")
     */
    function getIcon(iconName) {
        var folder = darkMode ? "icons-light" : "icons"
        return "qrc:/assets/" + folder + "/" + iconName + ".svg"
    }
}
