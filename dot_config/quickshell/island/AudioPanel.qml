import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.theme
import qs.services
import qs.widgets

// Mixer: output + mic with device pickers, then one slider per playing app.
Item {
    id: root

    implicitWidth: 400
    implicitHeight: col.implicitHeight + 2 * 18

    component SectionTitle: Label {
        color: Theme.muted
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 1
    }

    // Device row: mute button, name (click to pick another device), slider
    component DeviceControl: ColumnLayout {
        id: dc

        required property PwNode node
        required property list<PwNode> choices
        required property string iconOn
        required property string iconOff
        required property bool isSink
        property bool picking: false

        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing

            IconButton {
                icon: dc.node?.audio?.muted ? dc.iconOff : dc.iconOn
                iconColor: dc.node?.audio?.muted ? Theme.muted : Theme.text
                onClicked: Audio.toggleMute(dc.node)
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                MouseArea {
                    Layout.fillWidth: true
                    implicitHeight: nameLabel.implicitHeight
                    cursorShape: dc.choices.length > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: dc.picking = !dc.picking
                    Label {
                        id: nameLabel
                        width: parent.width
                        text: (dc.node?.description ?? "No device") + (dc.choices.length > 1 ? (dc.picking ? "  ▴" : "  ▾") : "")
                        color: Theme.subtle
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
                Slider {
                    Layout.fillWidth: true
                    value: dc.node?.audio?.volume ?? 0
                    dimmed: dc.node?.audio?.muted ?? false
                    onMoved: v => Audio.setVolume(dc.node, v)
                }
            }
            Label {
                text: Math.round((dc.node?.audio?.volume ?? 0) * 100) + "%"
                color: Theme.subtle
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 40
            }
        }

        // Device picker
        Repeater {
            model: dc.picking ? dc.choices : []
            Rectangle {
                id: choice
                required property PwNode modelData
                readonly property bool current: modelData === dc.node
                Layout.fillWidth: true
                Layout.leftMargin: 42
                implicitHeight: 30
                radius: 8
                color: choiceMouse.containsMouse ? Theme.highlightMed : current ? Theme.overlay : "transparent"
                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    text: choice.modelData.description
                    color: choice.current ? Theme.iris : Theme.text
                    font.pixelSize: Theme.fontSizeSmall
                }
                MouseArea {
                    id: choiceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (dc.isSink)
                            Pipewire.preferredDefaultAudioSink = choice.modelData;
                        else
                            Pipewire.preferredDefaultAudioSource = choice.modelData;
                        dc.picking = false;
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        SectionTitle {
            text: "Output"
        }
        DeviceControl {
            node: Audio.sink
            choices: Audio.sinks
            iconOn: Icons.volume(false, Audio.volume)
            iconOff: Icons.volumeOff
            isSink: true
        }

        SectionTitle {
            text: "Input"
        }
        DeviceControl {
            node: Audio.source
            choices: Audio.sources
            iconOn: Icons.mic
            iconOff: Icons.micOff
            isSink: false
        }

        SectionTitle {
            visible: Audio.streams.length > 0
            text: "Apps"
        }
        Repeater {
            model: Audio.streams
            RowLayout {
                id: stream
                required property PwNode modelData
                Layout.fillWidth: true
                spacing: Theme.spacing

                Label {
                    text: Audio.nodeName(stream.modelData)
                    Layout.preferredWidth: 110
                }
                Slider {
                    Layout.fillWidth: true
                    value: stream.modelData.audio?.volume ?? 0
                    dimmed: stream.modelData.audio?.muted ?? false
                    fill: Theme.foam
                    onMoved: v => Audio.setVolume(stream.modelData, v)
                }
                Label {
                    text: Math.round((stream.modelData.audio?.volume ?? 0) * 100) + "%"
                    color: Theme.subtle
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 40
                }
            }
        }
    }
}
