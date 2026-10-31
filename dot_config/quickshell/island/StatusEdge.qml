import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Right-edge pill: CPU/GPU/RAM/network sparklines, tray and the date. Hover
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
        // optional second line (network: upload) and scale (default 0..1)
        property list<real> values2: []
        property color lineColor2: Theme.rose
        property real max: 1
        property color labelColor: Theme.muted

        implicitWidth: statRow.implicitWidth
        implicitHeight: statRow.implicitHeight

        Row {
            id: statRow
            spacing: 6
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: stat.label
                color: stat.labelColor
                font.pixelSize: Theme.fontSizeSmall
            }
            Sparkline {
                anchors.verticalCenter: parent.verticalCenter
                values: stat.values
                values2: stat.values2
                capacity: SysStats.historyLength
                color: stat.lineColor
                color2: stat.lineColor2
                max: stat.max
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

    // Download (foam) and upload (rose), scaled to the busiest moment of the
    // last minute but never below 64 KB/s, so idle chatter stays flat.
    Stat {
        label: "net"
        labelColor: Network.online ? Theme.muted : Theme.love
        values: SysStats.rxHistory
        lineColor: Theme.foam
        values2: SysStats.txHistory
        lineColor2: Theme.rose
        max: Math.max(65536, ...SysStats.rxHistory, ...SysStats.txHistory)
        tip: (Network.online ? "<b>" + (Network.type === "wifi" ? "Wi-Fi" : "Ethernet") + "</b> · " + Network.name : "<b>Offline</b>") + "<br><font color=\"" + Theme.foam + "\">↓</font> " + SysStats.rate(SysStats.rxRate) + "   <font color=\"" + Theme.rose + "\">↑</font> " + SysStats.rate(SysStats.txRate)
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
