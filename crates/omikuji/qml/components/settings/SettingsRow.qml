import QtQuick
import "../widgets"


Item {
    id: root

    property string label: ""
    property string description: ""
    // 120 for per-game pages, wider for global settings where labels are longer
    property int labelWidth: 120
    property int contentRightMargin: 98
    default property alias content: contentSlot.children

    implicitWidth: parent ? parent.width : 400
    implicitHeight: Math.max(labelCol.height, contentSlot.height)

    Column {
        id: labelCol
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.labelWidth
        spacing: 2

        Text {
            id: labelText
            text: root.label
            color: theme.text
            font.pixelSize: 15
        }

        Text {
            text: root.description
            color: theme.textSubtle
            font.pixelSize: 13
            width: Math.max(labelText.width, root.labelWidth)
            wrapMode: Text.WordWrap
            visible: root.description !== ""
        }
    }

    Item {
        id: contentSlot
        anchors.right: parent.right
        anchors.rightMargin: root.contentRightMargin
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
