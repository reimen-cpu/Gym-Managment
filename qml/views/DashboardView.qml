import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."
import "../components"

/**
 * DashboardView - Vista Principal (Home)
 * 
 * Muestra estadísticas generales y lista de suscripciones próximas a vencer.
 */
Item {
    id: root
    
    // ========================================================================
    // Conexión con Controller (se inyectará desde C++)
    // ========================================================================
    // property var controller: dashboardController
    
    // ========================================================================
    // Datos de ejemplo (serán reemplazados por el controller)
    // ========================================================================
    // Datos vinculados al controlador
    property int activeMembers: typeof gymController !== 'undefined' ? gymController.activeSubscriptionsCount : 0
    property int inactiveMembers: typeof gymController !== 'undefined' ? (gymController.totalMembers - gymController.activeSubscriptionsCount) : 0
    property int expiringMembers: typeof gymController !== 'undefined' ? gymController.expiringSubscriptionsCount : 0
    
    // Lista de suscripciones próximas a vencer
    property var expiringList: []
    
    Connections {
        target: typeof gymController !== 'undefined' ? gymController : null
        function onSubscriptionsChanged() {
            expiringList = gymController.expiringSubscriptions
            activeMembers = gymController.activeSubscriptionsCount
            inactiveMembers = gymController.totalMembers - gymController.activeSubscriptionsCount
            expiringMembers = gymController.expiringSubscriptionsCount
        }
        function onMembersChanged() {
            inactiveMembers = gymController.totalMembers - gymController.activeSubscriptionsCount
        }
    }
    
    Component.onCompleted: {
        if (typeof gymController !== 'undefined') {
            refreshData()
        }
    }
    
    function refreshData() {
        expiringList = gymController.expiringSubscriptions
        activeMembers = gymController.activeSubscriptionsCount
        inactiveMembers = gymController.totalMembers - gymController.activeSubscriptionsCount
        expiringMembers = gymController.expiringSubscriptionsCount
    }
    
    // ========================================================================
    // Layout Principal
    // ========================================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingXL
        
        // Encabezado
        RowLayout {
            Layout.fillWidth: true
            
            ColumnLayout {
                spacing: Theme.spacingXS
                
                Text {
                    text: "Panel de Control"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }
                
                Text {
                    text: "Resumen general del gimnasio"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: Theme.textSecondary
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // Fecha actual
            Text {
                text: Qt.formatDate(new Date(), "dddd, d 'de' MMMM yyyy")
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeM
                color: Theme.textSecondary
            }
        }
        
        // Tarjetas de Estadísticas
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingL
            
            StatCard {
                Layout.fillWidth: true
                title: "MIEMBROS ACTIVOS"
                value: activeMembers.toString()
                subtitle: "Con suscripción vigente"
                accentColor: Theme.success
                iconSource: "qrc:/assets/icons/members.svg"
            }
            
            StatCard {
                Layout.fillWidth: true
                title: "MIEMBROS INACTIVOS"
                value: inactiveMembers.toString()
                subtitle: "Sin suscripción activa"
                accentColor: Theme.error
                iconSource: "qrc:/assets/icons/members.svg"
            }
            
            StatCard {
                Layout.fillWidth: true
                title: "POR VENCER"
                value: expiringMembers.toString()
                subtitle: "En los próximos 7 días"
                accentColor: Theme.warning
                iconSource: "qrc:/assets/icons/subscriptions.svg"
            }
        }
        
        // Lista de Próximos a Vencer
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.surface
            radius: Theme.radiusL
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, Theme.shadowOpacity)
                shadowBlur: Theme.shadowBlur
                shadowVerticalOffset: Theme.shadowOffsetY
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM
                
                // Encabezado de la lista
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Suscripciones Próximas a Vencer"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeL
                        font.weight: Theme.fontWeightMedium
                        color: Theme.textPrimary
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "Ordenado por fecha de vencimiento"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeS
                        color: Theme.textSecondary
                    }
                }
                
                // Separador
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.border
                }
                
                // Lista
                ListView {
                    id: expiringListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Theme.spacingS
                    
                    model: expiringList
                    
                    delegate: MemberListItem {
                        width: expiringListView.width
                        memberName: modelData.name
                        planName: modelData.plan
                        startDate: modelData.startDate
                        endDate: modelData.endDate
                        status: modelData.status
                        daysUntilExpiry: modelData.daysLeft
                        
                        onClicked: {
                            console.log("Miembro seleccionado:", modelData.name)
                            // TODO: Abrir perfil del miembro
                        }
                    }
                    
                    // Mensaje cuando no hay datos
                    Text {
                        anchors.centerIn: parent
                        text: "No hay suscripciones próximas a vencer"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeM
                        color: Theme.textSecondary
                        visible: expiringListView.count === 0
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
    }
}
