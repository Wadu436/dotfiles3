pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The "current" MPRIS player: the one playing, else the last one that was.
Singleton {
    id: root

    readonly property list<MprisPlayer> players: Mpris.players.values
    property MprisPlayer lastPlaying: null

    readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? (players.includes(lastPlaying) ? lastPlaying : players[0] ?? null)

    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""

    onPlayerChanged: if (player?.isPlaying) lastPlaying = player

    Connections {
        target: root.player
        function onIsPlayingChanged() {
            if (root.player.isPlaying)
                root.lastPlaying = root.player;
        }
    }
}
