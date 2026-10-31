import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.theme
import qs.services

// One notification: icon, app · age, summary, body, image and actions.
// `compact` trims the body for history lists.
Rectangle {
    id: root

    required property Notification notif
    property bool compact: false
    readonly property bool hovered: hover.hovered

    // notify-send -i puts its argument in the image hint, which Quickshell hands
    // over as image://icon/<theme icon name> or image://icon//<file path>.
    // Theme icons go in the small icon slot; files (screenshots, avatars) and
    // raw image data are pictures and get previewed as content.
    readonly property string iconScheme: "image://icon/"
    readonly property bool imageIsFile: notif.image.startsWith(iconScheme + "/")
    readonly property bool imageIsIcon: notif.image.startsWith(iconScheme) && !imageIsFile
    readonly property string iconSource: {
        if (notif.appIcon !== "" && !notif.appIcon.includes("/"))
            return Quickshell.iconPath(notif.appIcon, true);
        return imageIsIcon ? notif.image : "";
    }
    readonly property string contentImage: {
        if (imageIsFile)
            return "file://" + notif.image.slice(iconScheme.length);
        if (notif.image !== "" && !imageIsIcon)
            return notif.image;
        return notif.appIcon.startsWith("/") ? "file://" + notif.appIcon : "";
    }

    // "default" is what a click on the notification itself should do (kitty:
    // focus the window that sent it), so it isn't shown as a button.
    readonly property var defaultAction: notif.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notif.actions.filter(a => a.identifier !== "default")

    // Emitted on any click on the card or one of its buttons; `ranAction` is
    // false for a body click on a notification without a default action.
    signal activated(bool ranAction)

    function invoke(action: var): void {
        if (action)
            action.invoke();
        root.activated(action !== null);
    }

    implicitHeight: layout.implicitHeight + 2 * 12
    radius: 14
    color: compact ? Theme.surface : "transparent"
    border.width: notif.urgency === NotificationUrgency.Critical ? 1 : 0
    border.color: Theme.love

    HoverHandler {
        id: hover
    }

    // Body click → default action. Declared before the content, so the close
    // and action buttons (inside the content) sit on top and win their clicks.
    MouseArea {
        anchors.fill: parent
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.invoke(root.defaultAction)
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // App icon, falling back to the first letter of the app name
        Rectangle {
            Layout.alignment: Qt.AlignTop
            implicitWidth: 36
            implicitHeight: 36
            radius: 10
            color: Theme.overlay

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                implicitSize: 24
                source: root.iconSource
                visible: root.iconSource !== "" && status !== Image.Error
            }
            Label {
                anchors.centerIn: parent
                visible: !appIcon.visible
                text: (root.notif.appName || "?").charAt(0).toUpperCase()
                color: Theme.iris
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: root.notif.appName + "  ·  " + Notifs.age(root.notif, Time.now)
                    color: Theme.muted
                    font.pixelSize: Theme.fontSizeSmall
                }
                Glyph {
                    text: Icons.close
                    size: 14
                    color: closeMouse.containsMouse ? Theme.love : Theme.muted
                    opacity: root.hovered ? 1 : 0
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.notif.dismiss()
                    }
                }
            }
            Label {
                Layout.fillWidth: true
                text: root.notif.summary
                font.bold: true
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notif.body
                textFormat: Text.StyledText
                color: Theme.subtle
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                wrapMode: Text.Wrap
                maximumLineCount: root.compact ? 2 : 5
                elide: Text.ElideRight
                linkColor: Theme.foam
                onLinkActivated: link => Qt.openUrlExternally(link)
            }
            Image {
                Layout.fillWidth: true
                Layout.maximumHeight: 140
                Layout.topMargin: 6
                visible: !root.compact && root.contentImage !== "" && status === Image.Ready
                source: root.compact ? "" : root.contentImage
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
                asynchronous: true
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                visible: root.buttons.length > 0
                spacing: 6
                Repeater {
                    model: root.buttons
                    Rectangle {
                        id: action
                        required property NotificationAction modelData
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 8
                        color: actionMouse.containsMouse ? Theme.highlightMed : Theme.overlay
                        Label {
                            anchors.centerIn: parent
                            width: parent.width - 12
                            horizontalAlignment: Text.AlignHCenter
                            text: action.modelData.text
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.invoke(action.modelData)
                        }
                    }
                }
            }
        }
    }
}
