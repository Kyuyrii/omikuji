import QtQuick
import QtQuick.Effects
import "../widgets"
import "../library"


Item {
    id: sidebar

    width: 56

    property var games: []
    property int currentIndex: 0
    signal gameSelected(int index)

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.03, 0.03, 0.05, 0.85)

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: Qt.rgba(1, 1, 1, 0.06)
        }
    }

    GameIcon {
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        size: 36
        name: "Store"
        color: "#1a1a2e"
        isStore: true
        onClicked: {}
    }

    Column {
        id: gameIcons
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Repeater {
            model: sidebar.games

            GameIcon {
                required property var modelData
                required property int index

                size: 36
                name: modelData.name
                iconSource: modelData.icon
                color: modelData.color
                selected: index === sidebar.currentIndex
                onClicked: sidebar.gameSelected(index)
            }
        }
    }
}
