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
                            id: searchIcon
                            source: Theme.getIcon("search")
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
        height: Math.min(550, parent.height - 40)  // Altura dinámica con máximo
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
        property string memberName: ""
        property bool showRenewalForm: false
        property int renewalPlanIndex: -1
        property double renewalPrice: 0
        property int currentMemberId: -1
        property var subscriptionHistory: []
        
        onOpened: {
            currentMemberId = selectedMemberId
            console.log("[QML] Popup opened for member:", currentMemberId)
            memberDetails = gymController.getMemberDetails(currentMemberId)
            subscriptionHistory = gymController.getMemberSubscriptionHistory(currentMemberId)
            console.log("[QML] History loaded:", subscriptionHistory.length, "items")
            memberName = memberDetails ? (memberDetails.firstName + " " + memberDetails.lastName) : ""
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
                        id: editIcon
                        anchors.centerIn: parent
                        source: Theme.getIcon("edit")
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
                clip: true
                
                // VISTA 0: Detalles del Miembro
                ColumnLayout {
                    id: detailsColumn
                    spacing: Theme.spacingM
                    visible: !memberDetailPopup.showRenewalForm
                    
                    // Info Personal - Header con flecha
                    property bool profileExpanded: false
                    
                    RowLayout {
                        Layout.fillWidth: true
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
                            Layout.fillWidth: true
                            spacing: 2
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
                        
                        // Flecha para expandir/colapsar
                        Rectangle {
                            width: 32; height: 32
                            radius: Theme.radiusM
                            color: profileArrowArea.containsMouse ? Theme.background : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: detailsColumn.profileExpanded ? "▲" : "▼"
                                font.pixelSize: 12
                                color: Theme.textSecondary
                            }
                            
                            MouseArea {
                                id: profileArrowArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: detailsColumn.profileExpanded = !detailsColumn.profileExpanded
                            }
                        }
                    }
                    
                    // Detalles expandidos del perfil (aparece/desaparece con el layout)
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: Theme.spacingL
                        rowSpacing: Theme.spacingS
                        visible: detailsColumn.profileExpanded
                        Layout.preferredHeight: detailsColumn.profileExpanded ? implicitHeight : 0
                        
                        // Peso
                        Text {
                            text: "Peso:"
                            font.pixelSize: Theme.fontSizeS
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }
                        Text {
                            text: memberDetailPopup.memberDetails && memberDetailPopup.memberDetails.weight > 0 ? 
                                  memberDetailPopup.memberDetails.weight + " kg" : "No registrado"
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textPrimary
                        }
                        
                        // Altura
                        Text {
                            text: "Altura:"
                            font.pixelSize: Theme.fontSizeS
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }
                        Text {
                            text: memberDetailPopup.memberDetails && memberDetailPopup.memberDetails.height > 0 ? 
                                  memberDetailPopup.memberDetails.height + " cm" : "No registrado"
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textPrimary
                        }
                        
                        // Instagram
                        Text {
                            text: "Instagram:"
                            font.pixelSize: Theme.fontSizeS
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }
                        Text {
                            text: memberDetailPopup.memberDetails && memberDetailPopup.memberDetails.instagram ? 
                                  "@" + memberDetailPopup.memberDetails.instagram : "No registrado"
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textPrimary
                        }
                        
                        // Notas de salud
                        Text {
                            text: "Notas de salud:"
                            font.pixelSize: Theme.fontSizeS
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                            Layout.alignment: Qt.AlignTop
                        }
                        Text {
                            text: memberDetailPopup.memberDetails && memberDetailPopup.memberDetails.healthNotes ? 
                                  memberDetailPopup.memberDetails.healthNotes : "Sin notas"
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textPrimary
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        
                        // Observaciones
                        Text {
                            text: "Observaciones:"
                            font.pixelSize: Theme.fontSizeS
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                            Layout.alignment: Qt.AlignTop
                        }
                        Text {
                            text: memberDetailPopup.memberDetails && memberDetailPopup.memberDetails.observations ? 
                                  memberDetailPopup.memberDetails.observations : "Sin observaciones"
                            font.pixelSize: Theme.fontSizeS
                            color: Theme.textPrimary
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
                    
                    Text {
                        text: "Historial de Suscripciones"
                        font.weight: Font.Bold
                        color: Theme.textPrimary
                    }
                    
                    // Lista de historial de suscripciones
                    ListView {
                        id: subscriptionHistoryList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 150
                        clip: true
                        spacing: Theme.spacingS
                        
                        model: memberDetailPopup.subscriptionHistory
                        
                        delegate: Rectangle {
                            width: subscriptionHistoryList.width
                            height: 60
                            radius: Theme.radiusM
                            color: Theme.surfaceVariant
                            border.width: modelData.status === "active" ? 2 : 0
                            border.color: Theme.success
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingS
                                spacing: Theme.spacingM
                                
                                // Indicador de estado
                                Rectangle {
                                    width: 4
                                    Layout.fillHeight: true
                                    radius: 2
                                    color: modelData.status === "active" ? Theme.success : 
                                           modelData.status === "expiring" ? Theme.warning : Theme.error
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.planName || "Plan"
                                        font.weight: Font.Medium
                                        color: Theme.textPrimary
                                    }
                                    Text {
                                        text: modelData.startDate + " → " + modelData.endDate
                                        font.pixelSize: Theme.fontSizeS
                                        color: Theme.textSecondary
                                    }
                                }
                                
                                // Badge de estado
                                Rectangle {
                                    Layout.preferredWidth: statusLabel.width + 16
                                    Layout.preferredHeight: 24
                                    radius: 12
                                    color: Qt.rgba(
                                        (modelData.status === "active" ? Theme.success : 
                                         modelData.status === "expiring" ? Theme.warning : Theme.error).r,
                                        (modelData.status === "active" ? Theme.success : 
                                         modelData.status === "expiring" ? Theme.warning : Theme.error).g,
                                        (modelData.status === "active" ? Theme.success : 
                                         modelData.status === "expiring" ? Theme.warning : Theme.error).b,
                                        0.15
                                    )
                                    
                                    Text {
                                        id: statusLabel
                                        anchors.centerIn: parent
                                        text: modelData.status === "active" ? "Activo" : 
                                              modelData.status === "expiring" ? "Por Vencer" : "Vencido"
                                        font.pixelSize: Theme.fontSizeXS
                                        color: modelData.status === "active" ? Theme.success : 
                                               modelData.status === "expiring" ? Theme.warning : Theme.error
                                    }
                                }
                                
                                // Precio
                                Text {
                                    text: "$" + (modelData.price || 0).toLocaleString()
                                    font.weight: Font.Bold
                                    color: Theme.textPrimary
                                }
                            }
                        }
                        
                        // Mensaje cuando no hay historial
                        Text {
                            anchors.centerIn: parent
                            text: "No hay historial de suscripciones"
                            color: Theme.textSecondary
                            visible: subscriptionHistoryList.count === 0
                        }
                    }
                    
                    
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
                    id: renewalForm
                    spacing: Theme.spacingM
                    visible: memberDetailPopup.showRenewalForm
                    
                    property var plans: gymController.plans
                    
                    Text { 
                        text: "Seleccione el plan de renovación para " + memberDetailPopup.memberName
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeM
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }
                    
                    // Selector de Plan con GymComboBox
                    GymComboBox {
                        Layout.fillWidth: true
                        label: "Plan de Renovación"
                        required: true
                        model: parent.plans
                        textRole: "name"
                        valueRole: "id"
                        placeholder: "Seleccionar plan..."
                        currentIndex: memberDetailPopup.renewalPlanIndex
                        onActivated: function(index) {
                            memberDetailPopup.renewalPlanIndex = index
                            if (index >= 0 && parent.plans[index]) {
                                memberDetailPopup.renewalPrice = parent.plans[index].price
                            }
                        }
                    }
                    
                    // Mostrar detalles del plan seleccionado
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        // Usar Qt.rgba para el fondo en lugar de opacity global (que afectaría texto)
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                        radius: Theme.radiusM
                        border.width: 1
                        border.color: Theme.primary
                        visible: memberDetailPopup.renewalPlanIndex >= 0
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS
                            
                            Text {
                                text: memberDetailPopup.renewalPlanIndex >= 0 && renewalForm.plans[memberDetailPopup.renewalPlanIndex] ? 
                                      renewalForm.plans[memberDetailPopup.renewalPlanIndex].name : ""
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeL
                                font.weight: Theme.fontWeightBold
                                color: Theme.primary
                            }
                            
                            RowLayout {
                                spacing: Theme.spacingL
                                
                                Text {
                                    text: "Duración: " + (memberDetailPopup.renewalPlanIndex >= 0 && renewalForm.plans[memberDetailPopup.renewalPlanIndex] ? 
                                          renewalForm.plans[memberDetailPopup.renewalPlanIndex].duration : "")
                                    font.pixelSize: Theme.fontSizeS
                                    font.weight: Font.Medium
                                    color: Theme.textPrimary
                                }
                                
                                Text {
                                    text: "Precio: $" + (memberDetailPopup.renewalPrice || 0).toLocaleString()
                                    font.pixelSize: Theme.fontSizeS
                                    font.weight: Theme.fontWeightBold
                                    color: Theme.success
                                }
                            }
                        }
                    }
                    
                    MoneyInput {
                        Layout.fillWidth: true
                        label: "Precio de Renovación (ajustable)"
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
                                var plan = renewalForm.plans[memberDetailPopup.renewalPlanIndex]
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
