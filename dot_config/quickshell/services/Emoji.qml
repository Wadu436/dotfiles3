pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Emoji list from rofi-emoji (tab-separated: emoji, group, subgroup, name,
// " | "-separated keywords) plus a pick count so favourites come first.
Singleton {
    id: root

    property var all: []

    function search(query: string, limit: int): var {
        const q = query.trim().toLowerCase();
        if (q === "")
            // favourites first, then the list's own order (by group)
            return all.map((e, i) => ({
                        e,
                        i
                    })).sort((x, y) => Apps.count("emoji:" + y.e.emoji) - Apps.count("emoji:" + x.e.emoji) || x.i - y.i).slice(0, limit).map(r => r.e);
        const scored = [];
        for (const e of all) {
            let s = 0;
            if (e.name === q)
                s = 100;
            else if (e.name.startsWith(q))
                s = 80;
            else if (e.name.split(" ").some(w => w.startsWith(q)))
                s = 60;
            else if (e.keywords.some(k => k.startsWith(q)))
                s = 40;
            else if (e.name.includes(q))
                s = 20;
            if (s > 0)
                scored.push({
                    e,
                    s: s + Math.log2(1 + Apps.count("emoji:" + e.emoji)) * 4
                });
        }
        return scored.sort((x, y) => y.s - x.s).slice(0, limit).map(r => r.e);
    }

    // Copy it, then type it into whatever had focus once the launcher is gone.
    function pick(e: var): void {
        Apps.bump("emoji:" + e.emoji);
        Quickshell.execDetached(["wl-copy", e.emoji]);
        Quickshell.execDetached(["sh", "-c", 'sleep 0.15; wtype -- "$1"', "sh", e.emoji]);
    }

    FileView {
        path: "/usr/share/rofi-emoji/all_emojis.txt"
        onLoaded: {
            const list = [];
            for (const line of text().split("\n")) {
                const f = line.split("\t");
                if (f.length < 4)
                    continue;
                list.push({
                    emoji: f[0],
                    group: f[1],
                    name: f[3].toLowerCase(),
                    keywords: (f[4] ?? "").split("|").map(k => k.trim().toLowerCase()).filter(k => k !== "")
                });
            }
            root.all = list;
        }
    }
}
