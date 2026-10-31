import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.theme
import qs.widgets

// Icon + title of the window that matters on this monitor: the focused window
// if it's on the workspace showing here, otherwise the first window on that
// workspace, or nothing for an empty workspace.
RowLayout {
    id: root

    required property HyprlandMonitor monitor
    property int maxWidth: 520

    readonly property HyprlandWorkspace workspace: monitor?.activeWorkspace ?? null
    readonly property HyprlandToplevel toplevel: {
        // activeToplevel keeps pointing at the last focused window after you
        // switch to an empty workspace, so it must be on the visible one.
        const active = Hyprland.activeToplevel;
        if (active && active.workspace === workspace)
            return active;
        return workspace?.toplevels.values[0] ?? null;
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
