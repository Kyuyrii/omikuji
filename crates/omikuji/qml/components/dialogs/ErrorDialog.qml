import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../widgets"

Item {
    id: root

    property string gameId: ""
    property string displayName: ""
    property string title: "Couldn't launch"
    property string message: ""
    property string action: ""

    visible: false
    z: 2000

    signal actionRequested(string action, string gameId)
    signal dismissed()

    function show(payload) {
        if (payload) {
            gameId = payload.gameId || ""
            displayName = payload.displayName || ""
            title = payload.title || "Couldn't launch"
            message = payload.message || ""
            action = payload.action || ""
        }
        visible = true
        forceActiveFocus()
    }

    function hide() {
        visible = false
    }

    function renderMessage(raw) {
        if (!raw) return ""
        let accent = theme.accent
        let hex = Qt.colorEqual(accent, "transparent")
            ? "#888"
            : "#" + Math.round(accent.r * 255).toString(16).padStart(2, "0")
                  + Math.round(accent.g * 255).toString(16).padStart(2, "0")
                  + Math.round(accent.b * 255).toString(16).padStart(2, "0")
        let escaped = String(raw)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
        return escaped.replace(/`([^`]+)`/g, function(_m, p1) {
            return '<span style="color:' + hex + '; font-family:monospace">' + p1 + '</span>'
        })
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => { if (mouse.button === Qt.LeftButton) { root.dismissed(); root.hide() } }
            onWheel: (wheel) => wheel.accepted = true
            cursorShape: Qt.ArrowCursor
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 460)
        height: Math.min(parent.height - 60, content.implicitHeight + 48)
        radius: 22
        color: theme.surface
        border.width: 1
        border.color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: {}
            onWheel: (wheel) => wheel.accepted = true
        }

        layer.enabled: true
        layer.effect: DropShadow {
            radius: 24
            samples: 32
            color: Qt.rgba(0, 0, 0, 0.4)
            horizontalOffset: 0
            verticalOffset: 6
        }

        ColumnLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: Qt.rgba(theme.danger ? theme.danger.r : 0.88, theme.danger ? theme.danger.g : 0.38, theme.danger ? theme.danger.b : 0.38, 0.18)
                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "!"
                        color: theme.danger || "#e06060"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.title
                        color: theme.text
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.displayName
                        color: theme.textMuted
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 2
                radius: 12
                color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.04)
                implicitHeight: messageText.implicitHeight + 24

                Text {
                    id: messageText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    text: root.renderMessage(root.message)
                    textFormat: Text.RichText
                    color: theme.text
                    font.pixelSize: 13
                    wrapMode: Text.Wrap
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 10

                Item { Layout.fillWidth: true }

                Item {
                    implicitWidth: Math.max(80, cancelLabel.implicitWidth + 28)
                    implicitHeight: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: cancelHover.containsPress
                            ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.12)
                            : cancelHover.containsMouse
                                ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.06)
                                : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                    Text {
                        id: cancelLabel
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: theme.text
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    MouseArea {
                        id: cancelHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.dismissed(); root.hide() }
                    }
                }

                Item {
                    visible: root.action.length > 0
                    implicitWidth: visible ? Math.max(120, openLabel.implicitWidth + 28) : 0
                    implicitHeight: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: theme.accent
                        opacity: openHover.containsPress ? 0.8
                            : openHover.containsMouse ? 0.95 : 0.9
                        scale: openHover.containsPress ? 0.97 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }
                    Text {
                        id: openLabel
                        anchors.centerIn: parent
                        text: "Open Settings"
                        color: theme.accentOn
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        id: openHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.actionRequested(root.action, root.gameId)
                            root.hide()
                        }
                    }
                }
            }
        }
    }
}
