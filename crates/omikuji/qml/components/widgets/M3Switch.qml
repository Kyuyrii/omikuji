import QtQuick

Item {
    id: root

    property bool checked: false
    signal toggled(bool value)

    implicitWidth: 44
    implicitHeight: 26

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? theme.accent : "transparent"
        border.width: 2
        border.color: root.checked ? theme.accent : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.25)

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
    }

    Rectangle {
        id: thumb
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 3 : 3
        width: mouseArea.pressed ? 22 : root.checked ? 20 : 14
        height: width
        radius: width / 2
        color: root.checked ? theme.accentText : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.45)

        Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on width {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
