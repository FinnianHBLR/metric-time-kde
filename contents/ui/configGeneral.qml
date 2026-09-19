import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_timeFormat: formatCombo.currentIndex
    property alias cfg_metricSuffix: suffixCheck.checked
    property alias cfg_showConventionalInCompact: conventionalCheck.checked
    property alias cfg_showCalendar: calendarCheck.checked

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
        id: conventionalCheck
        Kirigami.FormData.label: "In panel:"
        text: "Also show conventional time next to it"
    }

    QQC2.CheckBox {
        id: calendarCheck
        Kirigami.FormData.label: "Popup:"
        text: "Show decimal calendar"
    }

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
        visible: true
        type: Kirigami.MessageType.Information
        text: "Time zone follows the system clock. The day is split local-midnight to local-midnight, same as the macOS version."
    }
}
