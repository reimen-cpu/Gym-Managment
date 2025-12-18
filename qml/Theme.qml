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
    // Colores Principales
    // ========================================================================
    
    // Fondos
    readonly property color background: "#f5f5f5"        // Fondo principal (gris claro)
    readonly property color surface: "#ffffff"           // Paneles y contenedores
    readonly property color surfaceVariant: "#fafafa"    // Variante de superficie
    
    // Texto
    readonly property color textPrimary: "#212121"       // Texto principal
    readonly property color textSecondary: "#757575"     // Texto secundario / etiquetas
    readonly property color textDisabled: "#9e9e9e"      // Texto deshabilitado
    readonly property color textOnPrimary: "#ffffff"     // Texto sobre color primario
    
    // Acentos
    readonly property color primary: "#2979ff"           // Azul fuerte - botones principales
    readonly property color primaryDark: "#1565c0"       // Azul oscuro - hover
    readonly property color primaryLight: "#82b1ff"      // Azul claro
    readonly property color success: "#00c853"           // Verde - confirmaciones
    readonly property color successDark: "#00a844"       // Verde oscuro - hover
    readonly property color error: "#d50000"             // Rojo - errores / alertas
    readonly property color errorLight: "#ff5252"        // Rojo claro
    readonly property color warning: "#ff9800"           // Naranja - advertencias
    readonly property color warningLight: "#ffb74d"      // Naranja claro
    
    // Estados de suscripción
    readonly property color statusActive: "#00c853"      // Activo
    readonly property color statusExpiring: "#ff9800"    // Por vencer
    readonly property color statusExpired: "#d50000"     // Vencido
    
    // Bordes
    readonly property color border: "#e0e0e0"            // Borde normal
    readonly property color borderFocus: "#2979ff"       // Borde con foco
    
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
}
