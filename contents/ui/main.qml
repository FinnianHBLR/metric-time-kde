import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/republican.js" as Republican
import "../code/decimal-time.js" as DecimalTime

PlasmoidItem {
    id: root

    // --- decimal time engine -------------------------------------------------
    property var now: new Date()

    function formatDecimal(date, format, suffix) {
        var t = DecimalTime.decimalTime(date)
        var suffixStr = suffix ? " M" : ""
        switch (format) {
        case 0: // Hours & minutes
            return t.hours + ":" + DecimalTime.pad(t.minutes, 2) + suffixStr
        case 2: // Day fraction
            return "." + DecimalTime.pad(Math.floor(t.fraction * 100000), 5) + suffixStr
        default: // Hours, minutes & seconds
            return t.hours + ":" + DecimalTime.pad(t.minutes, 2) + ":" + DecimalTime.pad(t.seconds, 2) + suffixStr
        }
    }

    function formatConventional(date) {
        return Qt.formatTime(date, "h:mm:ss AP")
    }

    readonly property string decimalText: formatDecimal(now, Plasmoid.configuration.timeFormat, Plasmoid.configuration.metricSuffix)
    readonly property string conventionalText: formatConventional(now)
    readonly property string republicanDateText: Republican.describe(Republican.fromDate(now))

    // Redraw only as often as the visible unit actually changes: once per
    // decimal second (0.864s) for the seconds/fraction formats, once per
    // decimal minute (86.4s) for hours & minutes only.
    Timer {
        interval: Plasmoid.configuration.timeFormat === 0 ? 86400 : 864
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    preferredRepresentation: compactRepresentation

    toolTipMainText: decimalText
    toolTipSubText: republicanDateText

    compactRepresentation: Item {
        Layout.minimumWidth: label.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumHeight: label.implicitHeight

        RowLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Label {
                id: label
                text: root.decimalText
                font.family: "monospace"
                elide: Text.ElideNone
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: PlasmaComponents3.Page {
        Layout.preferredWidth: content.implicitWidth + Kirigami.Units.largeSpacing * 2
        Layout.preferredHeight: content.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            MetricClockFace {
                Layout.alignment: Qt.AlignHCenter
                visible: Plasmoid.configuration.showAnalogDial
                now: root.now
            }

            Kirigami.Heading {
                Layout.alignment: Qt.AlignHCenter
                level: 1
                text: root.decimalText
                font.family: "monospace"
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.conventionalText
                opacity: 0.7
            }

            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.republicanDateText
                font.bold: true
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            CalendarView {
                Layout.fillWidth: true
                visible: Plasmoid.configuration.showCalendar
                now: root.now
                active: root.expanded
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                visible: Plasmoid.configuration.showCalendar
            }

            GridLayout {
                columns: 2
                columnSpacing: Kirigami.Units.largeSpacing
                Layout.alignment: Qt.AlignHCenter

                PlasmaComponents3.Label { text: "Day fraction:"; opacity: 0.7 }
                PlasmaComponents3.Label {
                    text: "." + DecimalTime.pad(Math.floor(DecimalTime.decimalTime(root.now).fraction * 100000), 5)
                    font.family: "monospace"
                }

                PlasmaComponents3.Label { text: "Time zone:"; opacity: 0.7 }
                PlasmaComponents3.Label { text: "System" }
            }

            PlasmaComponents3.Button {
                Layout.alignment: Qt.AlignHCenter
                text: "Widget settings\u2026"
                icon.name: "configure"
                onClicked: Plasmoid.internalAction("configure").trigger()
            }
        }
    }
}
