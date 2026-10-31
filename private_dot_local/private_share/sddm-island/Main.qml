import QtQuick
import QtQuick.Effects

// SDDM login screen in the style of the Quickshell island and hyprlock:
// blurred wallpaper with a darker column on the left holding the clock,
// date, user, password field and session/power controls.
Rectangle {
    id: root

    // Rosé Pine
    readonly property color base: "#191724"
    readonly property color overlay: "#26233a"
    readonly property color muted: "#6e6a86"
    readonly property color subtle: "#908caa"
    readonly property color text: "#e0def4"
    readonly property color love: "#eb6f92"
    readonly property color gold: "#f6c177"
    readonly property color foam: "#9ccfd8"
    readonly property color iris: "#c4a7e7"
    readonly property color highlightMed: "#403d52"
    readonly property color highlightHigh: "#524f67"
    readonly property string font: config.font || "JetBrainsMono Nerd Font"

    property int userIndex: Math.max(0, users.findIndex(u => u.name === userModel.lastUser))
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property var users: []
    property var sessions: []
    property bool failed: false
    property bool busy: false

    readonly property var user: users[userIndex] ?? {
        name: userModel.lastUser,
        realName: ""
    }

    function login(): void {
        if (busy)
            return;
        busy = true;
        failed = false;
        sddm.login(user.name, password.text, sessionIndex);
    }

    color: base

    // userModel/sessionModel are only readable through delegates
    Repeater {
        model: userModel
        Item {
            required property string name
            required property string realName
            Component.onCompleted: root.users = [...root.users, {
                    name,
                    realName
                }]
        }
    }
    Repeater {
        model: sessionModel
        Item {
            required property string name
            required property int index
            Component.onCompleted: {
                const s = [...root.sessions];
                s[index] = name;
                root.sessions = s;
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed(): void {
            root.busy = false;
            root.failed = true;
            password.text = "";
            shake.restart();
        }
        function onLoginSucceeded(): void {
            root.busy = false;
        }
    }

    // Background: blurred, dimmed wallpaper
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background || "background.jpg"
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true
    }
    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        blurEnabled: true
        blur: 0.5
        blurMax: 32
        brightness: -0.2
    }

    Timer {
        id: now
        property date date: new Date()
        interval: 1000
        running: true
        repeat: true
        onTriggered: date = new Date()
    }

    // Sidebar: a darker full-height column on the left holding everything
    Rectangle {
        id: sidebar

        readonly property int pad: 56

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 460
        color: Qt.alpha(root.base, 0.72)

        // Clock, date, user, password — vertically centered
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: sidebar.pad
            anchors.rightMargin: sidebar.pad
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: Qt.formatTime(now.date, "HH:mm")
                color: root.text
                font.family: root.font
                font.pixelSize: 96
                font.weight: Font.ExtraBold
            }
            Text {
                text: Qt.formatDate(now.date, "dddd d MMMM")
                color: root.subtle
                font.family: root.font
                font.pixelSize: 20
            }

            Item {
                width: 1
                height: 64
            }

            // Name; click to switch user when there are several
            Text {
                text: root.user.realName || root.user.name
                color: root.text
                font.family: root.font
                font.pixelSize: 18
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    enabled: root.users.length > 1
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.userIndex = (root.userIndex + 1) % root.users.length
                }
            }

            Item {
                width: 1
                height: 14
            }

            // Password field: dark fill with a thin solid outline that turns
            // love on a wrong password and gold with caps lock on
            Item {
                id: field
                width: parent.width
                height: 54

                SequentialAnimation {
                    id: shake
                    NumberAnimation { target: field; property: "x"; to: -12; duration: 50 }
                    NumberAnimation { target: field; property: "x"; to: 12; duration: 70 }
                    NumberAnimation { target: field; property: "x"; to: -8; duration: 60 }
                    NumberAnimation { target: field; property: "x"; to: 0; duration: 50 }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Qt.alpha(root.base, 0.85)
                    border.width: 2
                    border.color: root.failed ? root.love : keyboard.capsLock ? root.gold : root.highlightHigh

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: root.text
                    font.family: root.font
                    font.pixelSize: 18
                    font.letterSpacing: 4
                    focus: true
                    clip: true
                    enabled: !root.busy
                    onAccepted: root.login()
                    onTextEdited: root.failed = false

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: password.text === ""
                        text: root.busy ? "signing in…" : root.failed ? "wrong password" : keyboard.capsLock ? "caps lock is on" : "password"
                        color: root.failed ? root.love : keyboard.capsLock ? root.gold : root.muted
                        font.family: root.font
                        font.pixelSize: 15
                        font.letterSpacing: 0
                    }
                }
            }
        }

        // Session (click to cycle) + power, along the bottom of the column
        Row {
            anchors.left: parent.left
            anchors.leftMargin: sidebar.pad
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            spacing: 18

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍹  " + (root.sessions[root.sessionIndex] ?? "session")
                color: sessionMouse.containsMouse ? root.text : root.subtle
                font.family: root.font
                font.pixelSize: 14
                MouseArea {
                    id: sessionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.sessionIndex = (root.sessionIndex + 1) % Math.max(1, root.sessions.length)
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 18
                color: root.highlightMed
            }

            Repeater {
                model: [
                    { icon: "󰤄", enabled: sddm.canSuspend, act: () => sddm.suspend() },
                    { icon: "󰜉", enabled: sddm.canReboot, act: () => sddm.reboot() },
                    { icon: "󰐥", enabled: sddm.canPowerOff, act: () => sddm.powerOff() }
                ]
                Text {
                    required property var modelData
                    anchors.verticalCenter: parent.verticalCenter
                    visible: modelData.enabled
                    text: modelData.icon
                    color: powerMouse.containsMouse ? root.love : root.subtle
                    font.family: root.font
                    font.pixelSize: 18
                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.modelData.act()
                    }
                }
            }
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
