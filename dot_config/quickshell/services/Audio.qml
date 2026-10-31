pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default sink/source, device lists and per-app playback streams.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Filter on flags, not properties["media.class"]: properties stay empty
    // until a node is bound, and binding is what the tracker below does.
    // Playback streams count as sinks (they take audio from an app).
    readonly property list<PwNode> sinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property list<PwNode> sources: Pipewire.nodes.values.filter(n => n.audio && !n.isSink && !n.isStream)
    readonly property list<PwNode> streams: Pipewire.nodes.values.filter(n => n.audio && n.isSink && n.isStream)

    function setVolume(node: PwNode, v: real): void {
        if (!node?.audio)
            return;
        node.audio.muted = false;
        node.audio.volume = Math.max(0, Math.min(1, v));
    }

    function nudge(delta: real): void {
        setVolume(sink, volume + delta);
    }

    function toggleMute(node: PwNode): void {
        if (node?.audio)
            node.audio.muted = !node.audio.muted;
    }

    function nodeName(node: PwNode): string {
        if (!node)
            return "";
        return node.properties["application.name"] || node.nickname || node.description || node.name;
    }

    // Nodes only report volume/mute while bound by a tracker.
    PwObjectTracker {
        objects: [...root.sinks, ...root.sources, ...root.streams]
    }

    // Volume changes (keys, scroll, other apps) flash the OSD. Ignore the burst
    // of changes while a sink first binds or the default device switches.
    property bool settled: false
    onSinkChanged: {
        settled = false;
        settleTimer.restart();
    }
    Timer {
        id: settleTimer
        interval: 800
        running: true
        onTriggered: root.settled = true
    }
    onVolumeChanged: if (settled) Shell.showOsd()
    onMutedChanged: if (settled) Shell.showOsd()
}
