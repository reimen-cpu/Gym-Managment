import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."

/**
 * Sidebar Colapsable
 * 
 * Barra de navegación lateral derecha con capacidad de expandir/colapsar.
 * Muestra iconos cuando está colapsada, iconos + texto cuando está expandida.
 */
Rectangle {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property bool expanded: true
    property int currentIndex: 0
    
    // Monitor currentIndex changes
    onCurrentIndexChanged: {
        console.log("[CollapsibleSidebar] currentIndex changed to:", currentIndex)
    }
    
    // ========================================================================
    // Señales
    // ========================================================================
    signal navigationRequested(int index)
    signal toggleRequested()
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    width: expanded ? Theme.sidebarExpandedWidth : Theme.sidebarCollapsedWidth
    color: Theme.surface
    clip: true // Ensure content is clipped when collapsing
    
    // Sombra izquierda
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.border
    }
    
    // Animación de ancho
    Behavior on width {
        NumberAnimation {
            duration: Theme.animationDurationNormal
            easing.type: Easing.OutCubic
        }
    }
    
    // ========================================================================
    // Contenido
    // ========================================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingS
        spacing: Theme.spacingS
        
        // Botón de toggle (hamburguesa)
        RowLayout {
            Layout.fillWidth: true
            layoutDirection: Qt.RightToLeft // Force RTL for the header too
            
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                color: toggleArea.containsMouse ? Theme.background : "transparent"
                radius: Theme.radiusM
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationDurationFast }
                }
                
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/assets/icons/menu.svg"
                    width: 24
                    height: 24
                    sourceSize: Qt.size(24, 24)
                }
                
                MouseArea {
                    id: toggleArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleRequested()
                }
            }
            
            Item { Layout.fillWidth: true } // Spacer to push toggle properly if needed (though RTL puts first item on right)
        }
        
        // Separador
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.border
        }
        
        // Elementos de navegación
        Repeater {
            // ... (Model unchanged)
            model: ListModel {
                ListElement { 
                    title: "Inicio"
                    icon: "qrc:/assets/icons/dashboard.svg"
                    viewIndex: 0
                }
                ListElement { 
                    title: "Nuevo Suscriptor"
                    icon: "qrc:/assets/icons/members.svg"
                    viewIndex: 1
                }
                ListElement { 
                    title: "Planes de Pago"
                    icon: "qrc:/assets/icons/plans.svg"
                    viewIndex: 2
                }
                ListElement { 
                    title: "Suscripciones"
                    icon: "qrc:/assets/icons/subscriptions.svg"
                    viewIndex: 3
                }
                ListElement { 
                    title: "Finanzas"
                    icon: "qrc:/assets/icons/finance.svg"
                    viewIndex: 4
                }
            }
            
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                color: {
                    if (currentIndex === model.viewIndex) {
                        return Theme.primaryLight
                    } else if (navMouseArea.containsMouse) {
                        return Theme.background
                    }
                    return "transparent"
                }
                radius: Theme.radiusM
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationDurationFast }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingM
                    anchors.rightMargin: Theme.spacingM
                    spacing: Theme.spacingM
                    layoutDirection: Qt.RightToLeft // Icons on Right, Text on Left
                    
                    Image {
                        source: model.icon
                        width: 24
                        height: 24
                        sourceSize: Qt.size(24, 24)
                        opacity: currentIndex === model.viewIndex ? 1.0 : 0.7
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: model.title
                        horizontalAlignment: Text.AlignRight // Align text to the icon (Right)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeM
                        font.weight: currentIndex === model.viewIndex ? 
                            Theme.fontWeightMedium : Theme.fontWeightNormal
                        color: currentIndex === model.viewIndex ? 
                            Theme.primary : Theme.textPrimary
                        elide: Text.ElideRight
                        visible: expanded
                        opacity: expanded ? 1.0 : 0.0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: Theme.animationDurationFast }
                        }
                    }
                }
                
                MouseArea {
                    id: navMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("[CollapsibleSidebar] Navigation item clicked, viewIndex:", model.viewIndex, "title:", model.title)
                        root.navigationRequested(model.viewIndex)
                    }
                }
                
                // Indicador de selección
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: parent.height - Theme.spacingM
                    radius: 2
                    color: Theme.primary
                    visible: currentIndex === model.viewIndex
                }
            }
        }
        
        // Espaciador
        Item {
            Layout.fillHeight: true
        }
        
        // Información de versión (al fondo)
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: expanded ? "GymOS v1.0.0" : "v1.0"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXS
            color: Theme.textSecondary
            opacity: 0.6
        }
    }
}
