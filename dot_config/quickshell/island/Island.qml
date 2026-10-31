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
        // Hangs from the top edge like the island (see there)
        y: -1
        width: inner.implicitWidth + 2 * Theme.padding
        height: Theme.idleHeight + 1
        radius: height / 2
        topLeftRadius: 0
        topRightRadius: 0
        color: Theme.islandBg
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
        case "launcher":
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
    // OnDemand, not Exclusive: Exclusive makes Hyprland drop the focus grab
    // below. While the grab is active the keyboard comes to us anyway.
    WlrLayershell.keyboardFocus: !panelHere ? WlrKeyboardFocus.None : WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.idleHeight

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

    // Stay-awake toggle: an inhibitor on a visible surface stops hypridle
    IdleInhibitor {
        window: win
        enabled: Shell.stayAwake
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

        // Flush with the top edge, notch-style: square top corners, and one
        // pixel above the screen so the top border line is cut off cleanly.
        anchors.horizontalCenter: parent.horizontalCenter
        y: -1
        width: win.current.implicitWidth
        height: win.current.implicitHeight + 1
        radius: win.pill ? height / 2 : Theme.panelRadius
        topLeftRadius: 0
        topRightRadius: 0
        color: win.pill ? Theme.islandBg : Theme.panelBg
        // No outline normally; gold while a Hyprland submap is active
        border.width: Shell.submap !== "" ? 1 : 0
        border.color: Theme.gold
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
        Behavior on color {
            ColorAnimation {
                duration: Theme.normal
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
                case "launcher":
                    return launcher;
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
        id: launcher
        Launcher {}
    }
    Component {
        id: dashboard
        Dashboard {}
    }
}
