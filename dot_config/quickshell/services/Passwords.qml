pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Bitwarden entries via rbw, for the launcher's passwords tab. Mirrors the old
// rofi-rbw setup: Enter copies the password (cleared from the clipboard after
// 30s if still there) and sends a notification; Shift+Enter copies the user.
Singleton {
    id: root

    // [{ id, name, user, folder }]
    property var entries: []
    property bool locked: false
    property bool loading: false

    readonly property int clearAfter: 30 // seconds

    function refresh(): void {
        loading = true;
        unlockCheck.running = true;
    }

    function search(query: string, limit: int): var {
        if (locked)
            return [
                {
                    id: "",
                    name: "Unlock vault",
                    user: "",
                    folder: "rbw is locked — Enter to unlock",
                    unlock: true
                }
            ];
        const q = query.trim().toLowerCase();
        const hits = q === "" ? entries : entries.filter(e => e.name.toLowerCase().includes(q) || e.user.toLowerCase().includes(q) || e.folder.toLowerCase().includes(q));
        return hits.slice(0, limit);
    }

    function pick(e: var, alt: bool): void {
        if (e.unlock) {
            Quickshell.execDetached(["rbw", "unlock"]);
            return;
        }
        if (alt) {
            Quickshell.execDetached(["wl-copy", "--", e.user]);
            Quickshell.execDetached(["notify-send", "-a", "Bitwarden", "-i", "dialog-password", "Copied username", e.name]);
            return;
        }
        // Password goes from rbw straight into wl-copy; it never touches argv.
        Quickshell.execDetached(["sh", "-c", `
            pw=$(rbw get "$1") || exit 1
            printf %s "$pw" | wl-copy
            notify-send -a Bitwarden -i dialog-password "Copied password" "$2 — clears in ${clearAfter}s"
            sleep ${clearAfter}
            [ "$(wl-paste -n 2>/dev/null)" = "$pw" ] && wl-copy --clear`, "sh", e.id, e.name]);
    }

    Process {
        id: unlockCheck
        command: ["rbw", "unlocked"]
        onExited: code => {
            root.locked = code !== 0;
            if (root.locked)
                root.loading = false;
            else
                list.running = true;
        }
    }

    Process {
        id: list
        command: ["rbw", "list", "--fields", "id,name,user,folder"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(l => l !== "").map(l => {
                    const [id, name, user, folder] = l.split("\t");
                    return {
                        id,
                        name: name ?? "",
                        user: user ?? "",
                        folder: folder ?? ""
                    };
                }).sort((a, b) => a.name.localeCompare(b.name));
                root.loading = false;
            }
        }
    }
}
