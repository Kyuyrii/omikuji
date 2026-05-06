import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: icon

    property int size: 36
    property string name: ""
    property string iconSource: ""
    property color color: "#1a1a2e"
    property bool selected: false
    property bool isStore: false

    signal clicked()

    width: size
    height: size

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: -12
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: selected ? size * 0.6 : (hoverArea.containsMouse ? size * 0.3 : 0)
        radius: 2
        color: "#ffffff"
        opacity: selected ? 0.9 : 0.5

        Behavior on height {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    Item {
        id: iconContent
        anchors.fill: parent
        layer.enabled: true
        scale: hoverArea.containsPress ? 0.9 : 1.0
        opacity: selected ? 1.0 : 0.6

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            color: icon.color
        }

        Image {
            id: iconImg
            anchors.fill: parent
            source: icon.iconSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            text: isStore ? "+" : name.charAt(0)
            color: "#ffffff"
            font.pixelSize: size * 0.38
            font.weight: Font.DemiBold
            opacity: 0.9
            visible: !iconImg.visible
        }

        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: icon.size
                height: icon.size
                radius: icon.selected ? icon.size * 0.28 : icon.size * 0.5

                Behavior on radius {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: icon.clicked()
    }
}
