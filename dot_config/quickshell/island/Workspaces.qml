import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.theme
import qs.widgets

// One badge per workspace on this monitor: its number (as in SUPER+<number>)
// followed by an icon per distinct app open on it. A single iris highlight
// springs between badges on switch; urgent ones pulse love.
Item {
    id: root

    required property HyprlandMonitor monitor

    readonly property list<HyprlandWorkspace> workspaces: Hyprland.workspaces.values.filter(w => w.monitor === monitor && w.id > 0).sort((a, b) => a.id - b.id)
    readonly property int activeIndex: workspaces.indexOf(monitor?.activeWorkspace)
    // count is in the condition so this re-resolves once a new badge exists
    readonly property Item activeBadge: activeIndex >= 0 && activeIndex < repeater.count ? repeater.itemAt(activeIndex) : null

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

    implicitWidth: row.implicitWidth
    implicitHeight: 24

    component Spring: SpringAnimation {
        spring: Theme.spring
        damping: Theme.damping
        epsilon: 0.25
    }

    // The highlight lives behind the badges and chases the active one
    Rectangle {
        id: highlight
        visible: root.activeBadge !== null
        x: root.activeBadge?.x ?? 0
        width: root.activeBadge?.width ?? 0
        height: parent.height
        radius: height / 2
        color: Qt.alpha(Theme.iris, 0.2)
        border.width: 1
        border.color: Theme.iris

        Behavior on x {
            Spring {}
        }
        Behavior on width {
            Spring {}
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        // Neighbours glide aside when a workspace appears or a badge grows
        move: Transition {
            NumberAnimation {
                property: "x"
                duration: Theme.normal
                easing.type: Easing.OutBack
            }
        }

        Repeater {
            id: repeater
            // ScriptModel diffs each new array against the last, so only
            // workspaces that actually came or went get (re)created — a plain
            // array model would rebuild, and re-animate, every badge.
            model: ScriptModel {
                values: [...root.workspaces]
            }

            Rectangle {
                id: badge

                required property HyprlandWorkspace modelData
                readonly property bool active: root.monitor?.activeWorkspace === modelData
                readonly property bool urgent: modelData.urgent ?? false
                readonly property list<string> apps: root.appsOn(modelData)

                width: content.implicitWidth + 16
                height: 24
                radius: height / 2
                color: urgent ? Theme.love : mouse.containsMouse && !active ? Theme.highlightMed : "transparent"

                Behavior on width {
                    Spring {}
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.fast
                    }
                }

                // New workspaces grow in from nothing
                scale: 0
                Component.onCompleted: scale = 1
                Behavior on scale {
                    Spring {}
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

                    move: Transition {
                        NumberAnimation {
                            property: "x"
                            duration: Theme.normal
                            easing.type: Easing.OutBack
                        }
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: badge.modelData.id
                        color: badge.urgent ? Theme.base : badge.active ? Theme.iris : Theme.subtle
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.normal
                            }
                        }
                    }

                    Repeater {
                        model: ScriptModel {
                            values: badge.apps.slice(0, root.maxIcons)
                        }

                        IconImage {
                            required property string modelData
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 15
                            source: root.iconFor(modelData)
                            asynchronous: true
                            // Inactive workspaces stay quiet; the active one is in full color
                            opacity: badge.active || badge.urgent ? 1 : 0.6

                            // Pop in when the app opens
                            scale: 0
                            Component.onCompleted: scale = 1
                            Behavior on scale {
                                Spring {}
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.normal
                                }
                            }
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
}
