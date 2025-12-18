import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."

/**
 * GymComboBox - ComboBox Personalizado
 * 
 * Selector desplegable estilizado con etiqueta integrada.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades Públicas
    // ========================================================================
    property string label: ""
    property bool required: false
    property alias model: comboBox.model
    property alias currentIndex: comboBox.currentIndex
    property alias currentText: comboBox.currentText
    property alias currentValue: comboBox.currentValue
    property string textRole: "text"
    property string valueRole: "value"
    property string placeholder: "Seleccionar..."
    property string errorText: ""
    
    // ========================================================================
    // Señales
    // ========================================================================
    signal activated(int index)
    
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
    readonly property bool hasFocus: comboBox.popup.visible
    
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
        
        // ComboBox
        ComboBox {
            id: comboBox
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.inputHeight
            
            textRole: root.textRole
            valueRole: root.valueRole
            
            onActivated: (index) => root.activated(index)
            
            // Background del botón
            background: Rectangle {
                color: Theme.surface
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
            }
            
            // Content item (texto seleccionado)
            contentItem: Text {
                leftPadding: Theme.spacingM
                rightPadding: Theme.spacingL + 20
                text: comboBox.currentIndex >= 0 ? comboBox.currentText : placeholder
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeM
                color: comboBox.currentIndex >= 0 ? Theme.textPrimary : Theme.textDisabled
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            
            // Indicador (flecha)
            indicator: Item {
                x: comboBox.width - width - Theme.spacingM
                y: comboBox.height / 2 - height / 2
                width: 20
                height: 20
                
                Text {
                    anchors.centerIn: parent
                    text: "▼"
                    font.pixelSize: 10
                    color: Theme.textSecondary
                    rotation: comboBox.popup.visible ? 180 : 0
                    
                    Behavior on rotation {
                        NumberAnimation { duration: Theme.animationDurationFast }
                    }
                }
            }
            
            // Popup
            popup: Popup {
                y: comboBox.height + Theme.spacingXS
                width: comboBox.width
                implicitHeight: contentItem.implicitHeight + Theme.spacingS * 2
                padding: Theme.spacingXS
                
                background: Rectangle {
                    color: Theme.surface
                    radius: Theme.radiusM
                    border.width: 1
                    border.color: Theme.border
                    
                    // Sombra (disabled in performance mode)
                    layer.enabled: Theme.enableShadows
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0, 0, 0, 0.15)
                        shadowBlur: 8
                        shadowVerticalOffset: 4
                    }
                }
                
                contentItem: ListView {
                    clip: true
                    implicitHeight: Math.min(contentHeight, 300)
                    model: comboBox.popup.visible ? comboBox.delegateModel : null
                    currentIndex: comboBox.highlightedIndex
                    
                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }
            
            // Delegate para cada item
            delegate: ItemDelegate {
                width: comboBox.width - Theme.spacingS
                height: Theme.inputHeight
                
                contentItem: Text {
                    text: typeof modelData === 'object' ? modelData[root.textRole] : modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: highlighted ? Theme.primary : Theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                
                background: Rectangle {
                    color: highlighted ? Theme.background : "transparent"
                    radius: Theme.radiusS
                }
                
                highlighted: comboBox.highlightedIndex === index
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
