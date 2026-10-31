import QtQuick
import qs.theme

// Drag/click/scroll slider. Emits `moved` with the new 0..1 value; the caller
// writes it back, so external changes keep `value` in sync.
Item {
    id: root

    property real value: 0
    property color fill: Theme.iris
    property bool dimmed: false

    signal moved(real value)

    implicitHeight: 18
    implicitWidth: 200

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.highlightMed

        Rectangle {
            width: Math.max(height, track.width * Math.max(0, Math.min(1, root.value)))
            height: parent.height
            radius: parent.radius
            color: root.dimmed ? Theme.muted : root.fill
        }
    }

    Rectangle {
        x: track.width * Math.max(0, Math.min(1, root.value)) - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: mouse.containsMouse || mouse.pressed ? 16 : 12
        height: width
        radius: width / 2
        color: Theme.text

        Behavior on width {
            NumberAnimation {
                duration: Theme.fast
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function emitAt(x: real): void {
            root.moved(Math.max(0, Math.min(1, x / width)));
        }
        onPressed: m => emitAt(m.x)
        onPositionChanged: m => {
            if (pressed)
                emitAt(m.x);
        }
        onWheel: w => root.moved(Math.max(0, Math.min(1, root.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
