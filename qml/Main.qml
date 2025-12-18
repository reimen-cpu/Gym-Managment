import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "."  // Para Theme singleton
import "components"
import "views"

/**
 * GymOS - Ventana Principal
 * 
 * Estructura de la aplicación con sidebar colapsable a la derecha
 * y StackLayout para las vistas.
 */
ApplicationWindow {
    id: mainWindow
    
    width: 1280
    height: 800
    minimumWidth: 1024
    minimumHeight: 600
    visible: true
    title: qsTr("GymOS - Gestión de Gimnasio")
    color: Theme.background
    
    // ========================================================================
    // Propiedades de Estado
    // ========================================================================
    property int currentViewIndex: 0
    property bool sidebarExpanded: true
    
    // ========================================================================
    // Layout Principal
    // ========================================================================
    // Layout Principal - Using Item with anchors for fixed sidebar positioning
    Item {
        anchors.fill: parent
        
        // Main Content Area
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: sidebar.left
            color: Theme.background
            
            StackLayout {
                id: viewStack
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                currentIndex: currentViewIndex
                
                // Smooth transition between views
                property int previousIndex: 0
                
                onCurrentIndexChanged: {
                    // Fade transition
                    if (currentIndex !== previousIndex) {
                        fadeTransition.restart()
                        previousIndex = currentIndex
                    }
                }
                
                // Subtle fade effect
                opacity: 1.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
                
                NumberAnimation {
                    id: fadeTransition
                    target: viewStack
                    property: "opacity"
                    from: 0.95
                    to: 1.0
                    duration: 150
                    easing.type: Easing.OutQuad
                }
                
                // Vista 0: Dashboard (Home)
                DashboardView {
                    id: dashboardView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onNavigationRequested: function(viewName, filterParam) {
                        if (viewName === "subscriptions") {
                            console.log("[Main.qml] Navigation requested to subscriptions with filter:", filterParam)
                            currentViewIndex = 3
                            subscriptionsView.setFilter(filterParam)
                        }
                    }
                }
                
                // Vista 1: Nuevos Suscriptores
                NewSubscriberView {
                    id: newSubscriberView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                
                // Vista 2: Planes de Pago
                PlansView {
                    id: plansView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                
                // Vista 3: Suscripciones Activas
                SubscriptionsView {
                    id: subscriptionsView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                
                // Vista 4: Finanzas
                FinanceView {
                    id: financeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
        
        // Sidebar (anchored to right edge)
        CollapsibleSidebar {
            id: sidebar
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            expanded: sidebarExpanded
            currentIndex: currentViewIndex
            
            onNavigationRequested: function(index) {
                console.log("[Main.qml] Sidebar navigation requested, changing from", currentViewIndex, "to", index)
                currentViewIndex = index
                // Force immediate visual update
                viewStack.currentIndex = index
                // Trigger repaint timer for Wine compatibility
                repaintTimer.restart()
            }
            
            onToggleRequested: {
                sidebarExpanded = !sidebarExpanded
            }
        }
    }
    
    // Monitor currentViewIndex changes and force repaint
    onCurrentViewIndexChanged: {
        console.log("[Main.qml] currentViewIndex property changed to:", currentViewIndex)
        // Use gentle repaint for Wine compatibility
        Qt.callLater(forceRepaint)
    }
    
    // Gentle repaint function - smoother for Wine
    function forceRepaint() {
        // Only use requestUpdate - smoothest method
        mainWindow.requestUpdate()
        
        // Backup: Trigger timer for delayed update if needed
        repaintTimer.restart()
    }
    
    // Delayed repaint timer - ensures update completes
    Timer {
        id: repaintTimer
        interval: 50 // Reduced from 100ms for faster response
        running: false
        repeat: false
        onTriggered: {
            mainWindow.requestUpdate()
        }
    }
    
    // ========================================================================
    // Atajos de Teclado
    // ========================================================================
    Shortcut {
        sequence: "Ctrl+1"
        onActivated: currentViewIndex = 0
    }
    Shortcut {
        sequence: "Ctrl+2"
        onActivated: currentViewIndex = 1
    }
    Shortcut {
        sequence: "Ctrl+3"
        onActivated: currentViewIndex = 2
    }
    Shortcut {
        sequence: "Ctrl+4"
        onActivated: currentViewIndex = 3
    }
    Shortcut {
        sequence: "Ctrl+5"
        onActivated: currentViewIndex = 4
    }
    Shortcut {
        sequence: "Ctrl+B"
        onActivated: sidebarExpanded = !sidebarExpanded
    }
}
