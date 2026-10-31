import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.theme
import qs.services
import qs.widgets

// Search-first picker with tabs: apps (SUPER+D), windows (SUPER+Tab), emoji
// (SUPER+.), clipboard history (SUPER+V), passwords (SUPER+B) and a keybind
// cheat sheet (SUPER+/). Type to
// filter, ↑/↓ or Tab to move, Enter to pick (Shift+Enter: alternate action),
// Ctrl+Tab to switch tabs, Esc to close.
Item {
    id: root

    readonly property var modes: [
        {
            id: "apps",
            label: "Apps",
            placeholder: "Search apps…"
        },
        {
            id: "windows",
            label: "Windows",
            placeholder: "Switch to window…"
        },
        {
            id: "emoji",
            label: "Emoji",
            placeholder: "Search emoji…"
        },
        {
            id: "clips",
            label: "Clipboard",
            placeholder: "Search clipboard…"
        },
        {
            id: "keys",
            label: "Keys",
            placeholder: "Search keybinds…"
        },
        {
            id: "passwords",
            label: "Passwords",
            placeholder: "Search vault…  (→ all fields, Shift+Enter username)"
        }
    ]
    readonly property string mode: Shell.launcherMode
    readonly property var modeInfo: modes.find(m => m.id === mode) ?? modes[0]

    property int selected: 0
    readonly property var results: {
        switch (mode) {
        case "emoji":
            return Emoji.search(input.text, 8);
        case "clips":
            return Clips.search(input.text, 8);
        case "windows":
            return Windows.search(input.text, 8);
        case "keys":
            return Keybinds.search(input.text, 8);
        case "passwords":
            return Passwords.fieldsOf ? Passwords.searchFields(input.text, 8) : Passwords.search(input.text, 8);
        default:
            return Apps.search(input.text, 8);
        }
    }

    function pick(item: var, alt: bool): void {
        if (!item)
            return;
        // Act first, close after: closing destroys this launcher, whose cleanup
        // resets state (like the open password entry) the action still needs.
        switch (mode) {
        case "emoji":
            Emoji.pick(item);
            break;
        case "clips":
            Clips.pick(item);
            break;
        case "windows":
            Windows.pick(item);
            break;
        case "keys":
            break; // reference only
        case "passwords":
            if (Passwords.fieldsOf)
                Passwords.copyField(Passwords.fieldsOf, item.name);
            else
                Passwords.pick(item, alt);
            break;
        default:
            Apps.launch(item);
        }
        Shell.close();
    }

    function move(delta: int): void {
        if (results.length > 0)
            selected = (selected + delta + results.length) % results.length;
    }

    function cycleMode(delta: int): void {
        const i = modes.findIndex(m => m.id === mode);
        Shell.launcherMode = modes[(i + delta + modes.length) % modes.length].id;
    }

    // Passwords: → / Ctrl+Enter opens an entry's fields, ← / Esc goes back
    function openFields(item: var): bool {
        if (mode !== "passwords" || Passwords.fieldsOf || !item || item.unlock)
            return false;
        Passwords.openFields(item);
        input.text = "";
        return true;
    }

    function closeFields(): bool {
        if (!Passwords.fieldsOf)
            return false;
        Passwords.closeFields();
        input.text = "";
        return true;
    }

    // Returns whether the key was handled; unhandled keys edit the text, and an
    // unhandled Esc bubbles up to the island, which closes the launcher.
    function handleKey(e: var): bool {
        const ctrl = e.modifiers & Qt.ControlModifier;
        const enter = e.key === Qt.Key_Return || e.key === Qt.Key_Enter;
        const item = results[selected] ?? null;

        if (ctrl && e.key === Qt.Key_Tab)
            cycleMode(1);
        else if (ctrl && e.key === Qt.Key_Backtab)
            cycleMode(-1);
        else if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab)
            move(1);
        else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab)
            move(-1);
        else if (enter && ctrl)
            openFields(item);
        else if (enter)
            pick(item, e.modifiers & Qt.ShiftModifier);
        else if (e.key === Qt.Key_Right && input.cursorPosition === input.text.length)
            return openFields(item);
        else if (e.key === Qt.Key_Left && input.text === "")
            return closeFields();
        else if (e.key === Qt.Key_Escape)
            return closeFields();
        else
            return false;
        return true;
    }

    // Window focus order and the vault are fetched fresh each time their tab opens
    function refreshMode(): void {
        Passwords.closeFields();
        if (mode === "windows")
            Windows.refresh();
        else if (mode === "passwords")
            Passwords.refresh();
    }

    onResultsChanged: selected = 0
    onModeChanged: {
        input.text = "";
        refreshMode();
    }
    Component.onCompleted: refreshMode()
    Component.onDestruction: Passwords.closeFields()

    implicitWidth: 580
    implicitHeight: col.implicitHeight + 2 * 14

    // Focusing the text field in the same frame the panel opens makes Hyprland
    // drop the island's focus grab (closing the panel again), so wait a beat.
    Timer {
        interval: 120
        running: true
        onTriggered: input.forceActiveFocus()
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // Tabs
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.modes

                Rectangle {
                    id: tab
                    required property var modelData
                    readonly property bool current: modelData.id === root.mode

                    implicitWidth: tabLabel.implicitWidth + 24
                    implicitHeight: 28
                    radius: 14
                    color: current ? Theme.iris : tabMouse.containsMouse ? Theme.highlightMed : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.fast
                        }
                    }

                    Label {
                        id: tabLabel
                        anchors.centerIn: parent
                        text: tab.modelData.label
                        color: tab.current ? Theme.base : Theme.subtle
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: tab.current
                    }
                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Shell.launcherMode = tab.modelData.id;
                            input.forceActiveFocus();
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
            Label {
                text: "Ctrl+Tab"
                color: Theme.muted
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        // Search field
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            radius: 14
            color: Theme.card

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Glyph {
                    text: Icons.search
                    color: Theme.iris
                    size: 18
                }

                TextInput {
                    id: input
                    Layout.fillWidth: true
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSizeLarge
                    selectionColor: Qt.alpha(Theme.iris, 0.4)
                    selectedTextColor: Theme.text
                    clip: true

                    Keys.onPressed: e => {
                        e.accepted = root.handleKey(e);
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: Passwords.fieldsOf && root.mode === "passwords" ? "‹ " + Passwords.fieldsOf.name + "  —  pick a field to copy" : root.modeInfo.placeholder
                        color: Theme.muted
                        font.pixelSize: Theme.fontSizeLarge
                    }
                }
            }
        }

        // Results
        Repeater {
            model: ScriptModel {
                values: [...root.results]
            }

            Rectangle {
                id: row

                required property var modelData
                required property int index
                readonly property bool current: index === root.selected

                readonly property string title: {
                    switch (root.mode) {
                    case "emoji":
                        return modelData.name.charAt(0).toUpperCase() + modelData.name.slice(1);
                    case "clips":
                        return modelData.image !== "" ? "Image" : modelData.value.trim().split("\n")[0];
                    case "windows":
                        return modelData.title || modelData.wayland?.appId || "";
                    case "keys":
                        return modelData.desc;
                    case "passwords":
                        return Passwords.fieldsOf ? Passwords.describe(modelData).title : modelData.name;
                    default:
                        return modelData.name;
                    }
                }
                readonly property string subtitle: {
                    switch (root.mode) {
                    case "emoji":
                        return modelData.group;
                    case "clips":
                        {
                            const lines = modelData.value.trim().split("\n").length;
                            return [modelData.pinned ? "pinned" : "", Clips.age(modelData, Time.now), lines > 1 ? lines + " lines" : ""].filter(s => s).join("  ·  ");
                        }
                    case "windows":
                        return (modelData.wayland?.appId ?? "") + "  ·  workspace " + (modelData.workspace?.id ?? "?");
                    case "keys":
                        return (modelData.mods ? modelData.mods + " + " : "") + modelData.keys;
                    case "passwords":
                        if (Passwords.fieldsOf)
                            return Passwords.describe(modelData).hint;
                        return [modelData.user, modelData.folder].filter(s => s).join("  ·  ");
                    default:
                        return modelData.genericName || modelData.comment || "";
                    }
                }

                Layout.fillWidth: true
                implicitHeight: 48
                radius: 12
                color: current ? Qt.alpha(Theme.iris, 0.18) : "transparent"
                border.width: current ? 1 : 0
                border.color: Qt.alpha(Theme.iris, 0.6)

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.fast
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    // Leading visual: app icon, the emoji itself, or a clip preview
                    Item {
                        implicitWidth: 32
                        implicitHeight: 32

                        IconImage {
                            anchors.centerIn: parent
                            visible: root.mode === "apps" || root.mode === "windows"
                            implicitSize: 30
                            source: {
                                if (root.mode === "apps")
                                    return Quickshell.iconPath(row.modelData.icon, "application-x-executable");
                                if (root.mode === "windows") {
                                    const appId = row.modelData.wayland?.appId ?? "";
                                    const entry = appId ? DesktopEntries.heuristicLookup(appId) : null;
                                    return Quickshell.iconPath(entry?.icon ?? appId, "application-x-executable");
                                }
                                return "";
                            }
                            asynchronous: true
                        }
                        // Website favicon for vault entries, 🔑 for the rest
                        Image {
                            id: favicon
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            visible: root.mode === "passwords" && status === Image.Ready
                            source: root.mode === "passwords" && !Passwords.fieldsOf && !row.modelData.unlock ? Favicons.icon(row.modelData.domain ?? "") : ""
                            sourceSize: Qt.size(48, 48)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.mode === "keys"
                            text: "⌨️"
                            font.pixelSize: 20
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.mode === "passwords" && !favicon.visible
                            text: "🔑"
                            font.pixelSize: 20
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.mode === "emoji"
                            text: root.mode === "emoji" ? row.modelData.emoji : ""
                            font.pixelSize: 24
                        }
                        Rectangle {
                            anchors.fill: parent
                            visible: root.mode === "clips"
                            radius: 8
                            color: Theme.tile
                            clip: true

                            Image {
                                anchors.fill: parent
                                visible: source != ""
                                source: root.mode === "clips" && row.modelData.image !== "" ? "file://" + row.modelData.image : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(64, 64)
                                asynchronous: true
                            }
                            Label {
                                anchors.centerIn: parent
                                visible: root.mode === "clips" && row.modelData.image === ""
                                text: "Aa"
                                color: Theme.subtle
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            Layout.fillWidth: true
                            text: row.title
                            color: row.current ? Theme.text : Theme.subtle
                            font.bold: row.current
                        }
                        Label {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: row.subtitle
                            color: Theme.muted
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.selected = row.index
                    onClicked: m => root.pick(row.modelData, m.modifiers & Qt.ShiftModifier)
                }
            }
        }

        Label {
            visible: root.results.length === 0
            Layout.fillWidth: true
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            horizontalAlignment: Text.AlignHCenter
            text: root.mode === "passwords" && Passwords.loading ? "Loading vault…" : input.text === "" ? "Nothing here yet" : "No matches for “" + input.text + "”"
            color: Theme.muted
        }
    }
}
