import QtQuick

Item {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property string label: ""
    property bool readOnly: false

    signal textEdited()

    implicitWidth: 200
    implicitHeight: label ? labelText.height + 4 + field.height : field.height

    // guard against emitting textEdited on programmatic text changes
    property bool _settingText: false

    onTextChanged: {
        if (!_settingText && input.activeFocus) {
            textEdited()
        }
    }

    Text {
        id: labelText
        text: root.label
        color: input.activeFocus ? theme.accent : theme.textMuted
        font.pixelSize: 14
        font.weight: Font.Medium
        visible: root.label !== ""

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }

    Rectangle {
        id: field
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 44
        radius: 8
        color: "transparent"
        border.width: input.activeFocus ? 2 : 1
        border.color: input.activeFocus ? theme.accent
                     : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.15)

        Behavior on border.width {
            NumberAnimation { duration: 100 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 100 }
        }

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            color: theme.text
            font.pixelSize: 14
            clip: true
            readOnly: root.readOnly
            selectionColor: theme.accent
            selectedTextColor: theme.accentText
            selectByMouse: true

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: root.placeholder
                color: theme.textSubtle
                font.pixelSize: 14
                visible: !input.text && !input.activeFocus
            }
        }
    }
}
