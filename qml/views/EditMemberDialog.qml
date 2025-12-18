import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."
import "../components"

/**
 * EditMemberDialog - Dialog component for editing member profile
 */
Dialog {
    id: root
    
    // Properties
    property int memberId: -1
    property var memberData: null
    
    // UI Properties
    title: "Editar Perfil de Socio"
    modal: true
    dim: true
    standardButtons: Dialog.NoButton // We use custom buttons
    
    // Signals
    signal saved()
    signal cancelled()
    
    // Form fields linked to internal properties
    property string pFirstName: ""
    property string pLastName: ""
    property string pEmail: ""
    property string pPhone: ""
    property string pInstagram: ""
    property double pWeight: 0
    property double pHeight: 0
    property string pHealthNotes: ""
    property string pObservations: ""

    // Initializer
    onMemberDataChanged: {
        if (memberData) {
            pFirstName = memberData.firstName || ""
            pLastName = memberData.lastName || ""
            pEmail = memberData.email || ""
            pPhone = memberData.phone || ""
            pInstagram = memberData.instagram || ""
            pWeight = memberData.weight || 0
            pHeight = memberData.height || 0
            pHealthNotes = memberData.healthNotes || ""
            pObservations = memberData.observations || ""
        }
    }
    
    // Content
    contentItem: Rectangle {
        implicitWidth: 600
        implicitHeight: 700
        color: Theme.surface
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingL
            
            // Scrollable Content
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: parent.availableWidth
                    spacing: Theme.spacingL
                    
                    // 1. Datos Personales
                    GroupBox {
                        title: "Datos Personales"
                        Layout.fillWidth: true
                        
                        background: Rectangle { 
                            color: "transparent"
                            border.color: Theme.border
                            radius: Theme.radiusM
                        }
                        
                        label: Text {
                            text: parent.title
                            font: Theme.fontHeader
                            color: Theme.textSecondary
                            y: -10
                            x: 10
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingM
                            
                            RowLayout {
                                spacing: Theme.spacingM
                                GymTextField {
                                    Layout.fillWidth: true
                                    label: "Nombre *"
                                    text: pFirstName
                                    onTextChanged: pFirstName = text
                                }
                                GymTextField {
                                    Layout.fillWidth: true
                                    label: "Apellido *"
                                    text: pLastName
                                    onTextChanged: pLastName = text
                                }
                            }
                            
                            GymTextField {
                                Layout.fillWidth: true
                                label: "Email"
                                text: pEmail
                                onTextChanged: pEmail = text
                            }
                            
                            RowLayout {
                                spacing: Theme.spacingM
                                GymTextField {
                                    Layout.fillWidth: true
                                    label: "Teléfono"
                                    text: pPhone
                                    onTextChanged: pPhone = text
                                }
                                GymTextField {
                                    Layout.fillWidth: true
                                    label: "Instagram"
                                    placeholder: "@usuario"
                                    text: pInstagram
                                    onTextChanged: pInstagram = text
                                }
                            }
                        }
                    }
                    
                    // 2. Salud y Métricas
                    GroupBox {
                        title: "Salud y Notas"
                        Layout.fillWidth: true
                        
                        background: Rectangle { 
                            color: "transparent"
                            border.color: Theme.border
                            radius: Theme.radiusM
                        }
                        
                        label: Text {
                            text: parent.title
                            font: Theme.fontHeader
                            color: Theme.textSecondary
                            y: -10
                            x: 10
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Theme.spacingM
                            
                            RowLayout {
                                spacing: Theme.spacingM
                                GymTextField {
                                    Layout.fillWidth: true
                                    label: "Peso (kg)"
                                    text: pWeight > 0 ? pWeight.toString() : ""
                                    onTextChanged: pWeight = parseFloat(text) || 0
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                }
                                GymTextField {
                                    Layout.fillWidth: true
                                    label: "Altura (cm)"
                                    text: pHeight > 0 ? pHeight.toString() : ""
                                    onTextChanged: pHeight = parseFloat(text) || 0
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                }
                            }
                            
                            GymTextArea {
                                Layout.fillWidth: true
                                Layout.minimumHeight: 80
                                label: "Notas de Salud"
                                text: pHealthNotes
                                onTextChanged: pHealthNotes = text
                            }
                            
                            GymTextArea {
                                Layout.fillWidth: true
                                Layout.minimumHeight: 80
                                label: "Observaciones"
                                text: pObservations
                                onTextChanged: pObservations = text
                            }
                        }
                    }
                }
            }
            
            // Footer Buttons
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: Theme.spacingM
                
                GymButton {
                    text: "Cancelar"
                    variant: "outline"
                    onClicked: {
                        root.close()
                        root.cancelled()
                    }
                }
                
                GymButton {
                    text: "Guardar Cambios"
                    variant: "primary"
                    enabled: pFirstName.trim() !== "" && pLastName.trim() !== ""
                    onClicked: saveChanges()
                }
            }
        }
    }
    
    // Logic
    function saveChanges() {
        if (typeof gymController !== 'undefined') {
            var success = gymController.updateMember(
                memberId,
                pFirstName,
                pLastName,
                pEmail,
                pPhone,
                pInstagram,
                pWeight,
                pHeight,
                pHealthNotes,
                pObservations
            )
            
            if (success) {
                root.saved()
                root.close()
            }
        }
    }
}
