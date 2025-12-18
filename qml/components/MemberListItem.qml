import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."

/**
 * MemberListItem - Elemento de Lista de Miembros
 * 
 * Componente para mostrar información resumida de un miembro
 * con estado de suscripción visual.
 */
Rectangle {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property string memberName: "Nombre del Miembro"
    property string planName: "Plan Mensual"
    property string startDate: "01/01/2024"
    property string endDate: "01/02/2024"
    property string status: "active"  // active, expiring, expired
    property int daysUntilExpiry: 30
    
    // ========================================================================
    // Señales
    // ========================================================================
    signal clicked()
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    implicitHeight: 72
    
    color: mouseArea.containsMouse ? Theme.surfaceVariant : Theme.surface
    radius: Theme.radiusM
    scale: mouseArea.containsMouse ? 1.01 : 1.0
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }
    
    // ========================================================================
    // Contenido
    // ========================================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingM
        
        // Avatar / Iniciales
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: Theme.radiusRound
            color: Theme.getStatusColor(status)
            opacity: 0.15
            
            Text {
                anchors.centerIn: parent
                text: getInitials(memberName)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeL
                font.weight: Theme.fontWeightBold
                color: Theme.getStatusColor(status)
            }
        }
        
        // Información del miembro
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingXS
            
            // Nombre
            Text {
                Layout.fillWidth: true
                text: memberName
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeM
                font.weight: Theme.fontWeightMedium
                color: Theme.textPrimary
                elide: Text.ElideRight
            }
            
            // Plan y fechas
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS
                
                Text {
                    text: planName
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.textSecondary
                }
                
                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    color: Theme.textDisabled
                }
                
                Text {
                    text: startDate + " → " + endDate
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.textSecondary
                }
            }
        }
        
        // Badge de estado
        Rectangle {
            Layout.preferredWidth: statusText.width + Theme.spacingM * 2
            Layout.preferredHeight: 28
            radius: Theme.radiusRound
            color: Qt.rgba(
                Theme.getStatusColor(status).r,
                Theme.getStatusColor(status).g,
                Theme.getStatusColor(status).b,
                0.1
            )
            
            Text {
                id: statusText
                anchors.centerIn: parent
                text: getStatusLabel()
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXS
                font.weight: Theme.fontWeightMedium
                color: Theme.getStatusColor(status)
            }
        }
        
        // Días restantes
        ColumnLayout {
            Layout.preferredWidth: 60
            spacing: 2
            visible: status !== "expired"
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Math.abs(daysUntilExpiry).toString()
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXL
                font.weight: Theme.fontWeightBold
                color: Theme.getStatusColor(status)
            }
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: daysUntilExpiry === 1 ? "día" : "días"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXS
                color: Theme.textSecondary
            }
        }
        
        // Flecha de navegación
        Text {
            text: "›"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXL
            color: Theme.textDisabled
        }
    }
    
    // ========================================================================
    // Interacción
    // ========================================================================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    
    // ========================================================================
    // Funciones Helper
    // ========================================================================
    function getInitials(name) {
        var parts = name.split(" ")
        if (parts.length >= 2) {
            return parts[0].charAt(0).toUpperCase() + parts[1].charAt(0).toUpperCase()
        }
        return name.substring(0, 2).toUpperCase()
    }
    
    function getStatusLabel() {
        switch(status) {
            case "active": return "Activo"
            case "expiring": return "Por Vencer"
            case "expired": return "Vencido"
            default: return "Desconocido"
        }
    }
}
