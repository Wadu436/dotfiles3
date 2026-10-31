import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Album art, track info, transport controls and a seek bar for Media.player.
// Used by the media panel and the dashboard.
RowLayout {
    id: root

    readonly property var player: Media.player

    spacing: 14

    // MPRIS doesn't push position updates; poll while visible and playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && Media.playing
        onTriggered: root.player?.positionChanged()
    }

    function fmt(s: real): string {
        s = Math.max(0, Math.floor(s));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    Rectangle {
        implicitWidth: 84
        implicitHeight: 84
        radius: 12
        color: Theme.tile
        clip: true

        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(168, 168)
        }
        Glyph {
            anchors.centerIn: parent
            visible: Media.artUrl === ""
            text: Icons.music
            size: 32
            color: Theme.muted
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Label {
            Layout.fillWidth: true
            text: Media.title || "Nothing playing"
            font.bold: true
        }
        Label {
            Layout.fillWidth: true
            text: Media.artist || (root.player?.identity ?? "")
            color: Theme.subtle
        }

        RowLayout {
            Layout.topMargin: 4
            spacing: 4
            IconButton {
                icon: Icons.prev
                enabled: root.player?.canGoPrevious ?? false
                opacity: enabled ? 1 : 0.4
                onClicked: root.player.previous()
            }
            IconButton {
                icon: Media.playing ? Icons.pause : Icons.play
                active: true
                diameter: 36
                onClicked: root.player?.togglePlaying()
            }
            IconButton {
                icon: Icons.next
                enabled: root.player?.canGoNext ?? false
                opacity: enabled ? 1 : 0.4
                onClicked: root.player.next()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: (root.player?.lengthSupported ?? false) && root.player.length > 0
            spacing: 8
            Label {
                text: root.fmt(root.player?.position ?? 0)
                color: Theme.muted
                font.pixelSize: Theme.fontSizeSmall
            }
            Slider {
                Layout.fillWidth: true
                value: root.player ? root.player.position / Math.max(1, root.player.length) : 0
                fill: Theme.rose
                onMoved: v => {
                    if (root.player?.canSeek)
                        root.player.position = v * root.player.length;
                }
            }
            Label {
                text: root.fmt(root.player?.length ?? 0)
                color: Theme.muted
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
