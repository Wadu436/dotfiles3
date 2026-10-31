pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// UI state shared by every island: what is open and on which monitor.
// Only one monitor shows transient things (panels, toasts, OSD) at a time.
Singleton {
    id: root

    // "" | "audio" | "media" | "calendar" | "dashboard"
    property string panel: ""
    property string panelScreen: ""

    property bool osdVisible: false

    // Active Hyprland submap ("" when in the default keymap).
    property string submap: ""

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "submap")
                root.submap = event.data;
        }
    }

    readonly property string focusedScreen: Hyprland.focusedMonitor?.name ?? ""

    function open(name: string, screenName: string): void {
        panel = name;
        panelScreen = screenName || focusedScreen;
    }

    function toggle(name: string, screenName: string): void {
        if (panel === name)
            close();
        else
            open(name, screenName);
    }

    function close(): void {
        panel = "";
    }

    function showOsd(): void {
        osdVisible = true;
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.osdVisible = false
    }

    IpcHandler {
        target: "shell"

        function toggleDashboard(): void {
            root.toggle("dashboard", "");
        }

        // audio | media | calendar | dashboard
        function togglePanel(name: string): void {
            root.toggle(name, "");
        }

        function closePanel(): void {
            root.close();
        }
    }
}
