pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Primary connection from NetworkManager, refreshed on nmcli monitor events.
Singleton {
    id: root

    property string type: "" // "ethernet" | "wifi" | ""
    property string name: ""
    readonly property bool online: type !== ""

    Process {
        id: query
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.type = "";
                root.name = "";
                for (const line of text.trim().split("\n")) {
                    // TYPE and STATE never contain ':'; CONNECTION may, escaped as '\:'
                    const [type, state, ...rest] = line.split(":");
                    if (state === "connected" && (type === "ethernet" || type === "wifi")) {
                        root.type = type;
                        root.name = rest.join(":").replace(/\\:/g, ":");
                        break;
                    }
                }
            }
        }
    }

    Process {
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: refresh.restart()
        }
    }

    Timer {
        id: refresh
        interval: 300
        onTriggered: query.running = true
    }
}
