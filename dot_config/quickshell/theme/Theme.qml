pragma Singleton

import QtQuick
import Quickshell

// Rosé Pine palette and the shared sizing/motion tokens every surface uses.
Singleton {
    // Palette — https://rosepinetheme.com/palette
    readonly property color base: "#191724"
    readonly property color surface: "#1f1d2e"
    readonly property color overlay: "#26233a"
    readonly property color muted: "#6e6a86"
    readonly property color subtle: "#908caa"
    readonly property color text: "#e0def4"
    readonly property color love: "#eb6f92"
    readonly property color gold: "#f6c177"
    readonly property color rose: "#ebbcba"
    readonly property color pine: "#31748f"
    readonly property color foam: "#9ccfd8"
    readonly property color iris: "#c4a7e7"
    readonly property color highlightLow: "#21202e"
    readonly property color highlightMed: "#403d52"
    readonly property color highlightHigh: "#524f67"

    readonly property color islandBg: Qt.alpha(base, 0.88)
    readonly property color islandBorder: Qt.alpha(highlightMed, 0.7)

    readonly property string font: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeLarge: 16
    readonly property int iconSize: 16

    // Island geometry. The island and edge pills hang flush from the top edge;
    // Hyprland's gaps_out keeps windows clear of them.
    // Horizontal inset of the edge pills; matches Hyprland's gaps_out so they
    // line up with window edges.
    readonly property int screenMargin: 4
    readonly property int idleHeight: 34
    readonly property int radius: 17
    readonly property int panelRadius: 22
    readonly property int padding: 14
    readonly property int spacing: 10

    // Motion. The spring mirrors Hyprland's "easy" spring used for windows.
    readonly property int fast: 140
    readonly property int normal: 220
    readonly property real spring: 4.0
    readonly property real damping: 0.42
}
