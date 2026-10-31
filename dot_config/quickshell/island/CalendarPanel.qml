import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Month calendar with today highlighted; arrows/scroll change month.
Item {
    id: root

    property int month: Time.now.getMonth()
    property int year: Time.now.getFullYear()

    function shift(delta: int): void {
        const d = new Date(year, month + delta, 1);
        month = d.getMonth();
        year = d.getFullYear();
    }

    implicitWidth: 330
    implicitHeight: col.implicitHeight + 2 * 18

    WheelHandler {
        onWheel: e => root.shift(e.angleDelta.y > 0 ? -1 : 1)
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            IconButton {
                icon: "‹"
                onClicked: root.shift(-1)
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: new Date(root.year, root.month, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
                font.bold: true
                font.pixelSize: Theme.fontSizeLarge
            }
            IconButton {
                icon: "›"
                onClicked: root.shift(1)
            }
        }

        DayOfWeekRow {
            Layout.fillWidth: true
            locale: grid.locale
            delegate: Label {
                required property string shortName
                text: shortName.slice(0, 2)
                horizontalAlignment: Text.AlignHCenter
                color: Theme.muted
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        MonthGrid {
            id: grid
            Layout.fillWidth: true
            month: root.month
            year: root.year
            locale: Qt.locale("en_GB") // weeks start on Monday

            delegate: Rectangle {
                required property var model
                readonly property bool today: model.today
                implicitWidth: 38
                implicitHeight: 32
                radius: 10
                color: today ? Theme.iris : "transparent"
                Label {
                    anchors.centerIn: parent
                    text: parent.model.day
                    color: parent.today ? Theme.base : parent.model.month === root.month ? Theme.text : Theme.highlightHigh
                    font.bold: parent.today
                }
            }
        }
    }
}
