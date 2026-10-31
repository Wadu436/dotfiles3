import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.theme
import qs.services
import qs.widgets

// The resting pill: workspaces · clock · media · volume · bell.
// While hovered (`peek`) it widens to show the song, date and temperatures.
Item {
    id: root

    required property string screenName
    required property HyprlandMonitor monitor
    property bool peek: false
    property bool shown: true

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

    onPeekChanged: SysStats.users += peek ? 1 : -1
    Component.onDestruction: if (peek) SysStats.users--

    // Scrolling anywhere on the pill walks through this monitor's workspaces
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: e => Hyprland.dispatch("workspace " + (e.angleDelta.y > 0 ? "m-1" : "m+1"))
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing + 4

        Workspaces {
            monitor: root.monitor
        }

        Label {
            visible: Shell.submap !== ""
            text: Shell.submap
            color: Theme.gold
            font.italic: true
        }

        // Clock (+ date on peek) → calendar
        MouseArea {
            implicitWidth: clockRow.implicitWidth
            implicitHeight: Theme.idleHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: Shell.toggle("calendar", root.screenName)

            RowLayout {
                id: clockRow
                anchors.centerIn: parent
                spacing: 8
                Label {
                    visible: root.peek
                    text: Time.format("ddd d MMM")
                    color: Theme.subtle
                }
                Label {
                    text: Time.format("HH:mm")
                    font.bold: true
                }
            }
        }

        // Media → media panel
        MouseArea {
            visible: Media.player !== null
            implicitWidth: mediaRow.implicitWidth
            implicitHeight: Theme.idleHeight
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: m => m.button === Qt.MiddleButton ? Media.player.togglePlaying() : Shell.toggle("media", root.screenName)

            RowLayout {
                id: mediaRow
                anchors.centerIn: parent
                spacing: 8
                Glyph {
                    text: Media.playing ? Icons.music : Icons.pause
                    color: Media.playing ? Theme.foam : Theme.muted
                }
                Label {
                    visible: root.peek && Media.title !== ""
                    text: Media.artist ? Media.title + "  ·  " + Media.artist : Media.title
                    color: Theme.subtle
                    Layout.maximumWidth: 280
                }
            }
        }

        // Temperatures (peek only)
        RowLayout {
            visible: root.peek
            spacing: 8
            Glyph {
                text: Icons.cpu
                color: Theme.muted
            }
            Label {
                text: SysStats.cpuTemp + "°"
                color: SysStats.tempColor(SysStats.cpuTemp)
            }
            Glyph {
                text: Icons.gpu
                color: Theme.muted
            }
            Label {
                text: SysStats.gpuTemp + "°"
                color: SysStats.tempColor(SysStats.gpuTemp)
            }
        }

        // Volume: click → mixer, middle → mute, scroll → adjust
        MouseArea {
            implicitWidth: volRow.implicitWidth
            implicitHeight: Theme.idleHeight
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: m => m.button === Qt.MiddleButton ? Audio.toggleMute(Audio.sink) : Shell.toggle("audio", root.screenName)
            onWheel: w => Audio.nudge(w.angleDelta.y > 0 ? 0.05 : -0.05)

            RowLayout {
                id: volRow
                anchors.centerIn: parent
                spacing: 6
                Glyph {
                    text: Icons.volume(Audio.muted, Audio.volume)
                    color: Audio.muted ? Theme.muted : Theme.text
                }
                Label {
                    visible: root.peek
                    text: Math.round(Audio.volume * 100) + "%"
                    color: Theme.subtle
                }
            }
        }

        // Bell: click → dashboard, right-click → do not disturb
        MouseArea {
            implicitWidth: bellRow.implicitWidth
            implicitHeight: Theme.idleHeight
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: m => m.button === Qt.RightButton ? Notifs.dnd = !Notifs.dnd : Shell.toggle("dashboard", root.screenName)

            RowLayout {
                id: bellRow
                anchors.centerIn: parent
                spacing: 4
                Glyph {
                    text: Notifs.dnd ? Icons.bellOff : Icons.bell
                    color: Notifs.dnd ? Theme.muted : Notifs.count > 0 ? Theme.rose : Theme.text
                }
                Label {
                    visible: Notifs.count > 0
                    text: Notifs.count
                    color: Theme.rose
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
            }
        }
    }
}
