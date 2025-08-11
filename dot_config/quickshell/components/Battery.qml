import QtQuick
import qs.config
import Quickshell.Services.UPower

Text {
    text: "Battery: " + Math.round(100*UPower.displayDevice.percentage) + "%"
    color: Config.appearance.palette.foreground
    font.pixelSize: 16
}