import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."
import "../components"

/**
 * PlansView - Vista de Planes de Pago
 * 
 * Gestión de planes de suscripción con CRUD completo.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades de Estado
    property bool isEditing: false
    property int editingIndex: -1
    
    // Datos del formulario
    property string planName: ""
    property int planDays: 30
    property double planPrice: 0
    property bool planActive: true

    property double enrollmentFee: 0
    
    // Lista de planes (cargada desde el controller)
    property var plans: []
    
    // Cargar datos al iniciar
    Component.onCompleted: {
        if (typeof gymController !== 'undefined') {
            plans = gymController.plans
            enrollmentFee = gymController.enrollmentFee
        }
    }
    
    // Actualizar cuando cambien los datos
    Connections {
        target: typeof gymController !== 'undefined' ? gymController : null
        function onPlansChanged() {
            plans = gymController.plans
        }
        function onSettingsChanged() {
            enrollmentFee = gymController.enrollmentFee
        }
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
                    text: "Planes y Configuración"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }
                
                Text {
                    text: "Administra las suscripciones y cuotas globales"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: Theme.textSecondary
                }
            }
            
            Item { Layout.fillWidth: true }
            
            GymButton {
                text: "Nuevo Plan"
                iconSource: "qrc:/assets/icons/add.svg"
                onClicked: openNewPlanDialog()
            }
        }

        // Configuración Global (Cuota Inscripción)
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 80
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
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingXL

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Cuota de Inscripción"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeL
                        font.weight: Theme.fontWeightMedium
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "Monto fijo que se cobra al registrar un nuevo socio"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeS
                        color: Theme.textSecondary
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: Theme.spacingM
                    
                    Text {
                        text: "Monto: "
                        font.family: Theme.fontFamily
                        color: Theme.textSecondary
                    }

                    SpinBox {
                        id: feeSpinBox
                        from: 0
                        to: 999999
                        value: enrollmentFee
                        stepSize: 100
                        editable: true
                        onValueModified: {
                            if (typeof gymController !== 'undefined') {
                                gymController.setEnrollmentFee(value)
                            }
                        }
                    }
                }
            }
        }
        
        // Contenido Principal (Lista + Editor)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingL
            
            // Lista de planes
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
                    spacing: 0
                    
                    // Cabecera de la tabla
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: Theme.background
                        radius: Theme.radiusM
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingM
                            
                            Text {
                                Layout.preferredWidth: 200
                                text: "Nombre del Plan"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeS
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSecondary
                            }
                            
                            Text {
                                Layout.preferredWidth: 100
                                text: "Duración"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeS
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Text {
                                Layout.preferredWidth: 120
                                text: "Precio"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeS
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignRight
                            }
                            
                            Text {
                                Layout.preferredWidth: 80
                                text: "Estado"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeS
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Acciones"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeS
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                    
                    // Lista
                    ListView {
                        id: plansListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: Theme.spacingXS
                        
                        model: plans
                        
                        delegate: Rectangle {
                            width: plansListView.width
                            height: 56
                            color: planMouseArea.containsMouse ? Theme.background : "transparent"
                            radius: Theme.radiusM
                            
                            Behavior on color {
                                ColorAnimation { duration: Theme.animationDurationFast }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingM
                                anchors.rightMargin: Theme.spacingM
                                spacing: Theme.spacingM
                                
                                // Nombre
                                Text {
                                    Layout.preferredWidth: 200
                                    text: modelData.name
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeM
                                    font.weight: Theme.fontWeightMedium
                                    color: modelData.isActive ? Theme.textPrimary : Theme.textDisabled
                                    elide: Text.ElideRight
                                }
                                
                                // Duración (Días)
                                Text {
                                    Layout.preferredWidth: 100
                                    // Usamos helper o logic inline
                                    text: formatDuration(modelData.days)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeM
                                    color: modelData.isActive ? Theme.textSecondary : Theme.textDisabled
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                // Precio
                                Text {
                                    Layout.preferredWidth: 120
                                    text: "$" + modelData.price.toLocaleString()
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeM
                                    font.weight: Theme.fontWeightMedium
                                    color: modelData.isActive ? Theme.success : Theme.textDisabled
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                // Estado
                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 28
                                    Layout.alignment: Qt.AlignHCenter
                                    radius: Theme.radiusRound
                                    color: modelData.isActive ? 
                                        Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.1) :
                                        Qt.rgba(Theme.textDisabled.r, Theme.textDisabled.g, Theme.textDisabled.b, 0.1)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.isActive ? "Activo" : "Inactivo"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeXS
                                        font.weight: Theme.fontWeightMedium
                                        color: modelData.isActive ? Theme.success : Theme.textDisabled
                                    }
                                }
                                
                                // Acciones
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    spacing: Theme.spacingS
                                    
                                    // Editar
                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: Theme.radiusM
                                        color: editMouseArea.containsMouse ? Theme.background : "transparent"
                                        
                                        Image {
                                            id: planEditIcon
                                            anchors.centerIn: parent
                                            source: Theme.getIcon("edit")
                                            width: 18
                                            height: 18
                                            sourceSize: Qt.size(18, 18)
                                        }
                                        
                                        MouseArea {
                                            id: editMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: editPlan(index)
                                        }
                                    }
                                    
                                    // Toggle activo
                                    Switch {
                                        id: planSwitch
                                        checked: modelData.isActive
                                        onClicked: {
                                            if (typeof gymController !== 'undefined') {
                                                gymController.togglePlanStatus(modelData.id, checked)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: planMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                            }
                        }
                        
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }
            }
            
            // Panel de edición (visible cuando se edita)
            Rectangle {
                Layout.preferredWidth: 350
                Layout.fillHeight: true
                color: Theme.surface
                radius: Theme.radiusL
                visible: isEditing
                
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
                    
                    // Título
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: editingIndex < 0 ? "Nuevo Plan" : "Editar Plan"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeL
                            font.weight: Theme.fontWeightMedium
                            color: Theme.textPrimary
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Rectangle {
                            width: 32
                            height: 32
                            radius: Theme.radiusM
                            color: closeMouseArea.containsMouse ? Theme.background : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 16
                                color: Theme.textSecondary
                            }
                            
                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: cancelEdit()
                            }
                        }
                    }
                    
                    // Formulario
                    GymTextField {
                        Layout.fillWidth: true
                        label: "Nombre del Plan"
                        placeholder: "Ej: Pase Diario, Mensual..."
                        required: true
                        text: planName
                        onTextChanged: planName = text
                    }
                    
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 100
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingXS
                            
                            Text {
                                text: "Duración (días) *"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeS
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSecondary
                            }
                            
                            // Selector de Unidad y Valor
                            RowLayout {
                                id: durationLayout
                                Layout.fillWidth: true
                                spacing: Theme.spacingS

                                property int durationValue: 1
                                property string durationUnit: "months" // days, months, years

                                // Logic to sync internal state with planDays
                                Component.onCompleted: {
                                    // Initialize from planDays
                                    if (planDays % 365 === 0) {
                                        durationUnit = "years"
                                        durationValue = planDays / 365
                                    } else if (planDays % 30 === 0) {
                                        durationUnit = "months"
                                        durationValue = planDays / 30
                                    } else {
                                        durationUnit = "days"
                                        durationValue = planDays
                                    }
                                }

                                onDurationValueChanged: updatePlanDays()
                                onDurationUnitChanged: updatePlanDays()

                                function updatePlanDays() {
                                    if (durationLayout.durationUnit === "days") planDays = durationValue
                                    else if (durationLayout.durationUnit === "months") planDays = durationValue * 30
                                    else if (durationLayout.durationUnit === "years") planDays = durationValue * 365
                                }

                                SpinBox {
                                    Layout.fillWidth: true
                                    from: 1
                                    to: 1000
                                    value: parent.durationValue
                                    onValueModified: parent.durationValue = value
                                    editable: true
                                }

                                GymComboBox {
                                    Layout.preferredWidth: 120
                                    model: [
                                        { text: "Días", value: "days" },
                                        { text: "Meses", value: "months" },
                                        { text: "Años", value: "years" }
                                    ]
                                    textRole: "text"
                                    valueRole: "value"
                                    currentIndex: durationLayout.durationUnit === "days" ? 0 : (durationLayout.durationUnit === "months" ? 1 : 2)
                                    onActivated: (index) => {
                                        var val = model[index].value
                                        durationLayout.durationUnit = val
                                    }
                                }
                            }
                            
                            Text {
                                text: "Total: " + planDays + " días"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeXS
                                color: Theme.textSecondary
                                visible: true
                            }
                        }
                    }
                    
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 90
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingXS
                            
                            MoneyInput {
                                Layout.fillWidth: true
                                label: "Precio del Plan"
                                value: planPrice
                                onValueChanged: planPrice = value
                            }
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    // Botones
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingM
                        
                        GymButton {
                            Layout.fillWidth: true
                            text: "Cancelar"
                            variant: "outline"
                            onClicked: cancelEdit()
                        }
                        
                        GymButton {
                            Layout.fillWidth: true
                            text: "Guardar"
                            variant: "success"
                            enabled: planName.trim() !== "" && planPrice > 0
                            onClicked: savePlan()
                        }
                    }
                }
            }
        }
    }
    
    // ========================================================================
    // Funciones
    // ========================================================================
    function formatDuration(days) {
        if (days % 30 === 0) {
            var m = days / 30
            return m + (m === 1 ? " mes" : " meses")
        }
        return days + " días"
    }
    
    function openNewPlanDialog() {
        editingIndex = -1
        planName = ""
        planDays = 30
        planPrice = 0
        planActive = true
        isEditing = true
    }
    
    function editPlan(index) {
        editingIndex = index
        var plan = plans[index]
        planName = plan.name
        planDays = plan.days // Backend must provide 'days'
        planPrice = plan.price
        planActive = plan.isActive
        isEditing = true
    }
    
    function cancelEdit() {
        isEditing = false
        editingIndex = -1
    }
    
    function savePlan() {
        if (typeof gymController === 'undefined') return

        if (editingIndex < 0) {
            // Create
            gymController.createPlan(planName, planDays, planPrice)
        } else {
            // Update
            var id = plans[editingIndex].id
            gymController.updatePlan(id, planName, planDays, planPrice)
        }
        
        isEditing = false
        editingIndex = -1
    }
}
