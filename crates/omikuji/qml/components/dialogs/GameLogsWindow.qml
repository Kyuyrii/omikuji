import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import "../widgets"

Window {
    id: logWindow

    property string gameId: ""
    property string gameName: ""
    property var gameModel: null
    property var theme: null
    property bool autoScroll: true
    property bool justSaved: false

    signal windowClosed()

    width: 860
    height: 520
    minimumWidth: 420
    minimumHeight: 280
    title: "omikuji · " + (gameName || gameId) + " logs"
    color: theme ? theme.bg : "#0a0a0a"

    function refresh() {
        if (!gameModel) return
        textArea.text = gameModel.game_log(gameId)
        if (autoScroll) {
            textArea.cursorPosition = textArea.length
        }
    }

    Connections {
        target: gameModel
        function onGameLogAppended(id) {
            if (id === logWindow.gameId) logWindow.refresh()
        }
    }

    Component.onCompleted: {
        visible = true
        refresh()
        raise()
        requestActivate()
    }

    onClosing: windowClosed()

    component HeaderButton: Item {
        id: btn
        property string label: ""
        property color labelColor: logWindow.theme ? logWindow.theme.text : "#cccccc"
        property color borderColor: logWindow.theme ? logWindow.theme.surfaceBorder : "#2e2e2e"
        property color hoverColor: logWindow.theme
            ? Qt.rgba(logWindow.theme.text.r, logWindow.theme.text.g, logWindow.theme.text.b, 0.08)
            : "#222222"
        signal clicked()

        implicitWidth: btnText.implicitWidth + 24
        implicitHeight: 28

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: btnArea.containsMouse ? btn.hoverColor : "transparent"
            border.width: 1
            border.color: btn.borderColor
            Behavior on color { ColorAnimation { duration: 100 } }
        }

        Text {
            id: btnText
            anchors.centerIn: parent
            text: btn.label
            color: btn.labelColor
            font.pixelSize: 12
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: logWindow.theme ? logWindow.theme.bgAlt : "#141414"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    text: logWindow.gameName
                    color: logWindow.theme ? logWindow.theme.text : "#dddddd"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Item {
                    Layout.preferredWidth: followRow.implicitWidth + 12
                    Layout.preferredHeight: 28

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: followArea.containsMouse
                            ? (logWindow.theme
                                ? Qt.rgba(logWindow.theme.text.r, logWindow.theme.text.g, logWindow.theme.text.b, 0.08)
                                : "#1c1c1c")
                            : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    Row {
                        id: followRow
                        anchors.centerIn: parent
                        spacing: 8

                        SvgIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: logWindow.autoScroll ? "check_box" : "check_box_outline_blank"
                            size: 18
                            color: logWindow.autoScroll
                                ? (logWindow.theme ? logWindow.theme.accent : "#7fbfff")
                                : (logWindow.theme ? logWindow.theme.textMuted : "#888888")
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Follow"
                            color: logWindow.theme ? logWindow.theme.text : "#cccccc"
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: followArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: logWindow.autoScroll = !logWindow.autoScroll
                    }
                }

                HeaderButton {
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                    label: "Clear"
                    onClicked: {
                        if (gameModel) {
                            gameModel.clear_game_log(logWindow.gameId)
                            logWindow.refresh()
                        }
                    }
                }

                HeaderButton {
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                    label: "Copy all"
                    onClicked: {
                        textArea.selectAll()
                        textArea.copy()
                        textArea.deselect()
                    }
                }

                HeaderButton {
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                    label: logWindow.justSaved ? "Saved ✓" : "Save"
                    labelColor: logWindow.justSaved
                        ? (logWindow.theme ? logWindow.theme.success : "#9dd39d")
                        : (logWindow.theme ? logWindow.theme.text : "#cccccc")
                    borderColor: logWindow.justSaved
                        ? (logWindow.theme
                            ? Qt.rgba(logWindow.theme.success.r, logWindow.theme.success.g, logWindow.theme.success.b, 0.5)
                            : "#2e6b2e")
                        : (logWindow.theme ? logWindow.theme.surfaceBorder : "#2e2e2e")
                    hoverColor: logWindow.justSaved
                        ? (logWindow.theme
                            ? Qt.rgba(logWindow.theme.success.r, logWindow.theme.success.g, logWindow.theme.success.b, 0.18)
                            : "#1d3a1d")
                        : (logWindow.theme
                            ? Qt.rgba(logWindow.theme.text.r, logWindow.theme.text.g, logWindow.theme.text.b, 0.08)
                            : "#222222")
                    onClicked: {
                        if (!gameModel) return
                        let path = gameModel.save_game_log(logWindow.gameId)
                        if (path && path.length > 0) {
                            logWindow.justSaved = true
                            savedRevertTimer.restart()
                        }
                    }
                }

                Timer {
                    id: savedRevertTimer
                    interval: 2000
                    repeat: false
                    onTriggered: logWindow.justSaved = false
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: logWindow.theme ? logWindow.theme.surfaceBorder : "#222222"
        }

        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                id: textArea
                readOnly: true
                wrapMode: TextArea.Wrap
                selectByMouse: true
                color: logWindow.theme ? logWindow.theme.text : "#dddddd"
                font.family: "monospace"
                font.pixelSize: 14
                leftPadding: 14
                rightPadding: 14
                topPadding: 10
                bottomPadding: 10
                background: Rectangle { color: logWindow.theme ? logWindow.theme.bg : "#0a0a0a" }
                text: ""
            }
        }
    }
}
