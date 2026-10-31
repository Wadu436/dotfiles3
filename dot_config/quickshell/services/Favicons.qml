pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Website favicons for the passwords tab, from Bitwarden's icon service (what
// the official Bitwarden clients use). Fetched lazily, one at a time, only for
// domains actually shown, and cached on disk; misses are remembered too so a
// domain is requested at most once. Local hosts and IPs are never looked up.
Singleton {
    id: root

    readonly property string dir: Quickshell.cachePath("favicons")

    // domain → "ok" | "none" (known), absent = not fetched yet
    property var known: ({})
    property var queue: []
    property bool scanned: false

    // "https://www.example.com:8080/login" → "www.example.com"; "" if local
    function domainOf(uri: string): string {
        const host = (uri ?? "").replace(/^[a-z][a-z0-9+.-]*:\/\//i, "").split(/[\/:?#]/)[0].toLowerCase();
        // Only plain hostnames: the domain ends up in a file name and a URL
        if (!/^[a-z0-9.-]+$/.test(host))
            return "";
        const local = /^[0-9.]+$/.test(host) || !host.includes(".") || /(\.lan|\.local|\.home|\.internal|\.ts\.net)$/.test(host);
        return local ? "" : host;
    }

    // file:// URL of the cached icon, or "" (and queues a fetch if unknown)
    function icon(domain: string): string {
        if (!domain)
            return "";
        const state = known[domain];
        if (state === "ok")
            return "file://" + dir + "/" + domain + ".png";
        // Called from bindings, so queue the fetch outside the evaluation
        if (state === undefined && scanned)
            Qt.callLater(enqueue, domain);
        return "";
    }

    function enqueue(domain: string): void {
        if (known[domain] !== undefined || queue.includes(domain) || fetcher.domain === domain && fetcher.running)
            return;
        queue = [...queue, domain];
        next();
    }

    function mark(domain: string, state: string): void {
        known = Object.assign({}, known, {
            [domain]: state
        });
    }

    function next(): void {
        if (fetcher.running || queue.length === 0)
            return;
        fetcher.domain = queue[0];
        queue = queue.slice(1);
        fetcher.running = true;
    }

    // Learn what's already cached before fetching anything
    Process {
        running: true
        command: ["sh", "-c", 'mkdir -p "$1" && cd "$1" && ls', "sh", root.dir]
        stdout: StdioCollector {
            onStreamFinished: {
                const known = {};
                for (const f of text.split("\n")) {
                    if (f.endsWith(".png"))
                        known[f.slice(0, -4)] = "ok";
                    else if (f.endsWith(".none"))
                        known[f.slice(0, -5)] = "none";
                }
                root.known = known;
                root.scanned = true;
            }
        }
    }

    Process {
        id: fetcher

        property string domain

        // Bitwarden serves a generic globe for unknown sites, which we keep:
        // it still beats the key fallback for a website entry.
        command: ["sh", "-c", `
            cd "$1" || exit 1
            if curl -fsS --max-time 8 -o "$2.tmp" "https://icons.bitwarden.net/$2/icon.png" && [ -s "$2.tmp" ]; then
                mv "$2.tmp" "$2.png"
            else
                rm -f "$2.tmp"; touch "$2.none"; exit 1
            fi`, "sh", root.dir, domain]
        onExited: code => {
            root.mark(domain, code === 0 ? "ok" : "none");
            root.next();
        }
    }
}
