import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ".."

/**
 * GymTextField - Campo de Texto Personalizado
 * 
 * Campo de entrada estilizado con etiqueta, placeholder y validación.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property string label: ""
    property string placeholder: ""
    property alias text: textInput.text  // Direct binding to internal TextInput
    property string errorText: ""
    property bool required: false
    property bool readOnly: false
    property int inputType: TextInput.Normal  // Normal, Password, etc.
    property alias inputMethodHints: textInput.inputMethodHints
    property var validator: null
    
    // Alias para acceso directo
    property alias textField: textInput
    
    // ========================================================================
    // Dimensiones
    // ========================================================================
    implicitHeight: labelText.height + Theme.spacingXS + Theme.inputHeight + 
                    (errorText !== "" ? errorLabel.height + Theme.spacingXS : 0)
    implicitWidth: 250
    
    // ========================================================================
    // Estado
    // ========================================================================
    readonly property bool hasError: errorText !== ""
    readonly property bool hasFocus: textInput.activeFocus
    
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
        
        // Campo de texto
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.inputHeight
            
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
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingM
                anchors.rightMargin: Theme.spacingM
                spacing: Theme.spacingS
                
                TextInput {
                    id: textInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: readOnly ? Theme.textSecondary : Theme.textPrimary
                    selectionColor: Theme.primaryLight
                    selectedTextColor: Theme.textPrimary
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    readOnly: root.readOnly
                    echoMode: inputType
                    validator: root.validator
                    
                    // Placeholder
                    Text {
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        text: placeholder
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeM
                        color: Theme.textDisabled
                        visible: textInput.text === "" && !textInput.activeFocus
                    }
                }
                
                // Indicador de requerido
                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: Theme.error
                    visible: required && root.text === ""
                    opacity: 0.7
                }
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
