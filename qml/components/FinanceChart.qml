import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".."

/**
 * FinanceChart - Gráfico de Finanzas "Maybe Style"
 * 
 * Visualización de línea suave con gradiente, usando Canvas.
 * Muestra el balance neto o la métrica principal.
 */
Item {
    id: root
    
    // ========================================================================
    // Propiedades
    // ========================================================================
    property var monthlyData: []
    property string title: "Ingresos vs Gastos"
    
    // Configuracion visual
    property color lineColor: "#22c55e"          // Green-500
    property color gradientStart: "#22c55e"      // Green-500 (con alpha)
    property color gradientStop: "transparent"
    
    implicitHeight: 300
    
    onMonthlyDataChanged: chartCanvas.requestPaint()
    
    // ========================================================================
    // Contenido
    // ========================================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingM
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: title
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeL
                font.weight: Theme.fontWeightMedium
                color: Theme.textPrimary
            }
            Item { Layout.fillWidth: true }
            
            // Leyenda simple
            Row {
                spacing: Theme.spacingS
                Rectangle {
                    width: 12; height: 12; radius: 2
                    color: root.lineColor
                }
                Text {
                    text: "Balance Neto" // Simplificamos a una sola línea "Net Worth" style
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeS
                    color: Theme.textSecondary
                }
            }
        }
        
        // Area del Gráfico
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Canvas {
                id: chartCanvas
                anchors.fill: parent
                // Margen interno para no cortar la línea
                anchors.margins: 10 
                antialiasing: true // Critical for smooth lines
                
                Component.onCompleted: {
                    console.log("[FinanceChart] Canvas completed")
                    requestPaint()
                }
                
                onPaint: {
                    var ctx = getContext("2d")
                    var w = width
                    var h = height
                    console.log("[FinanceChart] Painting canvas. Size: " + w + "x" + h)
                    
                    ctx.clearRect(0, 0, w, h)
                    
                    // --- 1. Preparar Datos ---
                    var points = []
                    
                    // Si no hay datos reales o están vacíos, usar mock para visualizar diseño
                    // Check validity of first item to ensure it has required properties
                    var validData = (monthlyData && monthlyData.length > 0 && monthlyData[0].month !== undefined);
                    
                    var dataToDraw = validData ? monthlyData : [
                        { month: "En", income: 2000000, expense: 1500000 },
                        { month: "Feb", income: 2500000, expense: 1200000 },
                        { month: "Mar", income: 2200000, expense: 2000000 },
                        { month: "Abr", income: 3200000, expense: 1800000 },
                        { month: "May", income: 2800000, expense: 1500000 },
                        { month: "Jun", income: 4500000, expense: 2000000 }
                    ]
                    
                    console.log("[FinanceChart] Drawing with " + dataToDraw.length + " points. Source: " + (validData ? "REAL" : "MOCK"))
                    
                    // Calcular "Balance" para cada mes (puntos Y)
                    var values = []
                    var maxVal = -Infinity
                    var minVal = Infinity
                    
                    for (var i = 0; i < dataToDraw.length; i++) {
                        var net = dataToDraw[i].income - dataToDraw[i].expense
                        values.push(net)
                        if (net > maxVal) maxVal = net
                        if (net < minVal) minVal = net
                    }
                    
                    // Ensure baseline 0 is visible or chart is centered
                    if (minVal > 0) minVal = 0
                    var range = maxVal - minVal
                    if (range === 0) range = 100 // Avoid divide by zero
                    
                    // Add padding to range
                    maxVal += range * 0.1
                    // minVal -= range * 0.1 // Optional bottom padding
                    var plotRange = maxVal - minVal
                    
                    // Compute coordinate points
                    var stepX = w / (values.length - 1)
                    
                    for (var j = 0; j < values.length; j++) {
                        var val = values[j]
                        // Normalized Y (0 at bottom, 1 at top)
                        // Canvas Y is 0 at top. So we invert.
                        var normalizedY = (val - minVal) / plotRange
                        var px = j * stepX
                        var py = h - (normalizedY * h)
                        points.push({x: px, y: py})
                    }
                    
                    if (points.length < 2) return
                    
                    // --- 2. Dibujar Gradiente (Relleno) ---
                    ctx.beginPath()
                    ctx.moveTo(points[0].x, h) // Start bottom-left
                    ctx.lineTo(points[0].x, points[0].y)
                    
                    // Smooth curve using Catmull-Rom or cubic Bezier
                    // Simplified: Control points for smooth spline
                    for (var k = 0; k < points.length - 1; k++) {
                        var p0 = points[k]
                        var p1 = points[k+1]
                        
                        // Simple midpoint bezier for smoothness
                        var midX = (p0.x + p1.x) / 2
                        var cp1x = midX
                        var cp1y = p0.y
                        var cp2x = midX
                        var cp2y = p1.y
                        
                        ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p1.x, p1.y)
                    }
                    
                    ctx.lineTo(w, h) // Line to bottom-right
                    ctx.closePath()
                    
                    var gradient = ctx.createLinearGradient(0, 0, 0, h)
                    gradient.addColorStop(0, Qt.rgba(34/255, 197/255, 94/255, 0.2)) // Green-500 @ 20%
                    gradient.addColorStop(1, Qt.rgba(34/255, 197/255, 94/255, 0.0)) // Transparent
                    ctx.fillStyle = gradient
                    ctx.fill()
                    
                    // --- 3. Dibujar Línea (Stroke) ---
                    ctx.beginPath()
                    ctx.moveTo(points[0].x, points[0].y)
                    
                    for (var m = 0; m < points.length - 1; m++) {
                        var pp0 = points[m]
                        var pp1 = points[m+1]
                        var mX = (pp0.x + pp1.x) / 2
                        ctx.bezierCurveTo(mX, pp0.y, mX, pp1.y, pp1.x, pp1.y)
                    }
                    
                    ctx.strokeStyle = root.lineColor
                    ctx.lineWidth = 3
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.stroke()
                    
                    // --- 4. Etiquetas Eje X ---
                    // Dibujar meses en la parte inferior si hay espacio
                    // (Opcional, pero útil)
                }
                
                // Refresh triggers
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }
            
            // Overlay Labels (HTML/QML Text is sharper than Canvas Text)
            Row {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 20
                
                Repeater {
                    model: (root.monthlyData && root.monthlyData.length > 0) ? root.monthlyData : [
                        { month: "Jul" }, { month: "Ago" }, { month: "Sep" }, 
                        { month: "Oct" }, { month: "Nov" }, { month: "Dic" }
                    ]
                    
                    Item {
                        width: parent.width / 6 // Assumes 6 months fix or adjust dynamically
                        height: parent.height
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.month
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXS
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }
}
