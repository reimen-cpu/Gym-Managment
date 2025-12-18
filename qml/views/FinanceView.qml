import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import ".."
import "../components"

/**
 * FinanceView - Vista de Finanzas
 * 
 * Dashboard financiero con resumen, gráfico y registro de movimientos.
 * Inspirado conceptualmente en Maybe Finance.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades de Estado
    // ========================================================================
    property bool showNewEntryDialog: false
    property string newEntryType: "income"  // income, expense
    
    // Datos del formulario
    property double newEntryAmount: 0
    property string newEntryDescription: ""
    property date newEntryDate: new Date()
    
    // Resumen financiero (vinculado al controller)
    property double totalIncome: 0
    property double totalExpenses: 0
    readonly property double balance: totalIncome - totalExpenses
    
    // Datos mensuales para el gráfico
    property var monthlyData: []
    
    // Historial de movimientos
    property var entries: []
    
    Connections {
        target: typeof gymController !== 'undefined' ? gymController : null
        function onFinancialDataChanged() {
            refreshData()
        }
    }
    
    Component.onCompleted: {
        if (typeof gymController !== 'undefined') {
            refreshData()
        }
    }
    
    function refreshData() {
        console.log("[QML] Refreshing financial data...")
        var summary = gymController.financialSummary
        if (summary) {
            totalIncome = summary.totalIncome || 0
            totalExpenses = summary.totalExpenses || 0
        }
        monthlyData = gymController.monthlyBreakdown || []
        entries = gymController.recentTransactions || []
        console.log("[QML] Loaded " + entries.length + " transactions")
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
                    text: "Finanzas"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitle
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }
                
                Text {
                    text: "Resumen financiero del gimnasio"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeM
                    color: Theme.textSecondary
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // Botones de acción
            RowLayout {
                spacing: Theme.spacingM
                
                GymButton {
                    text: "Registrar Ingreso"
                    variant: "success"
                    iconSource: "qrc:/assets/icons/add.svg"
                    onClicked: {
                        newEntryType = "income"
                        showNewEntryDialog = true
                    }
                }
                
                GymButton {
                    text: "Registrar Gasto"
                    variant: "danger"
                    iconSource: "qrc:/assets/icons/add.svg"
                    onClicked: {
                        newEntryType = "expense"
                        showNewEntryDialog = true
                    }
                }
            }
        }
        
        // Tarjetas de Resumen
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingL
            
            StatCard {
                Layout.fillWidth: true
                title: "INGRESOS TOTALES"
                value: formatCurrency(totalIncome)
                subtitle: "Acumulado del período"
                accentColor: Theme.success
            }
            
            StatCard {
                Layout.fillWidth: true
                title: "GASTOS TOTALES"
                value: formatCurrency(totalExpenses)
                subtitle: "Acumulado del período"
                accentColor: Theme.error
            }
            
            StatCard {
                Layout.fillWidth: true
                title: "BALANCE"
                value: (balance >= 0 ? "+" : "") + formatCurrency(balance)
                subtitle: balance >= 0 ? "Ganancia neta" : "Pérdida neta"
                accentColor: balance >= 0 ? Theme.success : Theme.error
            }
        }
        
        // Contenido principal
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingL
            
            // Gráfico
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
                
                FinanceChart {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    title: "Ingresos vs Gastos (últimos 6 meses)"
                    monthlyData: root.monthlyData
                }
            }
            
            // Historial de movimientos
            Rectangle {
                Layout.preferredWidth: 450
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
                    
                    // Título
                    Text {
                        text: "Últimos Movimientos"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeL
                        font.weight: Theme.fontWeightMedium
                        color: Theme.textPrimary
                    }
                    
                    // Separador
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.border
                    }
                    
                    // Lista
                    ListView {
                        id: entriesListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: Theme.spacingXS
                        
                        model: root.entries
                        
                        delegate: Rectangle {
                            width: entriesListView.width
                            height: 60
                            color: entryMouseArea.containsMouse ? Theme.background : "transparent"
                            radius: Theme.radiusM
                            
                            Behavior on color {
                                ColorAnimation { duration: Theme.animationDurationFast }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingS
                                spacing: Theme.spacingM
                                
                                // Indicador de tipo
                                Rectangle {
                                    Layout.preferredWidth: 4
                                    Layout.fillHeight: true
                                    radius: 2
                                    color: getEntryColor(modelData.type)
                                }
                                
                                // Icono
                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    radius: Theme.radiusRound
                                    color: Qt.rgba(
                                        getEntryColor(modelData.type).r,
                                        getEntryColor(modelData.type).g,
                                        getEntryColor(modelData.type).b,
                                        0.1
                                    )
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: isIncome(modelData.type) ? "↑" : "↓"
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                        color: getEntryColor(modelData.type)
                                    }
                                }
                                
                                // Descripción
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.description
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeM
                                        color: Theme.textPrimary
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        text: modelData.date + " • " + getEntryTypeLabel(modelData.type)
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeXS
                                        color: Theme.textSecondary
                                    }
                                }
                                
                                // Monto
                                Text {
                                    text: (isIncome(modelData.type) ? "+" : "-") + 
                                          formatCurrency(modelData.amount)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeM
                                    font.weight: Theme.fontWeightBold
                                    color: getEntryColor(modelData.type)
                                }
                            }
                            
                            MouseArea {
                                id: entryMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                        
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    }
                }
            }
        }
    }
    
    // ========================================================================
    // Diálogo de Nueva Entrada
    // ========================================================================
    Popup {
        id: newEntryPopup
        visible: showNewEntryDialog
        anchors.centerIn: parent
        width: 400
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onClosed: showNewEntryDialog = false
        
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
        
        contentItem: ColumnLayout {
            spacing: Theme.spacingL
            
            // Encabezado
            RowLayout {
                Layout.fillWidth: true
                
                Rectangle {
                    width: 40
                    height: 40
                    radius: Theme.radiusRound
                    color: Qt.rgba(
                        (newEntryType === "income" ? Theme.success : Theme.error).r,
                        (newEntryType === "income" ? Theme.success : Theme.error).g,
                        (newEntryType === "income" ? Theme.success : Theme.error).b,
                        0.1
                    )
                    
                    Text {
                        anchors.centerIn: parent
                        text: newEntryType === "income" ? "↑" : "↓"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: newEntryType === "income" ? Theme.success : Theme.error
                    }
                }
                
                Text {
                    text: newEntryType === "income" ? "Registrar Ingreso" : "Registrar Gasto"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeL
                    font.weight: Theme.fontWeightBold
                    color: Theme.textPrimary
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.radiusM
                    color: closeEntryArea.containsMouse ? Theme.background : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 16
                        color: Theme.textSecondary
                    }
                    
                    MouseArea {
                        id: closeEntryArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: showNewEntryDialog = false
                    }
                }
            }
            
            // Formulario
            GymTextField {
                Layout.fillWidth: true
                label: "Descripción"
                placeholder: newEntryType === "income" ? 
                    "Ej: Clases particulares, venta de productos..." :
                    "Ej: Mantenimiento, servicios, suministros..."
                required: true
                text: newEntryDescription
                onTextChanged: newEntryDescription = text
            }
            
            Item {
                Layout.fillWidth: true
                implicitHeight: 70
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacingXS
                    
                    Text {
                        text: "Monto *"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeS
                        font.weight: Theme.fontWeightMedium
                        color: Theme.textSecondary
                    }
                    
                    MoneyInput {
                        Layout.fillWidth: true
                        value: newEntryAmount
                        onValueChanged: newEntryAmount = value
                    }
                }
            }
            
            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingM
                
                GymButton {
                    Layout.fillWidth: true
                    text: "Cancelar"
                    variant: "outline"
                    onClicked: showNewEntryDialog = false
                }
                
                GymButton {
                    Layout.fillWidth: true
                    text: "Registrar"
                    variant: newEntryType === "income" ? "success" : "danger"
                    enabled: newEntryDescription.trim() !== "" && newEntryAmount > 0
                    onClicked: saveNewEntry()
                }
            }
        }
    }
    
    // ========================================================================
    // Funciones Helper
    // ========================================================================
    function formatCurrency(amount) {
        // Manual regex to force dots for thousands. 1000 -> 1.000
        return "$" + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    }

    function isIncome(type) {
        return type.indexOf("income") >= 0
    }
    
    function getEntryColor(type) {
        return isIncome(type) ? Theme.success : Theme.error
    }
    
    function getEntryTypeLabel(type) {
        switch(type) {
            case "enrollment_income": return "Inscripción"
            case "renewal_income": return "Renovación"
            case "custom_income": return "Ingreso"
            case "custom_expense": return "Gasto"
            default: return "Movimiento"
        }
    }
    
    function saveNewEntry() {
        console.log("[QML] FinanceView.saveNewEntry() called")
        console.log("[QML] Entry data:")
        console.log("[QML]   - Type: " + newEntryType)
        console.log("[QML]   - Description: " + newEntryDescription)
        console.log("[QML]   - Amount: $" + newEntryAmount)
        
        var success = false
        
        // Determinar si es gasto o ingreso y llamar al método correspondiente
        // Determinar si es gasto o ingreso y llamar al método correspondiente
        if (newEntryType === "expense") {
            success = gymController.recordExpense(newEntryDescription, newEntryAmount)
        } else {
            success = gymController.recordIncome(newEntryDescription, newEntryAmount)
        }
        
        if (success) {
            console.log("[QML] Entry saved successfully!")
            // Limpiar y cerrar
            newEntryDescription = ""
            newEntryAmount = 0
            showNewEntryDialog = false
        } else {
            console.log("[QML] Failed to save entry")
        }
    }
}
