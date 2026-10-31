import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme
import qs.services
import qs.widgets

// SUPER+Pause: everything that used to live in the swaync sidebar.
Item {
    id: root

    implicitWidth: 460
    implicitHeight: col.implicitHeight + 2 * 20

    Component.onCompleted: SysStats.users++
    Component.onDestruction: SysStats.users--

    component Card: Rectangle {
        default property alias content: inner.data
        property int pad: 14
        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + 2 * pad
        radius: 16
        color: Theme.surface
        ColumnLayout {
            id: inner
            anchors.fill: parent
            anchors.margins: parent.pad
            spacing: 10
        }
    }

    component PowerButton: Rectangle {
        id: pb

        required property string icon
        required property string label
        required property var command
        property bool confirm: false
        property bool armed: false

        Layout.fillWidth: true
        implicitHeight: 54
        radius: 14
        color: armed ? Theme.love : pbMouse.containsMouse ? Theme.highlightMed : Theme.overlay

        Behavior on color {
            ColorAnimation {
                duration: Theme.fast
            }
        }

        Timer {
            id: disarm
            interval: 3000
            onTriggered: pb.armed = false
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            Glyph {
                Layout.alignment: Qt.AlignHCenter
                text: pb.icon
                color: pb.armed ? Theme.base : Theme.text
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: pb.armed ? "again" : pb.label
                color: pb.armed ? Theme.base : Theme.subtle
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        MouseArea {
            id: pbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (pb.confirm && !pb.armed) {
                    pb.armed = true;
                    disarm.restart();
                    return;
                }
                Shell.close();
                Quickshell.execDetached(pb.command);
            }
        }
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Header: big clock + date, network, DND toggle
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 0
                Label {
                    text: Time.format("HH:mm")
                    font.pixelSize: 34
                    font.bold: true
                }
                Label {
                    text: Time.format("dddd d MMMM")
                    color: Theme.subtle
                }
            }
            Item {
                Layout.fillWidth: true
            }
            ColumnLayout {
                spacing: 6
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 6
                    Glyph {
                        text: Network.type === "wifi" ? Icons.wifi : Network.online ? Icons.ethernet : Icons.offline
                        color: Network.online ? Theme.foam : Theme.love
                        size: 14
                    }
                    Label {
                        text: Network.online ? Network.name : "Offline"
                        color: Theme.subtle
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.maximumWidth: 160
                    }
                }
                Rectangle {
                    Layout.alignment: Qt.AlignRight
                    implicitWidth: dndRow.implicitWidth + 24
                    implicitHeight: 30
                    radius: 15
                    color: Notifs.dnd ? Theme.iris : dndMouse.containsMouse ? Theme.highlightMed : Theme.overlay
                    RowLayout {
                        id: dndRow
                        anchors.centerIn: parent
                        spacing: 6
                        Glyph {
                            text: Notifs.dnd ? Icons.bellOff : Icons.bell
                            color: Notifs.dnd ? Theme.base : Theme.text
                            size: 14
                        }
                        Label {
                            text: "Do not disturb"
                            color: Notifs.dnd ? Theme.base : Theme.text
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                    MouseArea {
                        id: dndMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dnd = !Notifs.dnd
                    }
                }
            }
        }

        Card {
            visible: Media.player !== null
            MediaCard {
                Layout.fillWidth: true
            }
        }

        Card {
            Meter {
                Layout.fillWidth: true
                icon: Icons.cpu
                label: "CPU"
                value: SysStats.cpu
                valueText: Math.round(SysStats.cpu * 100) + "%  " + SysStats.cpuTemp + "°"
                valueColor: SysStats.tempColor(SysStats.cpuTemp)
            }
            Meter {
                Layout.fillWidth: true
                icon: Icons.gpu
                label: "GPU"
                value: SysStats.gpu
                barColor: Theme.foam
                valueText: Math.round(SysStats.gpu * 100) + "%  " + SysStats.gpuTemp + "°"
                valueColor: SysStats.tempColor(SysStats.gpuTemp)
            }
            Meter {
                Layout.fillWidth: true
                icon: Icons.memory
                label: "RAM"
                value: SysStats.mem
                barColor: Theme.rose
                valueText: SysStats.memUsedGb.toFixed(1) + " / " + Math.round(SysStats.memTotalGb) + "G"
            }
        }

        // Notification history
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Label {
                Layout.fillWidth: true
                text: Notifs.count > 0 ? "Notifications  ·  " + Notifs.count : "Notifications"
                color: Theme.muted
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
            }
            Label {
                visible: Notifs.count > 0
                text: "Clear all"
                color: clearMouse.containsMouse ? Theme.love : Theme.subtle
                font.pixelSize: Theme.fontSizeSmall
                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.clearAll()
                }
            }
        }

        Label {
            visible: Notifs.count === 0
            Layout.fillWidth: true
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            horizontalAlignment: Text.AlignHCenter
            text: "All caught up"
            color: Theme.muted
        }

        ListView {
            id: list
            visible: Notifs.count > 0
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 380)
            clip: true
            spacing: 8
            boundsBehavior: Flickable.StopAtBounds
            // newest first
            model: [...Notifs.history].reverse()

            delegate: NotifCard {
                required property var modelData
                width: list.width
                notif: modelData
                compact: true
                // get out of the way of whatever the action focused/opened
                onActivated: ranAction => {
                    if (ranAction)
                        Shell.close();
                }
            }

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Theme.normal
                }
            }
        }

        // Power
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 8
            PowerButton {
                icon: Icons.lock
                label: "Lock"
                command: ["loginctl", "lock-session"]
            }
            PowerButton {
                icon: Icons.logout
                label: "Log out"
                command: ["uwsm", "stop"]
            }
            PowerButton {
                icon: Icons.reboot
                label: "Reboot"
                command: ["systemctl", "reboot"]
                confirm: true
            }
            PowerButton {
                icon: Icons.power
                label: "Shut down"
                command: ["systemctl", "poweroff"]
                confirm: true
            }
        }
    }
}
