import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Right-edge pill: temperatures, network, tray and the date. Hover any of
// them for a plain-language explanation.
RowLayout {
    id: root

    spacing: Theme.spacing + 4

    Component.onCompleted: SysStats.users++
    Component.onDestruction: SysStats.users--

    function pct(v: real): string {
        return Math.round(v * 100) + "%";
    }

    // HoverTip anchors to its parent, so it needs a plain Item, not a layout
    Item {
        implicitWidth: cpuRow.implicitWidth
        implicitHeight: cpuRow.implicitHeight

        RowLayout {
            id: cpuRow
            spacing: 6
            Glyph {
                text: Icons.cpu
                color: Theme.muted
                size: 14
            }
            Label {
                text: SysStats.cpuTemp + "°"
                color: SysStats.tempColor(SysStats.cpuTemp)
            }
        }
        HoverTip {
            text: "<b>CPU</b> temperature " + SysStats.cpuTemp + "°C<br>load " + root.pct(SysStats.cpu)
        }
    }

    Item {
        implicitWidth: gpuRow.implicitWidth
        implicitHeight: gpuRow.implicitHeight

        RowLayout {
            id: gpuRow
            spacing: 6
            Glyph {
                text: Icons.gpu
                color: Theme.muted
                size: 14
            }
            Label {
                text: SysStats.gpuTemp + "°"
                color: SysStats.tempColor(SysStats.gpuTemp)
            }
        }
        HoverTip {
            text: "<b>GPU</b> temperature " + SysStats.gpuTemp + "°C<br>load " + root.pct(SysStats.gpu)
        }
    }

    Glyph {
        text: Network.type === "wifi" ? Icons.wifi : Network.online ? Icons.ethernet : Icons.offline
        color: Network.online ? Theme.subtle : Theme.love
        size: 14
        HoverTip {
            text: Network.online ? "<b>" + (Network.type === "wifi" ? "Wi-Fi" : "Ethernet") + "</b><br>" + Network.name : "<b>Offline</b>"
        }
    }

    Tray {
        visible: children.length > 1 // the Repeater itself is a child
    }

    Label {
        text: Time.format("ddd d MMM")
        color: Theme.subtle
        HoverTip {
            text: Time.format("dddd d MMMM yyyy")
        }
    }
}
