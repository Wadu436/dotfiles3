pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

// What's recording you right now: microphone and camera from PipeWire capture
// streams, screen sharing from Hyprland's screencast events. Each list holds
// the names of the apps doing it.
Singleton {
    id: root

    // Plain arrays: a list<string> type turned [] into [""] elsewhere
    readonly property var mic: appsCapturing(n => cls(n) === "Stream/Input/Audio" && !isMeter(n))
    readonly property var camera: appsCapturing(n => cls(n) === "Stream/Input/Video" && sourceOf(n) && !isScreenSource(sourceOf(n)))
    property bool screen: false

    readonly property bool active: mic.length > 0 || camera.length > 0 || screen

    function cls(n: PwNode): string {
        return n?.properties["media.class"] ?? "";
    }

    // Level meters (e.g. pavucontrol's VU bars) open capture streams too
    function isMeter(n: PwNode): bool {
        return /peak detect/i.test(n.properties["media.name"] ?? "");
    }

    // The screen-sharing portal (xdph) shows up as a video source as well
    function isScreenSource(n: PwNode): bool {
        return /^xdph|screen|xdg-desktop-portal/i.test(n.name + " " + (n.properties["node.description"] ?? ""));
    }

    function sourceOf(stream: PwNode): PwNode {
        return Pipewire.linkGroups.values.find(g => g.target === stream)?.source ?? null;
    }

    function appsCapturing(match: var): var {
        const names = Pipewire.nodes.values.filter(n => n.isStream && match(n)).map(n => n.properties["application.name"] || n.properties["node.name"] || "unknown app");
        return [...new Set(names)];
    }

    // media.class and friends are only filled in for bound nodes
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.isStream || !n.audio)
    }

    // "screencast>>1,0": first field is 1 while a screencast/screencopy runs
    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "screencast")
                root.screen = event.data.split(",")[0] === "1";
        }
    }
}
