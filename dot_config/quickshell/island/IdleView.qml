import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.theme
import qs.services
import qs.widgets

// The resting pill: workspaces · clock · media · volume · bell.
Item {
    id: root

    required property string screenName
    required property HyprlandMonitor monitor
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

    // Scrolling anywhere on the pill walks through this monitor's workspaces.
    // Hyprland runs a Lua config, so dispatch takes a Lua dispatcher expression.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: e => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${e.angleDelta.y > 0 ? "m-1" : "m+1"}" })`)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing + 4

        // Privacy: lit while something records the mic, camera or screen
        Item {
            visible: Privacy.active
            implicitWidth: privacyRow.implicitWidth
            implicitHeight: Theme.idleHeight

            Row {
                id: privacyRow
                anchors.centerIn: parent
                spacing: 6
                Glyph {
                    visible: Privacy.mic.length > 0
                    text: Icons.mic
                    color: Theme.gold
                    size: 14
                }
                Glyph {
                    visible: Privacy.camera.length > 0
                    text: Icons.camera
                    color: Theme.foam
                    size: 14
                }
                Glyph {
                    visible: Privacy.screen
                    text: Icons.screen
                    color: Theme.love
                    size: 14
                }
            }
            HoverTip {
                text: [Privacy.mic.length ? "<b>Microphone</b>: " + Privacy.mic.join(", ") : "", Privacy.camera.length ? "<b>Camera</b>: " + Privacy.camera.join(", ") : "", Privacy.screen ? "<b>Screen</b> is being shared" : ""].filter(l => l).join("<br>")
            }
        }

        Workspaces {
            monitor: root.monitor
        }

        Label {
            visible: Shell.submap !== ""
            text: Shell.submap
            color: Theme.gold
            font.italic: true
        }

        // Clock → dashboard (notifications, media, stats, power)
        MouseArea {
            implicitWidth: clockRow.implicitWidth
            implicitHeight: Theme.idleHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: Shell.toggle("dashboard", root.screenName)

            RowLayout {
                id: clockRow
                anchors.centerIn: parent
                spacing: 8
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
