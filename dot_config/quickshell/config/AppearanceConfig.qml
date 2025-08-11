import Quickshell.Io

JsonObject {
    property Palette palette: Palette {}

    component Palette: JsonObject {
        property string primary: "#7c3aed"     // vivid royal purple
        property string primaryLight: "#a78bfa"
        property string primaryDark: "#4c1d95"

        property string accent: "#9b5de5"      // softer secondary purple
        property string accentLight: "#d8b4fe"
        property string accentDark: "#5e239d"

        property string background: "#b01a1a1f"          // dark background
        property string backgroundLight: "#2a2a2f"    // slightly lighter panels
        property string backgroundDark: "#121217"     // darker panels
        property string foreground: "#f5f5f5"          // main text
        property string foregroundDim: "#a0a0b0"       // dim text

        property string hover: primaryLight
        property string active: primary
    }
}
