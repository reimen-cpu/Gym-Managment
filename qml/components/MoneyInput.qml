import QtQuick 2.15
import ".."

/**
 * MoneyInput - Campo de entrada monetario
 * 
 * Extiende GymTextField para auto-formatear números con puntos (1.000.000)
 * mientras mantiene un valor numérico limpio internamente.
 */
GymTextField {
    id: root
    
    // Propiedad para el valor numérico real (sin puntos)
    property double value: 0
    // Prefijo (opcional)
    property string currencySymbol: "$"
    
    // Manejo interno para evitar bucles de actualización
    property bool _updating: false
    
    // Configuración base
    placeholder: "0"
    inputMethodHints: Qt.ImhDigitsOnly
    
    // Cuando el usuario escribe:
    onTextChanged: {
        if (_updating) return
        
        // 1. Limpiar todo lo que no sea dígito
        var cleanText = text.replace(/[^\d]/g, "")
        
        // 2. Convertir a número para la propiedad 'value'
        var numVal = parseFloat(cleanText)
        if (isNaN(numVal)) numVal = 0
        value = numVal
        
        // 3. Formatear con puntos (locale de-DE usa puntos para miles)
        var formatted = numVal > 0 ? numVal.toLocaleString("de-DE") : ""
        
        // 4. Actualizar texto visual
        _updating = true
        text = formatted
        _updating = false
    }
    
    // Cuando el valor cambia programáticamente (binding inicial)
    onValueChanged: {
        if (_updating) return
        
        var currentNum = 0
        var cleanText = text.replace(/[^\d]/g, "")
        if (cleanText !== "") currentNum = parseFloat(cleanText)
        
        // Solo actualizar texto si el valor difiere del actual visualmente
        if (value !== currentNum) {
            _updating = true
            text = value > 0 ? value.toLocaleString("de-DE") : ""
            _updating = false
        }
    }
}
