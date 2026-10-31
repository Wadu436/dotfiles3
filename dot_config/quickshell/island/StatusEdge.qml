import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Right-edge pill: CPU/GPU/RAM sparklines, network, tray and the date. Hover
// any of them for the exact numbers / a plain-language explanation.
RowLayout {
    id: root

    spacing: Theme.spacing + 4

    Component.onCompleted: SysStats.users++
    Component.onDestruction: SysStats.users--

    function pct(v: real): string {
        return Math.round(v * 100) + "%";
    }

    // Label + sparkline of the last minute. The line turns gold/red when the
    // part runs hot; exact numbers are in the hover tip.
    component Stat: Item {
        id: stat

        required property string label
        required property list<real> values
        required property color lineColor
        required property string tip

        implicitWidth: statRow.implicitWidth
        implicitHeight: statRow.implicitHeight

        Row {
            id: statRow
            spacing: 6
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: stat.label
                color: Theme.muted
                font.pixelSize: Theme.fontSizeSmall
            }
            Sparkline {
                anchors.verticalCenter: parent.verticalCenter
                values: stat.values
                capacity: SysStats.historyLength
                color: stat.lineColor
            }
        }
        HoverTip {
            text: stat.tip
        }
    }

    function heat(t: int, normal: color): color {
        return t >= 85 ? Theme.love : t >= 75 ? Theme.gold : normal;
    }

    Stat {
        label: "cpu"
        values: SysStats.cpuHistory
        lineColor: root.heat(SysStats.cpuTemp, Theme.iris)
        tip: "<b>CPU</b> load " + root.pct(SysStats.cpu) + "<br>temperature " + SysStats.cpuTemp + "°C"
    }

    Stat {
        label: "gpu"
        values: SysStats.gpuHistory
        lineColor: root.heat(SysStats.gpuTemp, Theme.foam)
        tip: "<b>GPU</b> load " + root.pct(SysStats.gpu) + "<br>temperature " + SysStats.gpuTemp + "°C"
    }

    Stat {
        label: "ram"
        values: SysStats.memHistory
        lineColor: SysStats.mem >= 0.9 ? Theme.love : SysStats.mem >= 0.75 ? Theme.gold : Theme.rose
        tip: "<b>RAM</b> in use<br>" + SysStats.memUsedGb.toFixed(1) + " of " + Math.round(SysStats.memTotalGb) + " GB (" + root.pct(SysStats.mem) + ")"
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
