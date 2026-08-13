import QtQuick 2.0
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami

Kirigami.FormLayout {
    // === Preferencias ya existentes ===
    property alias cfg_showSecondHand:    showSecondHandCheckBox.checked
    property alias cfg_showTimezoneString: showTimezoneCheckBox.checked
    property alias cfg_circleStyle:       circleStyleCheckBox.checked
    property alias cfg_drawCalendarLines: calendarLinesCheckBox.checked
    property alias cfg_thicknessPadding:  thickPaddingSpn.value

    // === NUEVA preferencia: archivo de fondo ===
    // Guardamos el nombre del archivo elegido aquí.
    // El plasmoid lo leerá como plasmoid.configuration.backgroundSource
    property alias cfg_backgroundSource:  bgFilename.text

    anchors {
        left: parent.left
        right: parent.right
    }

    // ---- Apariencia ----
    CheckBox {
        id: showSecondHandCheckBox
        text: i18n("Show seconds hand")
        Kirigami.FormData.label: i18n("Appearance:")
    }

    CheckBox {
        id: showTimezoneCheckBox
        text: i18n("Show time zone")
    }

    CheckBox {
        id: circleStyleCheckBox
        text: i18n("Use circle style for highlights")
    }

    CheckBox {
        id: calendarLinesCheckBox
        text: i18n("Draw calendar lines")
    }

    SpinBox {
        id: thickPaddingSpn
        from: 0
        to: 96
        Kirigami.FormData.label: i18n("Thickness padding:")
        textFromValue: function(value) {
            return value + " " + i18nc("pixels", "px.");
        }
    }

    // ---- Selector de fondo (ComboBox) ----
    ComboBox {
        id: bgCombo
        Kirigami.FormData.label: i18n("Background:")
        // Mostramos nombres amigables pero guardamos el filename real.
        model: [
            { text: i18n("Fondo 01"), value: "fondo01.svg" },
            { text: i18n("Fondo 02"), value: "fondo02.svg" },
            { text: i18n("Fondo 03"), value: "fondo03.svg" },
            { text: i18n("Fondo 04"), value: "fondo04.svg" },
            { text: i18n("Fondo 05 (Constelación)"), value: "fondo05.png" },
            { text: i18n("Fondo 06 (Giro Sur Real)"), value: "fondo06.svg" }
        ]
        textRole: "text"

        // Sincronizar selección -> filename guardado
        onCurrentIndexChanged: {
            if (currentIndex >= 0 && currentIndex < model.length) {
                bgFilename.text = model[currentIndex].value
            }
        }

        Component.onCompleted: {
            // Inicializar el índice según el valor guardado (o fondo06 por defecto)
            var current = bgFilename.text && bgFilename.text.length ? bgFilename.text : "fondo06.svg"
            var idx = 0
            for (var i = 0; i < model.length; ++i) {
                if (model[i].value === current) { idx = i; break; }
            }
            currentIndex = idx
        }
    }

    // Campo “oculto” donde realmente se guarda el valor (para el alias)
    TextField {
        id: bgFilename
        visible: false
        text: "fondo06.svg" // valor por defecto seguro
    }
}
