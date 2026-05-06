import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects


Item {
    id: root

    property string title: "Are you sure?"
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool destructive: false

    property var payload: null

    signal confirmed(var payload)
    signal cancelled(var payload)

    visible: false
    z: 2000

    function show(payload_) {
        payload = payload_ === undefined ? null : payload_
        visible = true
        forceActiveFocus()
    }

    function hide() {
        visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        MouseArea {
            anchors.fill: parent
            // hoverEnabled true so cards underneath dont stay lit while the dialog is open
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => { if (mouse.button === Qt.LeftButton) { root.cancelled(root.payload); root.hide() } }
            onWheel: (wheel) => wheel.accepted = true
            cursorShape: Qt.ArrowCursor
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 420)
        height: Math.min(parent.height - 60, contentCol.implicitHeight + 44)
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

        Flickable {
            id: cardScroll
            anchors.fill: parent
            anchors.margins: 22
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: contentCol
            width: cardScroll.width
            spacing: 14

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
                text: root.message
                color: theme.textMuted
                font.pixelSize: 13
                wrapMode: Text.Wrap
                visible: text.length > 0
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
                        text: root.cancelText
                        color: theme.text
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    MouseArea {
                        id: cancelHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.cancelled(root.payload); root.hide() }
                    }
                }

                Item {
                    implicitWidth: Math.max(96, confirmLabel.implicitWidth + 28)
                    implicitHeight: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: root.destructive ? "#e06060" : theme.accent
                        opacity: confirmHover.containsPress ? 0.8
                            : confirmHover.containsMouse ? 0.95 : 0.9
                        scale: confirmHover.containsPress ? 0.97 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }
                    Text {
                        id: confirmLabel
                        anchors.centerIn: parent
                        text: root.confirmText
                        color: root.destructive ? theme.text : theme.accentOn
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        id: confirmHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.confirmed(root.payload); root.hide() }
                    }
                }
            }
        }
        }
    }
}
