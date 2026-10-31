pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// UI state shared by every island: what is open and on which monitor.
// Only one monitor shows transient things (panels, toasts, OSD) at a time.
Singleton {
    id: root

    // "" | "audio" | "media" | "dashboard" | "launcher"
    property string panel: ""
    // Which launcher tab is showing: "apps" | "emoji" | "clips"
    property string launcherMode: "apps"
    property string panelScreen: ""

    property bool osdVisible: false

    // Keep the session from idling (no dim/lock/suspend by hypridle); the
    // islands hold the actual idle inhibitor.
    property bool stayAwake: false

    // A tray menu is a separate popup surface, which Hyprland's focus grab
    // counts as "outside"; panels must not auto-close while one is open.
    property bool menuOpen: false

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

    // Close the open panel, then run `command` once the island has finished
    // animating away, so e.g. hyprlock's screenshot background doesn't catch
    // the dashboard half-closed.
    function closeThenRun(command: var): void {
        close();
        pendingCommand = command;
        afterClose.restart();
    }

    property var pendingCommand: null

    Timer {
        id: afterClose
        interval: 450
        onTriggered: {
            Quickshell.execDetached(root.pendingCommand);
            root.pendingCommand = null;
        }
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

        // audio | media | dashboard | launcher
        function togglePanel(name: string): void {
            root.toggle(name, "");
        }

        // apps | emoji | clips. Pressing the same key again closes it; another
        // mode's key while open just switches tabs.
        function launcher(mode: string): void {
            if (root.panel === "launcher" && root.launcherMode === mode) {
                root.close();
                return;
            }
            root.launcherMode = mode;
            root.open("launcher", "");
        }

        function toggleStayAwake(): void {
            root.stayAwake = !root.stayAwake;
        }

        function closePanel(): void {
            root.close();
        }
    }
}
