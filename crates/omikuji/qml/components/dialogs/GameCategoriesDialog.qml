import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../widgets"

Item {
    id: dialog

    property var gameModel: null
    property var uiSettings: null
    property int gameIndex: -1
    property string gameName: ""

    property var tagCategories: []
    property var selectedTags: []

    signal requestNewCategory()

    visible: false
    z: 2100

    function show(index) {
        if (!gameModel || index < 0) return
        let g = gameModel.get_game(index)
        if (!g) return
        dialog.gameIndex = index
        dialog.gameName = g.name || ""
        try { dialog.selectedTags = JSON.parse(g.categories || "[]") }
        catch (e) { dialog.selectedTags = [] }
        _loadCategories()
        dialog.visible = true
    }

    function hide() { dialog.visible = false }

    function _loadCategories() {
        if (!uiSettings) { dialog.tagCategories = []; return }
        let all = []
        try { all = JSON.parse(uiSettings.categoriesJson()) } catch (e) { all = [] }
        let tags = []
        for (let i = 0; i < all.length; i++) {
            if (all[i].kind === "tag") tags.push(all[i])
        }
        dialog.tagCategories = tags
    }

    function _toggleTag(value) {
        let current = dialog.selectedTags.slice()
        let idx = current.indexOf(value)
        if (idx === -1) current.push(value)
        else current.splice(idx, 1)
        dialog.selectedTags = current
    }

    function _save() {
        if (!gameModel || gameIndex < 0) return
        let json = JSON.stringify(dialog.selectedTags)
        gameModel.update_game_field(gameIndex, "meta.categories", json)
        let g = gameModel.get_game(gameIndex)
        if (g) gameModel.save_game(g.gameId)
        dialog.hide()
    }

    Connections {
        target: uiSettings
        function onCategoriesChanged() {
            if (dialog.visible) dialog._loadCategories()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => { if (mouse.button === Qt.LeftButton) dialog.hide() }
            onWheel: (wheel) => wheel.accepted = true
            cursorShape: Qt.ArrowCursor
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 440)
        height: Math.min(parent.height - 120, contentCol.implicitHeight + actionRow.implicitHeight + 56)
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
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: actionRow.top
            anchors.margins: 22
            anchors.bottomMargin: 12
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: contentCol
            width: cardScroll.width
            spacing: 12

            Text {
                text: "Categories"
                color: theme.text
                font.pixelSize: 17
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: dialog.gameName
                color: theme.textMuted
                font.pixelSize: 13
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Text {
                Layout.fillWidth: true
                text: "No tag categories yet. Create one to start tagging."
                color: theme.textSubtle
                font.pixelSize: 13
                wrapMode: Text.Wrap
                visible: dialog.tagCategories.length === 0
            }

            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(tagList.height, 320)
                contentHeight: tagList.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height
                visible: dialog.tagCategories.length > 0

                Column {
                    id: tagList
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: dialog.tagCategories

                        Item {
                            required property var modelData

                            width: parent.width
                            height: 40

                            readonly property bool selected: dialog.selectedTags.indexOf(modelData.value) !== -1

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: rowHover.containsMouse
                                    ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.06)
                                    : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                SvgIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: selected ? "check_box" : "check_box_outline_blank"
                                    size: 20
                                    color: selected ? theme.accent : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.55)
                                }

                                SvgIcon {
                                    name: modelData.icon
                                    size: 18
                                    color: theme.icon
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.name
                                    color: theme.text
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: rowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: dialog._toggleTag(modelData.value)
                            }
                        }
                    }
                }
            }

        }
        }

        RowLayout {
            id: actionRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 22
            spacing: 10

            Item {
                implicitWidth: addRow.implicitWidth + 20
                implicitHeight: 36

                Rectangle {
                    anchors.fill: parent
                    radius: 18
                    color: addHover.containsMouse
                        ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.12)
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Row {
                    id: addRow
                    anchors.centerIn: parent
                    spacing: 6
                    SvgIcon {
                        name: "add"
                        size: 14
                        color: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "New"
                        color: theme.accent
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: addHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dialog.requestNewCategory()
                }
            }

            Item { Layout.fillWidth: true }

            Item {
                implicitWidth: 90
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
                    onClicked: dialog.hide()
                }
            }

            Item {
                implicitWidth: 100
                implicitHeight: 36

                Rectangle {
                    anchors.fill: parent
                    radius: 18
                    color: theme.accent
                    opacity: saveHover.containsPress ? 0.8
                        : saveHover.containsMouse ? 0.95 : 0.9
                    scale: saveHover.containsPress ? 0.97 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }
                Text {
                    anchors.centerIn: parent
                    text: "Save"
                    color: theme.accentOn
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
                MouseArea {
                    id: saveHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dialog._save()
                }
            }
        }
    }
}
