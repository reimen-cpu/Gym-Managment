import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."
import "../components"

/**
 * NewSubscriberView - Vista de Nuevo Suscriptor (Horizontal Refactor)
 * 
 * Formulario para registrar nuevos miembros con selección de plan.
 * Layout horizontal optimizado para escritorio.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades de Estado
    // ========================================================================
    property bool isSubmitting: false
    property string errorMessage: ""
    
    // Datos del formulario
    property string firstName: ""
    property string lastName: ""
    property string email: ""
    property string phone: ""
    property string instagram: ""
    property string facebook: ""
    property string healthNotes: ""
    property double weight: 0
    property double memberHeight: 0
    property string observations: ""
    property int selectedPlanIndex: -1
    property double enrollmentFee: 0
    
    // Planes disponibles
    property var availablePlans: []
    
    // Fechas
    readonly property date startDate: new Date()
    readonly property date endDate: {
        if (selectedPlanIndex < 0 || availablePlans.length === 0) return startDate
        var d = new Date(startDate)
        // Use 'days' from plan object (assuming backend provides 'days' or 'months' converted)
        // Backend 'getPlans' now provides 'days'.
        var planDays = availablePlans[selectedPlanIndex].days || (availablePlans[selectedPlanIndex].months * 30) || 30
        d.setDate(d.getDate() + planDays)
        return d
    }
    
    // ========================================================================
    // Carga de Datos
    // ========================================================================
    Component.onCompleted: {
        console.log("[QML] NewSubscriberView V2 loading plans")
        if (typeof gymController !== 'undefined') {
            availablePlans = gymController.plans
            enrollmentFee = gymController.enrollmentFee // Load global fee
        } else {
            console.log("[QML] WARNING: gymController is undefined!")
            availablePlans = []
        }
    }
    
    // Listen for settings/plans changes
    Connections {
        target: typeof gymController !== 'undefined' ? gymController : null
        function onPlansChanged() { availablePlans = gymController.plans }
        function onSettingsChanged() { enrollmentFee = gymController.enrollmentFee }
    }

    // ========================================================================
    // Layout Principal
    // ========================================================================
    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        clip: true
        contentWidth: availableWidth
        
        ColumnLayout {
            width: Math.min(parent.width, 1400)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingL
            
            // Header
            Text {
                text: "Registrar Nuevo Miembro"
                font: Theme.fontHeader
                color: Theme.textPrimary
            }
            
            // Main Form Row (3 Columns)
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingL
                
                // --- COLUMNA 1: Datos Personales ---
                GroupBox {
                    title: "1. Datos Personales"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 350
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: Theme.surface
                        border.color: Theme.border
                        radius: Theme.radiusL
                    }
                    
                    label: Text {
                        x: 10; y: -10
                        text: parent.title
                        font: Theme.fontHeader
                        color: Theme.textPrimary
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingM
                        
                        GymTextField {
                            Layout.fillWidth: true
                            label: "Nombre"
                            placeholder: "Ej: Juan"
                            text: firstName
                            onTextChanged: firstName = text
                            required: true
                        }
                        
                        GymTextField {
                            Layout.fillWidth: true
                            label: "Apellido"
                            placeholder: "Ej: Pérez"
                            text: lastName
                            onTextChanged: lastName = text
                            required: true
                        }
                        
                        GymTextField {
                            Layout.fillWidth: true
                            label: "Email"
                            placeholder: "juan@example.com"
                            text: email
                            onTextChanged: email = text
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                        }
                        
                        GymTextField {
                            Layout.fillWidth: true
                            label: "Teléfono"
                            placeholder: "+54 9 11..."
                            text: phone
                            onTextChanged: phone = text
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                        }
                        
                       GymTextField {
                            Layout.fillWidth: true
                            label: "Instagram (Opcional)"
                            placeholder: "@usuario"
                            text: instagram
                            onTextChanged: instagram = text
                        }
                    }
                }
                
                // --- COLUMNA 2: Salud y Observaciones ---
                GroupBox {
                    title: "2. Salud y Notas"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 350
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: Theme.surface
                        border.color: Theme.border
                        radius: Theme.radiusL
                    }
                    
                    label: Text {
                        x: 10; y: -10
                        text: parent.title
                        font: Theme.fontHeader
                        color: Theme.textPrimary
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingM
                        
                        RowLayout {
                            spacing: Theme.spacingM
                            GymTextField {
                                Layout.fillWidth: true
                                label: "Peso (kg)"
                                placeholder: "0.0"
                                text: weight > 0 ? weight.toString() : ""
                                onTextChanged: weight = parseFloat(text) || 0
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                            GymTextField {
                                Layout.fillWidth: true
                                label: "Altura (cm)"
                                placeholder: "0.0"
                                text: memberHeight > 0 ? memberHeight.toString() : ""
                                onTextChanged: memberHeight = parseFloat(text) || 0
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                            }
                        }
                        
                        GymTextArea {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 100
                            label: "Notas de Salud"
                            placeholder: "Alergias, lesiones, condiciones..."
                            text: healthNotes
                            onTextChanged: healthNotes = text
                        }
                        
                        GymTextArea {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 80
                            label: "Observaciones Generales"
                            placeholder: "Objetivos, experiencia previa..."
                            text: observations
                            onTextChanged: observations = text
                        }
                    }
                }
                
                // --- COLUMNA 3: Suscripción y Pago ---
                GroupBox {
                    title: "3. Suscripción"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 350
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: Theme.surface
                        border.color: Theme.border
                        radius: Theme.radiusL
                    }
                    
                    label: Text {
                        x: 10; y: -10
                        text: parent.title
                        font: Theme.fontHeader
                        color: Theme.textPrimary
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingM
                        
                        GymComboBox {
                            Layout.fillWidth: true
                            label: "Plan Seleccionado"
                            required: true
                            model: availablePlans
                            textRole: "name"
                            valueRole: "id"
                            placeholder: "Seleccionar..."
                            currentIndex: selectedPlanIndex
                            onActivated: selectedPlanIndex = index
                        }
                        
                        ColumnLayout {
                            spacing: Theme.spacingXS
                            Text { text: "Cuota Inscripción (Fija)"; color: Theme.textSecondary; font: Theme.fontLabel }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 48
                                color: Theme.background
                                radius: Theme.radiusS
                                border.color: Theme.border
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingM
                                    
                                    Text {
                                        text: "$" + enrollmentFee.toLocaleString()
                                        font.pixelSize: Theme.fontSizeM
                                        color: Theme.textPrimary
                                        Layout.fillWidth: true
                                    }
                                    
                                    Image {
                                        source: "qrc:/assets/icons/lock.svg" // Optional lock icon
                                        sourceSize: Qt.size(16, 16)
                                        opacity: 0.5
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.border
                            Layout.margins: Theme.spacingS
                        }
                        
                        // Resumen de Fechas y Precios
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingM
                            
                            ColumnLayout {
                                Text { text: "Inicio"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeS }
                                Text { text: Qt.formatDate(startDate, "dd/MM/yyyy"); font.weight: Font.Bold; color: Theme.textPrimary }
                            }
                            Text { text: "→"; color: Theme.textSecondary }
                            ColumnLayout {
                                Text { text: "Vencimiento"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeS }
                                Text { 
                                    text: selectedPlanIndex >= 0 ? Qt.formatDate(endDate, "dd/MM/yyyy") : "-"
                                    font.weight: Font.Bold
                                    color: selectedPlanIndex >= 0 ? Theme.success : Theme.textSecondary 
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.1)
                            radius: Theme.radiusM
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                Text { text: "Total a Pagar"; color: Theme.textSecondary; font: Theme.fontLabel }
                                Text {
                                    text: "$" + (selectedPlanIndex >= 0 ? (availablePlans[selectedPlanIndex].price + enrollmentFee).toLocaleString() : enrollmentFee.toLocaleString())
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    color: Theme.success
                                }
                                Text {
                                    text: "(Plan + Inscripción)"
                                    font.pixelSize: Theme.fontSizeXS
                                    color: Theme.textSecondary
                                    visible: selectedPlanIndex >= 0 && enrollmentFee > 0
                                }
                            }
                        }
                    }
                } // End GroupBox Subscription
                
            } // End RowLayout (Columns)
            
            // Botones de Acción
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Theme.spacingM
                
                GymButton {
                    text: "Limpiar"
                    variant: "outlined"
                    onClicked: clearForm()
                }
                
                GymButton {
                    text: isSubmitting ? "Guardando..." : "Registrar Miembro"
                    variant: "primary"
                    enabled: !isSubmitting
                    onClicked: submitForm()
                }
            }
            
            // Error Message
            Text {
                visible: errorMessage !== ""
                text: errorMessage
                color: Theme.error
                font.pixelSize: Theme.fontSizeS
                Layout.alignment: Qt.AlignRight
            }
            
        } // End Main ColumnLayout
    } // End ScrollView
    
    // Popup de Éxito
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.5)
        visible: root.state === "Submitted"
        z: 100
        
        Rectangle {
            anchors.centerIn: parent
            width: 300; height: 200
            color: Theme.surface
            radius: Theme.radiusL
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingL
                
                Text {
                    text: "✓"
                    font.pixelSize: 48
                    color: Theme.success
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Miembro Registrado"
                    font: Theme.fontHeader
                    color: Theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
                
                GymButton {
                    text: "Nuevo Registro"
                    onClicked: {
                        root.state = ""
                        clearForm()
                    }
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    
    // ========================================================================
    // Lógica
    // ========================================================================
    function clearForm() {
        firstName = ""; lastName = ""; email = ""; phone = ""
        instagram = ""; healthNotes = ""; observations = ""
        weight = 0; memberHeight = 0
        selectedPlanIndex = -1; 
        // Do NOT reset enrollmentFee to 0, reload it from controller to keep sync
        if (typeof gymController !== 'undefined') {
            enrollmentFee = gymController.enrollmentFee
        }
        errorMessage = ""
    }
    
    function submitForm() {
        if (!validate()) return
        
        isSubmitting = true
        errorMessage = ""
        
        // Simular o Llamar Backend
        if (typeof gymController !== 'undefined') {
            try {
                var success = gymController.registerMember(
                    firstName, lastName, email, phone,
                    availablePlans[selectedPlanIndex].id,
                    startDate, enrollmentFee
                )
                
                if (success) {
                    root.state = "Submitted"
                    // Auto-reset después de 3s si se desea, o manual via botón
                } else {
                    errorMessage = "Error al guardar en base de datos"
                }
            } catch(e) {
                errorMessage = "Excepción: " + e
            }
        } else {
            errorMessage = "Error: Controlador no conectado"
        }
        isSubmitting = false
    }
    
    function validate() {
        if (firstName.trim() === "") { errorMessage = "Falta Nombre"; return false }
        if (lastName.trim() === "") { errorMessage = "Falta Apellido"; return false }
        if (selectedPlanIndex < 0) { errorMessage = "Seleccione un Plan"; return false }
        return true
    }
}
