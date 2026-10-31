pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Keybinds for the launcher's cheat-sheet tab, read straight from the Hyprland
// Lua config so the comments there become the descriptions. A bind's trailing
// "-- comment" describes it; otherwise the comment heading its block does;
// otherwise it's derived from what it dispatches.
Singleton {
    id: root

    // [{ keys, mods, desc }] in file order, runs of same-description binds merged
    property var binds: []

    readonly property var keyNames: ({
            Left: "←",
            Right: "→",
            Up: "↑",
            Down: "↓",
            Return: "Enter",
            Period: ".",
            Comma: ",",
            Minus: "−",
            bracketleft: "[",
            bracketright: "]",
            slash: "/",
            "mouse:272": "Left drag",
            "mouse:273": "Right drag",
            XF86AudioRaiseVolume: "Vol +",
            XF86AudioLowerVolume: "Vol −",
            XF86AudioMute: "Mute",
            XF86AudioMicMute: "Mic mute",
            XF86AudioNext: "Next",
            XF86AudioPrev: "Prev",
            XF86AudioPlay: "Play",
            XF86AudioPause: "Play",
            XF86MonBrightnessUp: "Bright +",
            XF86MonBrightnessDown: "Bright −"
        })
    readonly property var mediaKeys: ({
            XF86AudioRaiseVolume: "Volume up",
            XF86AudioLowerVolume: "Volume down",
            XF86AudioMute: "Mute speakers",
            XF86AudioMicMute: "Mute microphone",
            XF86AudioNext: "Next track",
            XF86AudioPrev: "Previous track",
            XF86AudioPlay: "Play / pause",
            XF86AudioPause: "Play / pause",
            XF86MonBrightnessUp: "Brightness up",
            XF86MonBrightnessDown: "Brightness down"
        })

    // Query words that name the same key differently
    readonly property var keyAliases: ({
            win: "super",
            mod: "super",
            meta: "super",
            control: "ctrl",
            return: "enter",
            left: "←",
            right: "→",
            up: "↑",
            down: "↓"
        })

    // Search descriptions, and key combos written any way round:
    // "Super + Q", "super q" and "q super" all find Super+Q (exact combos first)
    function search(query: string, limit: int): var {
        const q = query.trim().toLowerCase();
        if (q === "")
            return binds.slice(0, limit);
        const words = q.split(/[\s+]+/).filter(w => w).map(w => keyAliases[w] ?? w);
        const exact = [], partial = [], byDesc = [];
        for (const b of binds) {
            const keys = [...b.modList.map(m => m.toLowerCase()), ...b.keys.toLowerCase().split(" ")];
            const has = w => keys.some(k => k === w || (k === "1–0" && /^[0-9]$/.test(w)));
            if (words.every(has))
                (words.length === b.modList.length + 1 ? exact : partial).push(b);
            else if (b.desc.toLowerCase().includes(q))
                byDesc.push(b);
        }
        return [...exact, ...partial, ...byDesc].slice(0, limit);
    }

    function prettyKey(k: string): string {
        return keyNames[k] ?? (k.startsWith("XF86") ? k.slice(4) : k);
    }

    function prettyMods(mods: list<string>): string {
        return mods.map(m => m.charAt(0) + m.slice(1).toLowerCase()).join(" + ");
    }

    // Fallback description from the dispatcher expression
    function describe(dispatch: string, loopKey: bool): string {
        if (/focus\(\{\s*workspace\s*=\s*i\b/.test(dispatch))
            return "Go to workspace";
        if (/move\(\{\s*workspace\s*=\s*i\b/.test(dispatch))
            return "Move window to workspace";
        const cmd = dispatch.match(/exec_cmd\("([^"]+)"\)|uwsm_launch\("([^"]+)"\)/);
        if (cmd)
            return "Run " + (cmd[1] ?? cmd[2]);
        return dispatch.replace(/^hl\.dsp\./, "").replace(/\(.*$/, "");
    }

    function parse(text: string): void {
        // Join multi-line hl.bind( ... ) calls into single statements
        const statements = [];
        let pending = "";
        for (const line of text.split("\n")) {
            if (pending) {
                pending += " " + line.trim();
                if (balanced(pending)) {
                    statements.push(pending);
                    pending = "";
                }
            } else if (/^\s*hl\.bind\(/.test(line) && !balanced(line)) {
                pending = line.trim();
            } else {
                statements.push(line);
            }
        }

        const out = [];
        let heading = "";
        for (const st of statements) {
            const trimmed = st.trim();
            if (trimmed === "") {
                heading = "";
                continue;
            }
            const comment = trimmed.match(/^--\s*(.*)$/);
            if (comment) {
                // Plain prose comments head a block; banners and links don't
                heading = /^[#$]|https?:|^[A-Z0-9 ]+$/.test(comment[1]) ? "" : comment[1];
                continue;
            }
            const m = trimmed.match(/^hl\.bind\(\s*"([^"]*)"(\s*\.\.\s*\w+)?\s*,\s*(.*?)\)?\s*(?:--\s*(.*))?$/);
            if (!m)
                continue;
            const loop = !!m[2];
            const parts = m[1].split("+").map(p => p.trim()).filter(p => p);
            const key = loop ? "1–0" : parts.pop() ?? "";
            const mods = parts.filter(p => p === p.toUpperCase());
            const desc = mediaKeys[key] ?? m[4] ?? (heading || describe(m[3], loop));
            const prev = out[out.length - 1];
            if (prev && prev.desc === desc && prev.modList.join() === mods.join()) {
                if (!prev.keys.split(" ").includes(prettyKey(key)))
                    prev.keys += " " + prettyKey(key);
            } else {
                out.push({
                    keys: loop ? key : prettyKey(key),
                    modList: mods,
                    mods: prettyMods(mods),
                    desc: desc.charAt(0).toUpperCase() + desc.slice(1)
                });
            }
        }
        binds = out;
    }

    function balanced(s: string): bool {
        const noStrings = s.replace(/"[^"]*"/g, "");
        return (noStrings.match(/\(/g) ?? []).length <= (noStrings.match(/\)/g) ?? []).length;
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/hypr/hyprland/keybinds.lua"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parse(text())
    }
}
