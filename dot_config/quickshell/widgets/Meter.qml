import QtQuick
import QtQuick.Layouts
import qs.theme

// Labelled horizontal usage bar: icon, name, bar, value text.
RowLayout {
    id: root

    property string icon
    property string label
    property real value: 0 // 0..1
    property string valueText: Math.round(value * 100) + "%"
    property color barColor: Theme.iris
    property color valueColor: Theme.subtle

    spacing: Theme.spacing

    Glyph {
        text: root.icon
        color: Theme.subtle
        Layout.preferredWidth: 20
    }
    Label {
        text: root.label
        color: Theme.subtle
        Layout.preferredWidth: 40
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 6
        radius: 3
        color: Theme.highlightMed

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: parent.radius
            color: root.barColor

            Behavior on width {
                NumberAnimation {
                    duration: Theme.normal
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
    Label {
        text: root.valueText
        color: root.valueColor
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 80
    }
}
