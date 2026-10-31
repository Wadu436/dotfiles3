import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets

// The oldest queued notification, with a "+N more" hint. Times out per
// urgency; the clock pauses while hovered.
Item {
    id: root

    property bool shown: false
    readonly property var notif: Notifs.popups[0] ?? null

    anchors.horizontalCenter: parent.horizontalCenter
    implicitWidth: 420
    implicitHeight: col.implicitHeight + 8
    opacity: shown ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.normal
        }
    }

    Timer {
        id: timer
        interval: root.notif ? Notifs.timeout(root.notif) : 0
        running: root.shown && interval > 0 && !(card.item?.hovered ?? false)
        onTriggered: Notifs.dropPopup(root.notif)
    }
    // A new notification at the head of the queue gets its full time
    onNotifChanged: timer.restart()

    ColumnLayout {
        id: col
        anchors.top: parent.top
        anchors.topMargin: 4
        width: parent.width
        spacing: 0

        Loader {
            id: card
            Layout.fillWidth: true
            active: root.notif !== null
            sourceComponent: NotifCard {
                notif: root.notif
                onActionInvoked: Notifs.dropPopup(notif)

                // Clicking the body just puts it away; it stays in history
                TapHandler {
                    onTapped: Notifs.dropPopup(parent.notif)
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 6
            visible: Notifs.popups.length > 1
            text: "+" + (Notifs.popups.length - 1) + " more"
            color: Theme.muted
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
