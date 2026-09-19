pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/republican.js" as Republican

// Navigable decimal calendar: 12 months of 3 decades (10 days each), plus a
// 13th "month" for the 5-6 epagomenal days at the end of each year.
ColumnLayout {
    id: view

    // Current time, supplied by the widget (re-highlights "today" at midnight).
    property var now: new Date()
    // True while the popup is open; each time it opens we jump back to today.
    property bool active: false

    // What the view is showing. month: 0-11 = normal months, 12 = epagomenal block.
    property int viewYear: 0
    property int viewMonth: 0

    readonly property var today: Republican.fromDate(now)
    readonly property int todayMonth: today.isEpagomenal ? Republican.EPAGOMENAL_SLOT : today.monthIndex
    readonly property bool viewingToday: viewYear === today.republicanYear && viewMonth === todayMonth
    readonly property bool viewingEpagomenal: viewMonth === Republican.EPAGOMENAL_SLOT

    // Grid geometry
    readonly property real cellWidth: Kirigami.Units.gridUnit * 2
    readonly property real cellHeight: Kirigami.Units.gridUnit * 2.2
    readonly property real gap: Kirigami.Units.smallSpacing
    readonly property int rows: 3

    spacing: Kirigami.Units.smallSpacing

    function goToday() {
        var v = Republican.viewFor(today)
        viewYear = v.year
        viewMonth = v.month
    }

    // Each year has 13 slots (12 months + epagomenal block); step through them.
    function step(slots) {
        var idx = viewYear * 13 + viewMonth + slots
        viewYear = Math.floor(idx / 13)
        viewMonth = idx - viewYear * 13
    }

    Component.onCompleted: goToday()
    onActiveChanged: if (active) goToday()

    // --- title ---------------------------------------------------------------
    Kirigami.Heading {
        Layout.alignment: Qt.AlignHCenter
        level: 3
        text: Republican.monthTitle(view.viewYear, view.viewMonth)
    }

    // --- navigation ----------------------------------------------------------
    RowLayout {
        Layout.fillWidth: true
        spacing: view.gap

        PlasmaComponents3.Button {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            text: "\u00AB Year"
            onClicked: view.step(-13)
        }
        PlasmaComponents3.Button {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            text: "\u2039 Month"
            onClicked: view.step(-1)
        }
        PlasmaComponents3.Button {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            text: "Today"
            enabled: !view.viewingToday
            onClicked: view.goToday()
        }
        PlasmaComponents3.Button {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            text: "Month \u203A"
            onClicked: view.step(1)
        }
        PlasmaComponents3.Button {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            text: "Year \u00BB"
            onClicked: view.step(13)
        }
    }

    // --- grid ----------------------------------------------------------------
    // Fixed height (3 rows) so the popup doesn't resize when flipping between
    // a normal month and the epagomenal block.
    Item {
        Layout.fillWidth: true
        Layout.preferredWidth: 10 * view.cellWidth + 9 * view.gap
        Layout.preferredHeight: view.rows * view.cellHeight + (view.rows - 1) * view.gap

        // Normal month: 3 decades x 10 days.
        GridLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !view.viewingEpagomenal
            columns: 10
            rowSpacing: view.gap
            columnSpacing: view.gap

            Repeater {
                model: 30

                delegate: Rectangle {
                    id: cell

                    required property int index
                    readonly property int dayInDecade: cell.index % 10
                    readonly property bool isRest: dayInDecade === 9
                    readonly property bool isToday: view.viewingToday
                                                    && !view.today.isEpagomenal
                                                    && view.today.dayOfMonth === cell.index + 1

                    Layout.preferredWidth: view.cellWidth
                    Layout.preferredHeight: view.cellHeight
                    radius: Kirigami.Units.cornerRadius
                    color: isToday ? Kirigami.Theme.highlightColor : "transparent"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        PlasmaComponents3.Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: cell.index + 1
                            font.family: "monospace"
                            font.bold: cell.isToday
                            color: cell.isToday ? Kirigami.Theme.highlightedTextColor
                                 : cell.isRest  ? Kirigami.Theme.negativeTextColor
                                                : Kirigami.Theme.textColor
                        }
                        PlasmaComponents3.Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: Republican.DAYS_ABBR[cell.dayInDecade]
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            opacity: 0.65
                            color: cell.isToday ? Kirigami.Theme.highlightedTextColor
                                                : Kirigami.Theme.textColor
                        }
                    }
                }
            }
        }

        // Epagomenal block: 5 or 6 named days, belonging to no month.
        GridLayout {
            anchors.fill: parent
            visible: view.viewingEpagomenal
            columns: 2
            rowSpacing: view.gap
            columnSpacing: view.gap

            Repeater {
                model: Republican.epagomenalCount(view.viewYear)

                delegate: Rectangle {
                    id: epagCell

                    required property int index
                    readonly property bool isToday: view.viewingToday
                                                    && view.today.isEpagomenal
                                                    && view.today.epagIndex === epagCell.index

                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: view.cellHeight
                    radius: Kirigami.Units.cornerRadius
                    color: isToday ? Kirigami.Theme.highlightColor : "transparent"

                    PlasmaComponents3.Label {
                        anchors.centerIn: parent
                        text: Republican.EPAGOMENAL[epagCell.index]
                        font.italic: true
                        font.bold: epagCell.isToday
                        color: epagCell.isToday ? Kirigami.Theme.highlightedTextColor
                                                : Kirigami.Theme.textColor
                    }
                }
            }
        }
    }
}
