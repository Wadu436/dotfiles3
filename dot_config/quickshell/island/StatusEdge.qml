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

    // Live numbers are padded to a fixed width (the font is monospaced) so the
    // pill, and the tray next to it, doesn't twitch as values change.
    function fixed(s: string, width: int): string {
        return s.padStart(width, "\u2007");
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
                text: root.fixed(SysStats.cpuTemp + "°", 3)
                color: SysStats.tempColor(SysStats.cpuTemp)
            }
            Label {
                text: root.fixed(root.pct(SysStats.cpu), 4)
                color: Theme.muted
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
                text: root.fixed(SysStats.gpuTemp + "°", 3)
                color: SysStats.tempColor(SysStats.gpuTemp)
            }
            Label {
                text: root.fixed(root.pct(SysStats.gpu), 4)
                color: Theme.muted
            }
        }
        HoverTip {
            text: "<b>GPU</b> temperature " + SysStats.gpuTemp + "°C<br>load " + root.pct(SysStats.gpu)
        }
    }

    Item {
        implicitWidth: memRow.implicitWidth
        implicitHeight: memRow.implicitHeight

        RowLayout {
            id: memRow
            spacing: 6
            Glyph {
                text: Icons.memory
                color: Theme.muted
                size: 14
            }
            Label {
                text: root.fixed(SysStats.memUsedGb.toFixed(1) + "G", 5)
                color: SysStats.mem >= 0.9 ? Theme.love : SysStats.mem >= 0.75 ? Theme.gold : Theme.subtle
            }
            Label {
                text: root.fixed(root.pct(SysStats.mem), 4)
                color: Theme.muted
            }
        }
        HoverTip {
            text: "<b>RAM</b> in use<br>" + SysStats.memUsedGb.toFixed(1) + " of " + Math.round(SysStats.memTotalGb) + " GB (" + root.pct(SysStats.mem) + ")"
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
