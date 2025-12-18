import QtQuick 2.15
import QtQuick.Controls 2.15
import ".."

/**
 * GymButton - Botón Personalizado
 * 
 * Botón estilizado con variantes: primary, success, danger, outline.
 */
Button {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property string variant: "primary"  // primary, success, danger, outline
    property string iconSource: ""
    property bool loading: false
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    implicitHeight: Theme.buttonHeight
    leftPadding: iconSource !== "" ? Theme.spacingM : Theme.spacingL
    rightPadding: Theme.spacingL
    
    // ========================================================================
    // Colores según variante
    // ========================================================================
    readonly property color bgColor: {
        if (!enabled) return Theme.border
        switch(variant) {
            case "success": return Theme.success
            case "danger": return Theme.error
            case "outline": return "transparent"
            default: return Theme.primary
        }
    }
    
    readonly property color bgColorHover: {
        if (!enabled) return Theme.border
        switch(variant) {
            case "success": return Theme.successDark
            case "danger": return Theme.errorLight
            case "outline": return Theme.background
            default: return Theme.primaryDark
        }
    }
    
    readonly property color textColor: {
        if (!enabled) return Theme.textDisabled
        switch(variant) {
            case "outline": return Theme.primary
            default: return Theme.textOnPrimary
        }
    }
    
    readonly property color borderColor: {
        switch(variant) {
            case "outline": return Theme.primary
            default: return "transparent"
        }
    }
    
    // ========================================================================
    // Background
    // ========================================================================
    background: Rectangle {
        color: root.hovered ? bgColorHover : bgColor
        radius: Theme.radiusM
        border.width: variant === "outline" ? 1 : 0
        border.color: borderColor
        
        Behavior on color {
            ColorAnimation { duration: Theme.animationDurationFast }
        }
    }
    
    // ========================================================================
    // Content
    // ========================================================================
    contentItem: Row {
        spacing: Theme.spacingS
        
        // Icono de loading
        Item {
            width: 20
            height: 20
            visible: loading
            
            Rectangle {
                id: loadingSpinner
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: 8
                color: "transparent"
                border.width: 2
                border.color: textColor
                opacity: 0.3
            }
            
            Rectangle {
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: 8
                color: "transparent"
                border.width: 2
                border.color: textColor
                
                // Arco parcial (simulado con clip)
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: root.bgColor
                    anchors.right: parent.right
                }
                
                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: loading
                }
            }
        }
        
        // Icono
        Image {
            source: iconSource
            width: 20
            height: 20
            sourceSize: Qt.size(20, 20)
            visible: iconSource !== "" && !loading
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Texto
        Text {
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeM
            font.weight: Theme.fontWeightMedium
            color: textColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // ========================================================================
    // Cursor
    // ========================================================================
    MouseArea {
        anchors.fill: parent
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        acceptedButtons: Qt.NoButton
    }
}
