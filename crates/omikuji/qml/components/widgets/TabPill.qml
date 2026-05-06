import QtQuick
import "."

Item {
    id: root

    property var tabs: []
    property int currentIndex: 0
    readonly property string currentKind:
        (currentIndex >= 0 && currentIndex < tabs.length && tabs[currentIndex])
            ? (tabs[currentIndex].kind || "") : ""

    signal tabClicked(int index, string kind)

    implicitWidth: pillRow.width + 8
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.05)

        Row {
            id: pillRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 4
            spacing: 4

            Repeater {
                model: root.tabs

                Rectangle {
                    id: chip
                    required property int index
                    required property var modelData

                    readonly property bool selected: index === root.currentIndex
                    readonly property bool hovered: chipArea.containsMouse

                    height: 28
                    width: chipRow.width + 20
                    radius: 8
                    color: selected
                        ? theme.accent
                        : (hovered
                            ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)
                            : "transparent")

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 6

                        SvgIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: chip.modelData.icon || ""
                            size: 16
                            color: chip.selected ? theme.accentOn : theme.textMuted
                            visible: chip.modelData.icon !== undefined && chip.modelData.icon !== ""

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.modelData.label || ""
                            color: chip.selected ? theme.accentOn : theme.text
                            font.pixelSize: 13
                            font.weight: chip.selected ? Font.DemiBold : Font.Medium

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: chipArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        // parent drives currentIndex; imperative assign here would sever the binding
                        onClicked: root.tabClicked(chip.index, chip.modelData.kind || "")
                    }
                }
            }
        }
    }
}
