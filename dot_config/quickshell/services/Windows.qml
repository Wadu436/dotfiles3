pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Open windows for the launcher's switcher tab, most recently used first, with
// the focused window last so Enter on an empty search acts like Alt+Tab.
Singleton {
    id: root

    // Call when the switcher opens; focus history lives in the IPC objects.
    function refresh(): void {
        Hyprland.refreshToplevels();
    }

    function all(): var {
        const wins = Hyprland.toplevels.values.filter(t => t.wayland && (t.workspace?.id ?? 0) > 0);
        const rank = t => {
            const h = t.lastIpcObject?.focusHistoryID ?? 999;
            return h === 0 ? 1000 : h; // focused window last
        };
        return wins.sort((a, b) => rank(a) - rank(b));
    }

    function search(query: string, limit: int): var {
        const q = query.trim().toLowerCase();
        const wins = all();
        if (q === "")
            return wins.slice(0, limit);
        return wins.filter(t => t.title.toLowerCase().includes(q) || (t.wayland?.appId ?? "").toLowerCase().includes(q)).slice(0, limit);
    }

    function pick(t: HyprlandToplevel): void {
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${t.address}" })`);
    }
}
