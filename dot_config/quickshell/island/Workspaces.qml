import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.theme
import qs.widgets

// One badge per workspace on this monitor: its number (as in SUPER+<number>)
// followed by an icon per distinct app open on it. The active badge gets an
// iris outline and tint; urgent ones pulse love.
Row {
    id: root

    required property HyprlandMonitor monitor

    readonly property list<HyprlandWorkspace> workspaces: Hyprland.workspaces.values.filter(w => w.monitor === monitor && w.id > 0).sort((a, b) => a.id - b.id)

    readonly property int maxIcons: 4

    // App id → themed icon, via its .desktop entry when there is one
    function iconFor(appId: string): string {
        const entry = DesktopEntries.heuristicLookup(appId);
        return Quickshell.iconPath(entry?.icon ?? appId, "application-x-executable");
    }

    // Distinct app ids on a workspace, in window order
    function appsOn(ws: HyprlandWorkspace): list<string> {
        const ids = ws.toplevels.values.map(t => t.wayland?.appId ?? t.lastIpcObject?.class ?? "").filter(id => id !== "");
        return [...new Set(ids)];
    }

    spacing: 4

    Repeater {
        model: root.workspaces

        Rectangle {
            id: badge

            required property HyprlandWorkspace modelData
            readonly property bool active: root.monitor?.activeWorkspace === modelData
            readonly property bool urgent: modelData.urgent ?? false
            readonly property list<string> apps: root.appsOn(modelData)

            anchors.verticalCenter: parent.verticalCenter
            width: content.implicitWidth + 16
            height: 24
            radius: height / 2
            color: urgent ? Theme.love : active ? Qt.alpha(Theme.iris, 0.2) : mouse.containsMouse ? Theme.highlightMed : "transparent"
            border.width: active && !urgent ? 1 : 0
            border.color: Theme.iris

            Behavior on color {
                ColorAnimation {
                    duration: Theme.fast
                }
            }

            SequentialAnimation on opacity {
                running: badge.urgent
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

            Row {
                id: content
                anchors.centerIn: parent
                spacing: 5

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: badge.modelData.id
                    color: badge.urgent ? Theme.base : badge.active ? Theme.iris : Theme.subtle
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }

                Repeater {
                    model: badge.apps.slice(0, root.maxIcons)

                    IconImage {
                        required property string modelData
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 15
                        source: root.iconFor(modelData)
                        asynchronous: true
                        // Inactive workspaces stay quiet; the active one is in full color
                        opacity: badge.active || badge.urgent ? 1 : 0.6
                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: badge.apps.length > root.maxIcons
                    text: "+" + (badge.apps.length - root.maxIcons)
                    color: Theme.muted
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: badge.modelData.activate()
            }
        }
    }
}
