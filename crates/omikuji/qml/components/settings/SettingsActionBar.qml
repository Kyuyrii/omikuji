import QtQuick
import Qt5Compat.GraphicalEffects

import "../widgets"

Item {
    id: root

    property bool canSave: true
    property bool canPlay: true

    signal cancelClicked()
    signal saveClicked()
    signal saveAndPlayClicked()

    height: 56

    Rectangle {
        id: bar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        width: parent.width - 32
        height: 56
        radius: 16
        color: theme.barBg
        border.width: 1
        border.color: theme.barBorder

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 4
            radius: 20
            samples: 41
            color: Qt.rgba(0, 0, 0, 0.45)
        }

        IconButton {
            id: cancelBtn
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            icon: "arrow_back"
            size: 36
            rounded: true
            onClicked: root.cancelClicked()
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Item {
                id: saveBtn
                width: 84
                height: 40
                enabled: root.canSave
                opacity: enabled ? 1 : 0.5
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: theme.accent
                    opacity: saveMouse.containsPress ? 0.8 : (saveMouse.containsMouse ? 0.95 : 0.9)
                    scale: saveMouse.containsPress ? 0.97 : 1.0

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Save"
                    color: theme.accentOn
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.saveClicked()
                }
            }

            Item {
                id: savePlayBtn
                width: 118
                height: 40
                enabled: root.canSave && root.canPlay
                opacity: enabled ? 1 : 0.5
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: theme.accent
                    opacity: playMouse.containsPress ? 0.8 : (playMouse.containsMouse ? 0.95 : 0.9)
                    scale: playMouse.containsPress ? 0.97 : 1.0

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Save & Play"
                    color: theme.accentOn
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.saveAndPlayClicked()
                }
            }
        }
    }
}
