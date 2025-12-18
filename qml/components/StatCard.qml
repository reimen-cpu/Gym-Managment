import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."

/**
 * StatCard - Tarjeta de Estadísticas
 * 
 * Componente para mostrar métricas en el dashboard.
 * Presenta un valor numérico con título y color de acento opcional.
 */
Rectangle {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property string title: "Título"
    property string value: "0"
    property string subtitle: ""
    property color accentColor: Theme.primary
    property string iconSource: ""
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    implicitWidth: Theme.statCardMinWidth
    implicitHeight: Theme.statCardHeight
    
    color: Theme.surface
    radius: Theme.radiusL
    
    // Sombra
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, Theme.shadowOpacity)
        shadowBlur: Theme.shadowBlur
        shadowVerticalOffset: Theme.shadowOffsetY
    }
    
    // ========================================================================
    // Contenido
    // ========================================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM
        
        // Indicador de color
        Rectangle {
            Layout.preferredWidth: 4
            Layout.fillHeight: true
            radius: 2
            color: accentColor
        }
        
        // Icono (opcional)
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: Theme.radiusM
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1)
            visible: iconSource !== ""
            
            Image {
                anchors.centerIn: parent
                source: iconSource
                width: 24
                height: 24
                sourceSize: Qt.size(24, 24)
            }
        }
        
        // Texto
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingXS
            
            Text {
                Layout.fillWidth: true
                text: title
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeS
                font.weight: Theme.fontWeightMedium
                color: Theme.textSecondary
                elide: Text.ElideRight
            }
            
            Text {
                Layout.fillWidth: true
                text: value
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXXL
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
                elide: Text.ElideRight
            }
            
            Text {
                Layout.fillWidth: true
                text: subtitle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXS
                color: Theme.textSecondary
                elide: Text.ElideRight
                visible: subtitle !== ""
            }
        }
    }
    
    // ========================================================================
    // Animación de Hover
    // ========================================================================
    signal clicked()

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: root.clicked()

        onEntered: {
            hoverAnimation.to = Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 1)
            hoverAnimation.start()
        }
        onExited: {
            hoverAnimation.to = Theme.surface
            hoverAnimation.start()
        }
    }
    
    ColorAnimation {
        id: hoverAnimation
        target: root
        property: "color"
        duration: Theme.animationDurationFast
    }
}
