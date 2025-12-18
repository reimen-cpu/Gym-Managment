import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."
import "../components"

/**
 * SubscriptionsView - Vista de Suscripciones Activas
 * 
 * Lista todas las suscripciones con filtros y búsqueda.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades de Estado
    // ========================================================================
    property string searchQuery: ""
    property string statusFilter: "all"  // all, active, expiring, expired
    property int selectedMemberId: -1
    
    // Lista de suscripciones (será cargada desde el controller)
    // Lista de suscripciones (vinculada al controller)
    property var subscriptions: typeof gymController !== 'undefined' ? gymController.allSubscriptions : []
    
    Connections {
        target: typeof gymController !== 'undefined' ? gymController : null
        function onSubscriptionsChanged() {
            root.subscriptions = gymController.allSubscriptions
        }
    }
    
    Component.onCompleted: {
        if (typeof gymController !== 'undefined') {
            root.subscriptions = gymController.allSubscriptions
        }
    }

    function setFilter(filter) {
        statusFilter = filter
    }
    
    // Suscripciones filtradas
    readonly property var filteredSubscriptions: {
        var result = []
        for (var i = 0; i < subscriptions.length; i++) {
            var sub = subscriptions[i]
            
            // Filtrar por estado
            if (statusFilter !== "all" && sub.status !== statusFilter) continue
            
            // Filtrar por búsqueda
            if (searchQuery !== "" && 
                sub.name.toLowerCase().indexOf(searchQuery.toLowerCase()) < 0 &&
                sub.plan.toLowerCase().indexOf(searchQuery.toLowerCase()) < 0) continue
            
            result.push(sub)
        }
        return result
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
                    text: "Suscripciones"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }
                
                Text {
                    text: filteredSubscriptions.length + " suscripciones encontradas"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: Theme.textSecondary
                }
            }
        }
        
        // Barra de filtros
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 56
            color: Theme.surface
            radius: Theme.radiusL
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, Theme.shadowOpacity)
                shadowBlur: Theme.shadowBlur
                shadowVerticalOffset: Theme.shadowOffsetY
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM
                
                // Campo de búsqueda
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true
                    color: Theme.background
                    radius: Theme.radiusM
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingS
                        
                        Image {
                            source: "qrc:/assets/icons/search.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                            opacity: 0.5
                        }
                        
                        TextInput {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeM
                            color: Theme.textPrimary
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            
                            onTextChanged: searchQuery = text
                            
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "Buscar por nombre o plan..."
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeM
                                color: Theme.textDisabled
                                visible: parent.text === ""
                            }
                        }
                    }
                }
                
                // Separador
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    Layout.topMargin: Theme.spacingS
                    Layout.bottomMargin: Theme.spacingS
                    color: Theme.border
                }
                
                // Filtros de estado
                Repeater {
                    model: [
                        { value: "all", label: "Todos", color: Theme.textSecondary },
                        { value: "active", label: "Activos", color: Theme.success },
                        { value: "expiring", label: "Por Vencer", color: Theme.warning },
                        { value: "expired", label: "Vencidos", color: Theme.error }
                    ]
                    
                    delegate: Rectangle {
                        Layout.preferredHeight: 36
                        implicitWidth: filterText.width + Theme.spacingL * 2
                        color: statusFilter === modelData.value ? 
                            Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.1) :
                            (filterMouseArea.containsMouse ? Theme.background : "transparent")
                        radius: Theme.radiusRound
                        border.width: statusFilter === modelData.value ? 1 : 0
                        border.color: modelData.color
                        
                        Behavior on color {
                            ColorAnimation { duration: Theme.animationDurationFast }
                        }
                        
                        Text {
                            id: filterText
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeS
                            font.weight: statusFilter === modelData.value ? 
                                Theme.fontWeightMedium : Theme.fontWeightNormal
                            color: statusFilter === modelData.value ? 
                                modelData.color : Theme.textSecondary
                        }
                        
                        MouseArea {
                            id: filterMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: statusFilter = modelData.value
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
        }
        
        // Lista de suscripciones
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
            
            ListView {
                id: subscriptionsListView
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                clip: true
                spacing: Theme.spacingS
                
                model: filteredSubscriptions
                
                delegate: MemberListItem {
                    width: subscriptionsListView.width
                    memberName: modelData.name
                    planName: modelData.plan
                    startDate: modelData.startDate
                    endDate: modelData.endDate
                    status: modelData.status
                    daysUntilExpiry: modelData.daysLeft
                    
                    onClicked: {
                        selectedMemberId = modelData.memberId
                        memberDetailPopup.open()
                    }
                }
                
                // Mensaje cuando no hay datos
                Text {
                    anchors.centerIn: parent
                    text: searchQuery !== "" || statusFilter !== "all" ?
                        "No se encontraron suscripciones con los filtros aplicados" :
                        "No hay suscripciones registradas"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: Theme.textSecondary
                    visible: subscriptionsListView.count === 0
                }
                
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }
        }
    }
    
    // ========================================================================
    // Popup de Detalle del Miembro
    // ========================================================================
    Popup {
        id: memberDetailPopup
        anchors.centerIn: parent
        width: 500
        height: 400
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: Theme.surface
            radius: Theme.radiusL
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.2)
                shadowBlur: 20
                shadowVerticalOffset: 8
            }
        }
        
        // Propiedades internas del popup
        property var memberDetails: null
        property bool showRenewalForm: false
        property int renewalPlanIndex: -1
        property double renewalPrice: 0
        
        onOpened: {
            memberDetails = gymController.getMemberDetails(selectedMemberId)
            showRenewalForm = false
            renewalPlanIndex = -1
        }

        contentItem: ColumnLayout {
            spacing: Theme.spacingL
            
            // Encabezado
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: memberDetailPopup.showRenewalForm ? "Renovar Suscripción" : "Detalle de Suscripción"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeL
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }
                
                Item { Layout.fillWidth: true }
                
                // Botón Editar
                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.radiusM
                    color: editPopupArea.containsMouse ? Theme.background : "transparent"
                    visible: !memberDetailPopup.showRenewalForm
                    
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/assets/icons/edit.svg"
                        width: 16; height: 16
                        sourceSize: Qt.size(16, 16)
                        opacity: 0.7
                    }
                    
                    MouseArea {
                        id: editPopupArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            editMemberDialog.memberId = selectedMemberId
                            editMemberDialog.memberData = memberDetailPopup.memberDetails
                            editMemberDialog.open()
                        }
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.radiusM
                    color: closePopupArea.containsMouse ? Theme.background : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 16
                        color: Theme.textSecondary
                    }
                    
                    MouseArea {
                        id: closePopupArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: memberDetailPopup.close()
                    }
                }
            }
            
            // ... (rest of content)
            
            // Contenido: Detalles o Formulario
            StackLayout {
                currentIndex: memberDetailPopup.showRenewalForm ? 1 : 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // VISTA 0: Detalles del Miembro
                ColumnLayout {
                    spacing: Theme.spacingM
                    visible: !memberDetailPopup.showRenewalForm
                    
                    // Info Personal
                    RowLayout {
                        spacing: Theme.spacingM
                        
                        // Avatar
                        Rectangle {
                            width: 64; height: 64
                            radius: 32
                            color: Theme.primary
                            Text {
                                anchors.centerIn: parent
                                text: memberDetailPopup.memberDetails && memberDetailPopup.memberDetails.firstName ? (memberDetailPopup.memberDetails.firstName[0] + (memberDetailPopup.memberDetails.lastName ? memberDetailPopup.memberDetails.lastName[0] : "")) : "?"
                                font.pixelSize: 24
                                color: "white"
                                font.weight: Font.Bold
                            }
                        }
                        
                        ColumnLayout {
                            Text {
                                text: memberDetailPopup.memberDetails ? memberDetailPopup.memberDetails.fullName : "Cargando..."
                                font: Theme.fontHeader
                                color: Theme.textPrimary
                            }
                            Text {
                                text: memberDetailPopup.memberDetails ? (memberDetailPopup.memberDetails.email || "Sin email") : ""
                                color: Theme.textSecondary
                            }
                            Text {
                                text: memberDetailPopup.memberDetails ? (memberDetailPopup.memberDetails.phone || "Sin teléfono") : ""
                                color: Theme.textSecondary
                            }
                        }
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                    
                    Text {
                        text: "Suscripción Actual"
                        font.weight: Font.Bold
                        color: Theme.textPrimary
                    }
                    
                    // Helper text since we don't have sub details in memberDetails yet
                    Text {
                         text: "Ver detalles en la lista principal."
                         color: Theme.textSecondary
                         font.italic: true
                    }
                    
                    Item { Layout.fillHeight: true } // Spacer
                    
                    // Botones Vista Detalle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingM
                        
                        GymButton {
                            Layout.fillWidth: true
                            text: "Renovar Suscripción"
                            variant: "success"
                            onClicked: {
                                memberDetailPopup.showRenewalForm = true
                            }
                        }
                        
                        GymButton {
                            Layout.fillWidth: true
                            text: "Cerrar"
                            variant: "outline"
                            onClicked: memberDetailPopup.close()
                        }
                    }
                }
                
                // VISTA 1: Formulario de Renovación
                ColumnLayout {
                    spacing: Theme.spacingM
                    visible: memberDetailPopup.showRenewalForm
                    
                    property var plans: gymController.plans
                    
                    Text { 
                        text: "Seleccione el Plan para renovar:"
                        color: Theme.textSecondary
                    }
                    
                    // Lista de Planes (Simplificada)
                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        clip: true
                        model: parent.plans
                        delegate: Rectangle {
                            width: parent.width
                            height: 40
                            color: memberDetailPopup.renewalPlanIndex === index ? Theme.primary : "transparent"
                            radius: Theme.radiusS
                            border.color: Theme.border
                            border.width: memberDetailPopup.renewalPlanIndex === index ? 0 : 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                Text { 
                                    text: modelData.name
                                    color: memberDetailPopup.renewalPlanIndex === index ? "white" : Theme.textPrimary
                                    Layout.fillWidth: true 
                                }
                                Text { 
                                    text: "$" + modelData.price
                                    color: memberDetailPopup.renewalPlanIndex === index ? "white" : Theme.textPrimary
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    memberDetailPopup.renewalPlanIndex = index
                                    memberDetailPopup.renewalPrice = modelData.price
                                }
                            }
                        }
                    }
                    
                    MoneyInput {
                        Layout.fillWidth: true
                        label: "Precio de Renovación"
                        value: memberDetailPopup.renewalPrice
                        onValueChanged: memberDetailPopup.renewalPrice = value
                        visible: memberDetailPopup.renewalPlanIndex >= 0
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingM
                        
                        GymButton {
                            text: "Cancelar"
                            variant: "outlined"
                            onClicked: memberDetailPopup.showRenewalForm = false
                        }
                        
                        GymButton {
                            Layout.fillWidth: true
                            text: "Confirmar Renovación"
                            variant: "primary"
                            enabled: memberDetailPopup.renewalPlanIndex >= 0
                            onClicked: {
                                var plan = parent.plans[memberDetailPopup.renewalPlanIndex]
                                console.log("Renovando: " + selectedMemberId + " Plan: " + plan.id)
                                var success = gymController.renewSubscription(selectedMemberId, plan.id, memberDetailPopup.renewalPrice)
                                if (success) memberDetailPopup.close()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dialogo de Edición
    EditMemberDialog {
        id: editMemberDialog
        anchors.centerIn: parent
        width: Math.min(600, parent.width - 40)
        height: Math.min(700, parent.height - 40)
        
        onSaved: {
            // Recargar detalles del miembro en el popup
            memberDetailPopup.memberDetails = gymController.getMemberDetails(selectedMemberId)
            // También recargar la lista principal si cambió el nombre
            gymController.refreshData() 
        }
    }
}
