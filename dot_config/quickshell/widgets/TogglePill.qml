import QtQuick
import QtQuick.Layouts
import qs.theme

// Pill-shaped on/off toggle with an icon and label (iris when on).
Rectangle {
    id: tp

    required property string icon
    required property string label
    property bool checked: false
    signal toggled

    implicitWidth: tpRow.implicitWidth + 24
    implicitHeight: 30
    radius: 15
    color: checked ? Theme.iris : tpMouse.containsMouse ? Theme.highlightMed : Theme.tile

    Behavior on color {
        ColorAnimation {
            duration: Theme.fast
        }
    }

    RowLayout {
        id: tpRow
        anchors.centerIn: parent
        spacing: 6
        Glyph {
            text: tp.icon
            color: tp.checked ? Theme.base : Theme.text
            size: 14
        }
        Label {
            text: tp.label
            color: tp.checked ? Theme.base : Theme.text
            font.pixelSize: Theme.fontSizeSmall
        }
    }
    MouseArea {
        id: tpMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tp.toggled()
    }
}
