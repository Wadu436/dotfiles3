import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.theme
import qs.widgets

// Icon + title of the window that matters on this monitor: the focused window
// if it lives here, otherwise the first window on this monitor's workspace.
RowLayout {
    id: root

    required property HyprlandMonitor monitor
    property int maxWidth: 520

    readonly property HyprlandToplevel toplevel: {
        const active = Hyprland.activeToplevel;
        if (active && active.monitor === monitor)
            return active;
        return monitor?.activeWorkspace?.toplevels.values[0] ?? null;
    }
    readonly property string appId: toplevel?.wayland?.appId ?? toplevel?.lastIpcObject?.class ?? ""

    visible: toplevel !== null
    spacing: 8

    IconImage {
        implicitSize: 16
        source: {
            const entry = DesktopEntries.heuristicLookup(root.appId);
            return Quickshell.iconPath(entry?.icon ?? root.appId, "application-x-executable");
        }
        asynchronous: true
    }

    Label {
        Layout.maximumWidth: root.maxWidth
        text: root.toplevel?.title ?? ""
        color: Theme.subtle
    }
}
