import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// Right-edge pill: temperatures, network, tray and the date.
RowLayout {
    id: root

    spacing: Theme.spacing + 4

    Component.onCompleted: SysStats.users++
    Component.onDestruction: SysStats.users--

    RowLayout {
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
        Glyph {
            Layout.leftMargin: 4
            text: Icons.gpu
            color: Theme.muted
            size: 14
        }
        Label {
            text: SysStats.gpuTemp + "°"
            color: SysStats.tempColor(SysStats.gpuTemp)
        }
    }

    Glyph {
        text: Network.type === "wifi" ? Icons.wifi : Network.online ? Icons.ethernet : Icons.offline
        color: Network.online ? Theme.subtle : Theme.love
        size: 14
    }

    Tray {
        visible: children.length > 1 // the Repeater itself is a child
    }

    Label {
        text: Time.format("ddd d MMM")
        color: Theme.subtle
    }
}
