import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."

/**
 * GymTextArea - Área de Texto Personalizada
 * 
 * Campo de entrada multilínea estilizado con etiqueta y placeholder.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property string label: ""
    property string placeholder: ""
    property alias text: textArea.text
    property string errorText: ""
    property bool required: false
    property bool readOnly: false
    
    // Alias opcional si se necesita acceder a la TextArea interna
    property alias textAreaControl: textArea
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    implicitHeight: labelText.height + Theme.spacingXS + 100 + // default min height
                    (errorText !== "" ? errorLabel.height + Theme.spacingXS : 0)
    implicitWidth: 250
    
    // ========================================================================
    // Estado
    // ========================================================================
    readonly property bool hasError: errorText !== ""
    readonly property bool hasFocus: textArea.activeFocus
    
    // ========================================================================
    // Layout
    // ========================================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingXS
        
        // Etiqueta
        Text {
            id: labelText
            Layout.fillWidth: true
            text: label + (required ? " *" : "")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeS
            font.weight: Theme.fontWeightMedium
            color: hasError ? Theme.error : Theme.textSecondary
            visible: label !== ""
        }
        
        // Área de texto con borde
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            color: readOnly ? Theme.surfaceVariant : Theme.surface
            radius: Theme.radiusM
            border.width: 1
            border.color: {
                if (hasError) return Theme.error
                if (hasFocus) return Theme.borderFocus
                return Theme.border
            }
            
            Behavior on border.color {
                ColorAnimation { duration: Theme.animationDurationFast }
            }
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                clip: true
                
                TextArea {
                    id: textArea
                    
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: readOnly ? Theme.textSecondary : Theme.textPrimary
                    selectionColor: Theme.primaryLight
                    selectedTextColor: Theme.textPrimary
                    
                    wrapMode: Text.WordWrap
                    readOnly: root.readOnly
                    selectByMouse: true
                    
                    // Placeholder
                    Text {
                        anchors.fill: parent
                        text: placeholder
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeM
                        color: Theme.textDisabled
                        visible: textArea.text === "" && !textArea.activeFocus
                        wrapMode: Text.WordWrap
                    }
                    
                    background: null // Remove default background
                }
            }
            
            // Indicador de requerido (esquina superior derecha)
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 4
                width: 8
                height: 8
                radius: 4
                color: Theme.error
                visible: required && root.text === ""
                opacity: 0.7
                z: 10
            }
        }
        
        // Mensaje de error
        Text {
            id: errorLabel
            Layout.fillWidth: true
            text: errorText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXS
            color: Theme.error
            visible: hasError
            wrapMode: Text.WordWrap
        }
    }
}
