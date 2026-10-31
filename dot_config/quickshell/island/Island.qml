import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.theme
import qs.services

// One island per monitor. The window spans the top of the screen but is fully
// transparent; only the island itself takes input (see `mask`).
PanelWindow {
    id: win

    required property ShellScreen modelData

    readonly property string name: modelData.name
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)
    readonly property bool focused: Shell.focusedScreen === name
    readonly property bool panelHere: Shell.panel !== "" && Shell.panelScreen === name
    readonly property bool fullscreen: monitor?.activeWorkspace?.hasFullscreen ?? false

    // Highest-priority wins. Transient states only show on the focused monitor.
    readonly property string state: {
        if (panelHere)
            return Shell.panel;
        if (focused && Shell.osdVisible)
            return "osd";
        if (focused && Notifs.popups.length > 0)
            return "toast";
        return "idle";
    }
    readonly property bool pill: state === "idle" || state === "osd"
    // Games and fullscreen video only get interrupted by toasts/OSD/panels.
    readonly property bool hidden: fullscreen && state === "idle"
    readonly property bool edgesHidden: fullscreen

    // Left/right pills sharing the strip the island reserves anyway
    component EdgePill: Rectangle {
        default property alias content: inner.data
        y: Theme.gap
        width: inner.implicitWidth + 2 * Theme.padding
        height: Theme.idleHeight
        radius: height / 2
        color: Theme.islandBg
        border.width: 1
        border.color: Theme.islandBorder
        visible: opacity > 0
        opacity: win.edgesHidden ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.normal
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Theme.normal
                easing.type: Easing.OutQuint
            }
        }

        Item {
            id: inner
            anchors.centerIn: parent
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }

    readonly property Item current: {
        switch (state) {
        case "osd":
            return osd;
        case "toast":
            return toast;
        case "audio":
        case "media":
        case "calendar":
        case "dashboard":
            return panelLoader;
        default:
            return idle;
        }
    }

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 1000
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:island"
    WlrLayershell.keyboardFocus: panelHere ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.gap + Theme.idleHeight

    // Input only lands on the island and the two edge pills.
    mask: Region {
        x: island.x
        y: island.y
        width: win.hidden ? 0 : island.width
        height: win.hidden ? 0 : island.height

        Region {
            intersection: Intersection.Combine
            x: leftEdge.x
            y: leftEdge.y
            width: win.edgesHidden ? 0 : leftEdge.width
            height: win.edgesHidden ? 0 : leftEdge.height
        }
        Region {
            intersection: Intersection.Combine
            x: rightEdge.x
            y: rightEdge.y
            width: win.edgesHidden ? 0 : rightEdge.width
            height: win.edgesHidden ? 0 : rightEdge.height
        }
    }

    // Clicking anywhere outside the island closes an open panel.
    HyprlandFocusGrab {
        windows: [win]
        active: win.panelHere && !Shell.menuOpen
        onCleared: Shell.close()
    }

    onPanelHereChanged: if (panelHere) island.forceActiveFocus()

    EdgePill {
        id: leftEdge
        x: Theme.screenMargin
        visible: opacity > 0 && title.toplevel !== null

        WindowTitle {
            id: title
            monitor: win.monitor
            // never run underneath the island
            maxWidth: Math.max(0, island.x - 3 * Theme.screenMargin - 2 * Theme.padding - 24)
        }
    }

    EdgePill {
        id: rightEdge
        x: win.width - width - Theme.screenMargin

        StatusEdge {}
    }

    Rectangle {
        id: island

        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.gap
        width: win.current.implicitWidth
        height: win.current.implicitHeight
        radius: win.pill ? height / 2 : Theme.panelRadius
        color: Theme.islandBg
        border.width: 1
        border.color: Shell.submap !== "" ? Theme.gold : Theme.islandBorder
        clip: true

        opacity: win.hidden ? 0 : 1
        scale: win.hidden ? 0.9 : 1

        Behavior on width {
            SpringAnimation {
                spring: Theme.spring
                damping: Theme.damping
                epsilon: 0.25
            }
        }
        Behavior on height {
            SpringAnimation {
                spring: Theme.spring
                damping: Theme.damping
                epsilon: 0.25
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: Theme.normal
                easing.type: Easing.OutQuint
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.normal
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.normal
                easing.type: Easing.OutQuint
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.normal
            }
        }

        Keys.onEscapePressed: Shell.close()

        IdleView {
            id: idle
            screenName: win.name
            monitor: win.monitor
            shown: win.current === idle
        }

        OsdView {
            id: osd
            shown: win.current === osd
        }

        ToastView {
            id: toast
            shown: win.current === toast
        }

        Loader {
            id: panelLoader

            readonly property bool shown: win.current === panelLoader
            anchors.horizontalCenter: parent.horizontalCenter
            active: win.panelHere
            opacity: shown ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.normal
                }
            }

            sourceComponent: {
                switch (Shell.panel) {
                case "audio":
                    return audioPanel;
                case "media":
                    return mediaPanel;
                case "calendar":
                    return calendarPanel;
                default:
                    return dashboard;
                }
            }
        }
    }

    Component {
        id: audioPanel
        AudioPanel {}
    }
    Component {
        id: mediaPanel
        MediaPanel {}
    }
    Component {
        id: calendarPanel
        CalendarPanel {}
    }
    Component {
        id: dashboard
        Dashboard {}
    }
}
