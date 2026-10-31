import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.theme
import qs.services
import qs.widgets

// System tray icons. Left click activates, middle click is the secondary
// action, right click (or any click on menu-only items) opens the menu.
Row {
    id: root

    property int iconSize: 16

    spacing: 4

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: trayItem

            required property SystemTrayItem modelData

            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.iconSize + 10
            implicitHeight: root.iconSize + 10
            radius: height / 2
            color: trayMouse.containsMouse || menuAnchor.visible ? Theme.highlightMed : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Theme.fast
                }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: root.iconSize
                source: trayItem.modelData.icon
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: m => {
                    const item = trayItem.modelData;
                    if (m.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (m.button === Qt.RightButton || item.onlyMenu) {
                        if (item.hasMenu)
                            menuAnchor.open();
                    } else {
                        item.activate();
                    }
                }
            }

            HoverTip {
                text: menuAnchor.visible ? "" : (trayItem.modelData.tooltipTitle || trayItem.modelData.title || trayItem.modelData.id)
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData.menu
                anchor.item: trayItem
                anchor.edges: Edges.Bottom | Edges.Left
                anchor.gravity: Edges.Bottom | Edges.Right
                onVisibleChanged: Shell.menuOpen = visible
                Component.onDestruction: if (visible) Shell.menuOpen = false
            }
        }
    }
}
