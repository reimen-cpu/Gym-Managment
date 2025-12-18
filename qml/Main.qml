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
                
                // Vista 0: Dashboard (Home)
                DashboardView {
                    id: dashboardView
                    onNavigationRequested: function(viewName, filterParam) {
                        if (viewName === "subscriptions") {
                            currentViewIndex = 3
                            subscriptionsView.setFilter(filterParam)
                        }
                    }
                }
                
                // Vista 1: Nuevos Suscriptores
                NewSubscriberView {
                    id: newSubscriberView
                }
                
                // Vista 2: Planes de Pago
                PlansView {
                    id: plansView
                }
                
                // Vista 3: Suscripciones Activas
                SubscriptionsView {
                    id: subscriptionsView
                }
                
                // Vista 4: Finanzas
                FinanceView {
                    id: financeView
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
                currentViewIndex = index
            }
            
            onToggleRequested: {
                sidebarExpanded = !sidebarExpanded
            }
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
