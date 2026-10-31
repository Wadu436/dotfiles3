import QtQuick
import qs.theme

// Round icon button with a hover wash. `active` tints it iris.
Rectangle {
    id: root

    property alias icon: glyph.text
    property alias iconSize: glyph.size
    property color iconColor: active ? Theme.base : Theme.text
    property bool active: false
    property int diameter: 32
    readonly property alias hovered: mouse.containsMouse

    signal clicked(var mouse)

    implicitWidth: diameter
    implicitHeight: diameter
    radius: height / 2
    color: active ? Theme.iris : mouse.containsMouse ? Theme.highlightMed : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Theme.fast
        }
    }

    Glyph {
        id: glyph
        anchors.centerIn: parent
        color: root.iconColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => root.clicked(m)
    }
}
