// Bar.qml
import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.components
import qs.config
import QtQuick.Layouts

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            required property ShellScreen modelData
            property var hyprlandMonitor: Hyprland.monitorFor(modelData)

            color: "transparent"

            screen: modelData

            implicitHeight: 30

            anchors {
                top: true
                left: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                color: Config.appearance.palette.background
            }

            Workspaces {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                screen: panelWindow.modelData
            }

            RowLayout {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Clock {}

                Battery {}
            }
        }
    }
}
