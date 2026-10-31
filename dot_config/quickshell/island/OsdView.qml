import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Volume flash: icon, bar, percentage.
Item {
    id: root

    property bool shown: false

    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: row.implicitWidth + 2 * Theme.padding
    implicitHeight: Theme.idleHeight
    opacity: shown ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.normal
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing

        Glyph {
            text: Icons.volume(Audio.muted, Audio.volume)
            color: Audio.muted ? Theme.muted : Theme.iris
        }
        Rectangle {
            implicitWidth: 180
            implicitHeight: 6
            radius: 3
            color: Theme.highlightMed

            Rectangle {
                width: parent.width * Math.min(1, Audio.volume)
                height: parent.height
                radius: parent.radius
                color: Audio.muted ? Theme.muted : Theme.iris

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.fast
                        easing.type: Easing.OutQuint
                    }
                }
            }
        }
        Label {
            text: Audio.muted ? "muted" : Math.round(Audio.volume * 100) + "%"
            color: Theme.subtle
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 44
        }
    }
}
