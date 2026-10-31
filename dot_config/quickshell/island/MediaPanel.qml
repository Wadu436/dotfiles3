import QtQuick
import qs.theme

Item {
    implicitWidth: 420
    implicitHeight: card.implicitHeight + 2 * 18

    MediaCard {
        id: card
        anchors.fill: parent
        anchors.margins: 18
    }
}
