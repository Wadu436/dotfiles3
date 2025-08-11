import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Controls
import qs.config

Item {
    id: root
    required property ShellScreen screen

    property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(screen)

    property list<HyprlandWorkspace> workspaces: Hyprland.workspaces.values.filter(function (workspace) {
        return workspace.monitor === hyprlandMonitor;
    })

    Row {
        anchors.fill: parent

        Repeater {
            model: root.workspaces
            Button {
                id: control
                required property HyprlandWorkspace modelData

                text: modelData.name
                
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                width: parent.height
                height: parent.height

                background: Rectangle {
                    color: control.down ? Config.appearance.palette.accentDark : control.hovered ? Config.appearance.palette.accent : control.modelData.active ? Config.appearance.palette.accentLight : "transparent"
                    border.width: 0
                    border.color: control.hovered ? Config.appearance.palette.accentDark : Config.appearance.palette.accent
                }

                contentItem: Text {
                    text: control.text
                    color: control.modelData.active ? control.hovered ? Config.appearance.palette.primaryDark : Config.appearance.palette.primary : Config.appearance.palette.foreground
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                onClicked: modelData.activate()
            }
        }
    }
}
