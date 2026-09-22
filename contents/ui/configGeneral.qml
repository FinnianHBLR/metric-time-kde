import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_timeFormat: formatCombo.currentIndex
    property alias cfg_metricSuffix: suffixCheck.checked
    property alias cfg_showCalendar: calendarCheck.checked
    property alias cfg_showAnalogDial: analogCheck.checked

    QQC2.ComboBox {
        id: formatCombo
        Kirigami.FormData.label: "Show:"
        model: [
            "Hours & minutes (5:43)",
            "Hours, minutes & seconds (5:43:21)",
            "Day fraction (.54321)"
        ]
    }

    QQC2.CheckBox {
        id: suffixCheck
        Kirigami.FormData.label: "Suffix:"
        text: "Add metric \u201cM\u201d marker"
    }

    QQC2.CheckBox {
        id: calendarCheck
        Kirigami.FormData.label: "Popup:"
        text: "Show decimal calendar"
    }

    QQC2.CheckBox {
        id: analogCheck
        Kirigami.FormData.label: "Analog Dial:"
        text: "Show metric analog clock dial"
        checked: cfg_showAnalogDial
        onCheckedChanged: cfg_showAnalogDial = checked
    }

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        visible: true
        type: Kirigami.MessageType.Information
        text: "Time zone follows the system clock."
    }
}
