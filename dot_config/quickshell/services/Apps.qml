pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Launchable apps, fuzzy search over them, and launch counts so the apps you
// use most rise to the top.
Singleton {
    id: root

    // Binding to the model is what makes Quickshell scan desktop entries.
    readonly property list<DesktopEntry> apps: DesktopEntries.applications.values.filter(a => !a.noDisplay && !hiddenIds.includes(a.id)).sort((a, b) => a.name.localeCompare(b.name))

    // Entries not meant for this desktop. Quickshell doesn't expose OnlyShowIn /
    // NotShowIn / Hidden, so read them ourselves (e.g. "About Xfce" is
    // OnlyShowIn=XFCE and would otherwise show up under Hyprland).
    property list<string> hiddenIds: []

    Process {
        running: true
        command: ["sh", "-c", `
            IFS=:
            for dir in \${XDG_DATA_HOME:-$HOME/.local/share} \${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
                for f in "$dir"/applications/*.desktop; do
                    [ -f "$f" ] || continue
                    awk -F= -v desks=":$XDG_CURRENT_DESKTOP:" -v id="$(basename "$f" .desktop)" '
                        /^\\[/ { main = ($0 == "[Desktop Entry]"); next }
                        !main { next }
                        $1 == "OnlyShowIn" { only = $2 }
                        $1 == "NotShowIn" { not = $2 }
                        $1 == "Hidden" && $2 == "true" { hide = 1 }
                        function listed(list,   n, i, a) {
                            n = split(list, a, ";")
                            for (i = 1; i <= n; i++) if (a[i] != "" && index(desks, ":" a[i] ":")) return 1
                            return 0
                        }
                        END { if (hide || (only != "" && !listed(only)) || listed(not)) print id }
                    ' "$f"
                done
            done`]
        stdout: StdioCollector {
            onStreamFinished: root.hiddenIds = text.split("\n").filter(id => id !== "")
        }
    }

    // Pick counts, keyed by desktop entry id (or "emoji:<emoji>" for emoji)
    function count(key: string): int {
        return usage.counts[key] ?? 0;
    }

    function bump(key: string): void {
        usage.counts = Object.assign({}, usage.counts, {
            [key]: count(key) + 1
        });
    }

    function uses(entry: DesktopEntry): int {
        return count(entry.id);
    }

    // How well `entry` matches the lower-cased query `q`; 0 means no match.
    function score(entry: DesktopEntry, q: string): real {
        const name = entry.name.toLowerCase();
        let s = 0;
        if (name === q)
            s = 100;
        else if (name.startsWith(q))
            s = 80;
        else if (name.split(/[\s\-_.]+/).some(w => w.startsWith(q)))
            s = 60;
        else if (name.includes(q))
            s = 40;
        else if ((entry.genericName ?? "").toLowerCase().includes(q) || entry.keywords.some(k => k.toLowerCase().startsWith(q)) || entry.id.toLowerCase().includes(q))
            s = 25;
        else if (isSubsequence(q, name))
            s = 15;
        else if ((entry.comment ?? "").toLowerCase().includes(q))
            s = 5;
        return s === 0 ? 0 : s + Math.log2(1 + uses(entry)) * 4;
    }

    function isSubsequence(q: string, text: string): bool {
        let i = 0;
        for (const c of text)
            if (c === q[i] && ++i === q.length)
                return true;
        return false;
    }

    function search(query: string, limit: int): list<DesktopEntry> {
        const q = query.trim().toLowerCase();
        if (q === "")
            return [...apps].sort((a, b) => uses(b) - uses(a) || a.name.localeCompare(b.name)).slice(0, limit);
        return apps.map(a => ({
                    a,
                    s: score(a, q)
                })).filter(r => r.s > 0).sort((x, y) => y.s - x.s).slice(0, limit).map(r => r.a);
    }

    function launch(entry: DesktopEntry): void {
        bump(entry.id);
        Quickshell.execDetached(["uwsm", "app", "--", entry.id + ".desktop"]);
    }

    FileView {
        path: Quickshell.statePath("launcher.json")
        atomicWrites: true
        onAdapterUpdated: writeAdapter()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: usage
            property var counts: ({})
        }
    }
}
