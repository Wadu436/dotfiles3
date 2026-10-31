import QtQuick
import qs.theme

// Hover hint: put it inside an item and it fills that item; after a short
// hover a small bubble fades in underneath. It never moves anything and
// takes no input, so it can't get in the way.
Item {
    id: root

    property string text
    property int delay: 350

    anchors.fill: parent

    // Set once the hover delay has passed; only leaving resets it. (A `running`
    // binding that mentions `text` would restart the delay — and hide the
    // bubble — every time live text like a temperature updates.)
    property bool armed: false

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered)
                delayTimer.restart();
            else {
                delayTimer.stop();
                root.armed = false;
            }
        }
    }

    Timer {
        id: delayTimer
        interval: root.delay
        onTriggered: root.armed = true
    }

    Rectangle {
        id: bubble

        readonly property bool shown: root.armed && root.text !== ""

        anchors.top: parent.bottom
        anchors.topMargin: shown ? 12 : 6
        anchors.horizontalCenter: parent.horizontalCenter
        z: 100
        width: label.implicitWidth + 20
        height: label.implicitHeight + 12
        radius: 10
        color: Theme.islandBg
        opacity: shown ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.fast
            }
        }
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Theme.normal
                easing.type: Easing.OutQuint
            }
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            textFormat: Text.StyledText
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSizeSmall
            lineHeight: 1.15
        }
    }
}
