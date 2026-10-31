pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history recorded by `clipse -listen` (started from Hyprland).
// We only read its history file and copy entries back with wl-copy.
Singleton {
    id: root

    // [{ value, recorded, image (file path or ""), pinned }], newest first
    property var history: []

    function search(query: string, limit: int): var {
        const q = query.trim().toLowerCase();
        const matches = q === "" ? history : history.filter(c => c.value.toLowerCase().includes(q));
        // pinned entries stay on top, otherwise newest first
        return [...matches.filter(c => c.pinned), ...matches.filter(c => !c.pinned)].slice(0, limit);
    }

    function pick(c: var): void {
        if (c.image !== "")
            Quickshell.execDetached(["sh", "-c", 'wl-copy --type image/png < "$1"', "sh", c.image]);
        else
            Quickshell.execDetached(["wl-copy", "--", c.value]);
    }

    // "2026-10-31 21:52:57.899196395" → "5m", "3h", "2d"
    function age(c: var, now: date): string {
        const t = new Date(c.recorded.slice(0, 19).replace(" ", "T"));
        const s = Math.max(0, Math.floor((now - t) / 1000));
        if (s < 60)
            return "now";
        if (s < 3600)
            return Math.floor(s / 60) + "m";
        if (s < 86400)
            return Math.floor(s / 3600) + "h";
        return Math.floor(s / 86400) + "d";
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/clipse/clipboard_history.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const entries = JSON.parse(text()).clipboardHistory ?? [];
                root.history = entries.map(e => ({
                            value: e.value ?? "",
                            recorded: e.recorded ?? "",
                            image: e.filePath && e.filePath !== "null" ? e.filePath : "",
                            pinned: e.pinned ?? false
                        }));
            } catch (err) {
                console.warn("clipse history unreadable:", err);
            }
        }
    }
}
