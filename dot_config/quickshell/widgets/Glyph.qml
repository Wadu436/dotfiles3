import QtQuick
import qs.theme

// A single Nerd Font icon.
Text {
    property int size: Theme.iconSize

    color: Theme.text
    font.family: Theme.font
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation {
            duration: Theme.fast
        }
    }
}
