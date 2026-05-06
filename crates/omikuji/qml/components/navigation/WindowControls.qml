import QtQuick
import "../widgets"


Row {
    id: controls

    spacing: 8

    signal minimize()
    signal close()

    Repeater {
        model: [
            { action: "minimize", icon: "minimize", tint: "#ffffff" },
            { action: "close",    icon: "close",    tint: "#ff5f57" }
        ]

        Rectangle {
            required property var modelData
            required property int index

            width: 34
            height: 34
            radius: 17
            color: hoverArea.containsMouse ? theme.surfaceHover : "transparent"

            Behavior on color {
                ColorAnimation { duration: 100 }
            }

            SvgIcon {
                anchors.centerIn: parent
                name: modelData.icon
                size: 18
                color: hoverArea.containsMouse ? modelData.tint : theme.icon

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.action === "minimize") controls.minimize()
                    else if (modelData.action === "close") controls.close()
                }
            }
        }
    }
}
