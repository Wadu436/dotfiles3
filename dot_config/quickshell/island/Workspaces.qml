import QtQuick
import Quickshell.Hyprland
import qs.theme

// One dot per occupied workspace on this monitor. The active one stretches into
// an iris pill; urgent ones pulse love.
Row {
    id: root

    required property HyprlandMonitor monitor

    readonly property list<HyprlandWorkspace> workspaces: Hyprland.workspaces.values.filter(w => w.monitor === monitor && w.id > 0).sort((a, b) => a.id - b.id)

    spacing: 6

    Repeater {
        model: root.workspaces

        Rectangle {
            id: dot

            required property HyprlandWorkspace modelData
            readonly property bool active: root.monitor?.activeWorkspace === modelData
            readonly property bool urgent: modelData.urgent ?? false

            anchors.verticalCenter: parent.verticalCenter
            width: active ? 22 : 8
            height: 8
            radius: 4
            color: urgent ? Theme.love : active ? Theme.iris : mouse.containsMouse ? Theme.subtle : Theme.highlightHigh

            Behavior on width {
                SpringAnimation {
                    spring: Theme.spring
                    damping: Theme.damping
                    epsilon: 0.25
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.fast
                }
            }

            SequentialAnimation on opacity {
                running: dot.urgent
                loops: Animation.Infinite
                alwaysRunToEnd: true
                NumberAnimation {
                    to: 0.35
                    duration: 500
                }
                NumberAnimation {
                    to: 1
                    duration: 500
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                anchors.margins: -5
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: dot.modelData.activate()
            }
        }
    }
}
