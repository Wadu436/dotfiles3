pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Night light via hyprsunset (schedule in ~/.config/hypr/hyprsunset.conf).
// Toggling overrides the schedule until its next profile switch.
Singleton {
    id: root

    readonly property int warmTemperature: 4000 // K, matches the evening profile
    // "Off" is a neutral 6500K, not identity: the temperature query can't tell
    // identity apart, so the toggle couldn't read its own state back.
    readonly property int neutralTemperature: 6500
    property int temperature: neutralTemperature
    property bool available: false
    readonly property bool on: available && temperature < neutralTemperature

    function refresh(): void {
        query.running = true;
    }

    function toggle(): void {
        set.command = ["hyprctl", "hyprsunset", "temperature", String(on ? neutralTemperature : warmTemperature)];
        set.running = true;
    }

    Process {
        id: query
        command: ["hyprctl", "hyprsunset", "temperature"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const t = parseInt(text.trim());
                root.available = !isNaN(t);
                if (root.available)
                    root.temperature = t;
            }
        }
    }

    Process {
        id: set
        onExited: root.refresh()
    }

    // The schedule can switch on its own; keep the toggle honest
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
