pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/decimal-time.js" as DecimalTime

// Analog face for decimal time: 10 hours around the dial (numbered 1-10, with
// "10" at the top standing in for 0, the same way a 12-hour clock uses 12 for
// 0), each hour split into 100 minutes and each minute into 100 seconds.
Item {
    id: face

    property var now: new Date()

    implicitWidth: Kirigami.Units.gridUnit * 12
    implicitHeight: implicitWidth

    readonly property var t: DecimalTime.decimalTime(now)
    readonly property real diameter: Math.min(width, height)
    readonly property real radius: diameter / 2

    // Hands creep between marks the same way a conventional clock's hour hand
    // does: each angle folds in the fraction of the next-smaller unit.
    readonly property real hourAngle: (t.hours + t.minutes / 100) / 10 * 360
    readonly property real minuteAngle: (t.minutes + t.seconds / 100) / 100 * 360
    readonly property real secondAngle: t.seconds / 100 * 360

    // --- dial ------------------------------------------------------------
    Rectangle {
        anchors.centerIn: parent
        width: face.diameter
        height: face.diameter
        radius: width / 2
        color: Kirigami.Theme.backgroundColor
        border.color: Kirigami.Theme.disabledTextColor
        border.width: 1
    }

    // Hour numerals 1-10, evenly spaced, "10" (i.e. hour 0) at the top.
    Repeater {
        model: 10

        delegate: PlasmaComponents3.Label {
            id: numeral

            required property int index
            readonly property real angle: index * 36 * Math.PI / 180
            readonly property real ringRadius: face.radius - Kirigami.Units.gridUnit * 0.9

            text: index === 0 ? "10" : String(index)
            font.bold: true
            x: face.width / 2 + ringRadius * Math.sin(angle) - width / 2
            y: face.height / 2 - ringRadius * Math.cos(angle) - height / 2
        }
    }

    // --- hands -------------------------------------------------------------
    // Each hand is a rounded bar drawn pointing straight up from the dial
    // center, then rotated into place; transformOrigin: Bottom pivots it
    // around that center point (0° = up, rotation increases clockwise).
    Rectangle {
        width: Kirigami.Units.gridUnit * 0.35
        height: face.radius * 0.5
        radius: width / 2
        color: Kirigami.Theme.textColor
        x: face.width / 2 - width / 2
        y: face.height / 2 - height
        transformOrigin: Item.Bottom
        rotation: face.hourAngle
    }

    Rectangle {
        width: Kirigami.Units.gridUnit * 0.25
        height: face.radius * 0.75
        radius: width / 2
        color: Kirigami.Theme.textColor
        x: face.width / 2 - width / 2
        y: face.height / 2 - height
        transformOrigin: Item.Bottom
        rotation: face.minuteAngle
    }

    Rectangle {
        width: Kirigami.Units.gridUnit * 0.12
        height: face.radius * 0.85
        radius: width / 2
        color: Kirigami.Theme.highlightColor
        x: face.width / 2 - width / 2
        y: face.height / 2 - height
        transformOrigin: Item.Bottom
        rotation: face.secondAngle
    }

    // Center pivot, drawn last so it sits on top of all three hands.
    Rectangle {
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 0.4
        height: width
        radius: width / 2
        color: Kirigami.Theme.highlightColor
    }
}
