import QtQuick
import qs.services
import qs.config

Text {
    text: "Time: " + Time.time
    color: Config.appearance.palette.foreground
    font.pixelSize: 16
}