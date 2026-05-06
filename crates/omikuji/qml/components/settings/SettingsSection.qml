import QtQuick
import "../widgets"


Item {
    id: root

    property string icon: ""
    property string label: ""
    default property alias content: sectionContent.children

    implicitWidth: parent ? parent.width : 400
    implicitHeight: header.height + 16 + sectionContent.height

    Item {
        id: header
        width: parent.width
        height: 28

        Text {
            id: headerLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: theme.textMuted
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 0.6
        }

        Rectangle {
            anchors.left: headerLabel.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: theme.separator
        }
    }

    Column {
        id: sectionContent
        anchors.top: header.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 16
    }
}
