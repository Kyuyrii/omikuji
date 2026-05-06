import QtQuick
import QtCore
import "."

Item {
    id: root

    property string label: ""
    property string placeholder: ""
    property string text: ""
    property bool selectFolder: false
    property bool readOnly: false
    property string trailingHint: ""
    property var gameModel: null

    signal textEdited(string text)
    signal accepted(string path)

    implicitWidth: 200
    implicitHeight: label ? labelText.height + 4 + fieldRow.height : fieldRow.height

    Text {
        id: labelText
        text: root.label
        color: inputArea.activeFocus ? theme.accent : theme.textMuted
        font.pixelSize: 14
        font.weight: Font.Medium
        visible: root.label !== ""

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }

    Row {
        id: fieldRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 44
        spacing: 8

        Rectangle {
            id: inputBg
            width: parent.width - folderBtn.width - parent.spacing
            height: parent.height
            radius: 8
            color: "transparent"
            border.width: inputArea.activeFocus ? 2 : 1
            border.color: inputArea.activeFocus ? theme.accent
                         : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.15)

            Behavior on border.width {
                NumberAnimation { duration: 100 }
            }
            Behavior on border.color {
                ColorAnimation { duration: 100 }
            }

            TextInput {
                id: inputArea
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                text: root.text
                color: root.readOnly ? theme.textMuted : theme.text
                font.pixelSize: 14
                clip: true
                readOnly: root.readOnly
                selectByMouse: !root.readOnly
                selectionColor: theme.accent
                selectedTextColor: theme.accentText

                onTextEdited: root.textEdited(text)
                onAccepted: root.accepted(text)
            }

            // x-positioned not anchored, anchoring feeds back into inputArea.width and causes a binding loop apparently
            Text {
                id: hintText
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                x: inputArea.x + Math.min(
                    inputArea.contentWidth + 2,
                    inputArea.width - implicitWidth - 4
                )
                width: Math.max(0, Math.min(
                    implicitWidth,
                    parent.width - 12 - x
                ))
                text: root.trailingHint
                color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.4)
                font.pixelSize: 14
                elide: Text.ElideRight
                visible: root.trailingHint !== "" && inputArea.text !== ""
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                verticalAlignment: Text.AlignVCenter
                text: root.placeholder
                color: theme.textSubtle
                font.pixelSize: 14
                visible: inputArea.text === "" && !inputArea.activeFocus
            }
        }

        Rectangle {
            id: folderBtn
            width: 44
            height: 44
            radius: 8
            opacity: root.readOnly ? 0.4 : 1.0
            color: root.readOnly ? "transparent"
                  : folderMouse.containsPress ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.1)
                  : folderMouse.containsMouse ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.06)
                  : "transparent"
            border.width: 1
            border.color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.15)

            SvgIcon {
                anchors.centerIn: parent
                name: "folder"
                size: 20
                color: theme.textMuted
            }

            MouseArea {
                id: folderMouse
                anchors.fill: parent
                hoverEnabled: !root.readOnly
                enabled: !root.readOnly
                cursorShape: root.readOnly ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: openFileDialog()
            }
        }
    }

    property string _dialogRequestId: ""

    Connections {
        target: root.gameModel
        enabled: root._dialogRequestId !== ""
        function onFile_dialog_result(requestId, path) {
            if (requestId !== root._dialogRequestId) return
            root._dialogRequestId = ""
            if (path && path !== "") {
                root.text = path
                root.textEdited(path)
                root.accepted(path)
            }
        }
    }

    function openFileDialog() {
        if (!gameModel) {
            return
        }

        let title = root.selectFolder ? "Select Folder" : "Select File"
        let defaultPath = root.text || "/home"

        let id = Date.now().toString(36) + Math.random().toString(36).substring(2, 8)
        root._dialogRequestId = id
        gameModel.open_file_dialog(id, root.selectFolder, title, defaultPath)
    }
}
