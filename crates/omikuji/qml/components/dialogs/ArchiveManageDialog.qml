import QtQuick
import QtQuick.Controls

import "../widgets"

Item {
    id: root

    property var archiveManager: null
    // root-owned map keyed by category/source/tag, install runs detached so reopening mid-download still reflects the live state
    property var activeInstalls: ({})

    property string category: ""
    property string sourceName: ""
    property string sourceKind: ""

    property var versions: []
    property var installedTags: ({})

    property string errorMessage: ""
    property bool fetching: false

    signal closed()
    signal versionDeleted(string category, string sourceName, string tag)

    anchors.fill: parent
    visible: false
    z: 2000

    function show(cat, name, kind) {
        category = cat
        sourceName = name
        sourceKind = kind
        versions = []
        installedTags = ({})
        errorMessage = ""
        refreshInstalled()
        visible = true
        fetchVersionsNow()
    }

    function hide() {
        visible = false
        root.closed()
    }

    function refreshInstalled() {
        if (!archiveManager || sourceName === "") return
        try {
            let raw = archiveManager.listInstalled(category, sourceName)
            let list = JSON.parse(raw) || []
            let map = ({})
            for (let i = 0; i < list.length; i++) map[list[i]] = true
            installedTags = map
        } catch (e) {
            console.warn("installedTags parse failed:", e)
            installedTags = ({})
        }
    }

    function fetchVersionsNow() {
        if (!archiveManager || sourceName === "") return
        fetching = true
        errorMessage = ""
        archiveManager.fetchVersions(category, sourceName)
    }

    Connections {
        target: archiveManager
        enabled: root.visible && archiveManager !== null

        function onVersionsReady(cat, name, json) {
            if (cat !== root.category || name !== root.sourceName) return
            root.fetching = false
            try {
                root.versions = JSON.parse(json) || []
            } catch (e) {
                root.versions = []
                root.errorMessage = "Couldn't parse versions response."
            }
        }
        function onVersionsFailed(cat, name, err) {
            if (cat !== root.category || name !== root.sourceName) return
            root.fetching = false
            root.errorMessage = err
        }
        function onInstallCompleted(cat, name, tag, installDir) {
            if (cat !== root.category || name !== root.sourceName) return
            root.refreshInstalled()
        }
        function onInstallFailed(cat, name, tag, err) {
            if (cat !== root.category || name !== root.sourceName) return
            root.errorMessage = err
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => { if (mouse.button === Qt.LeftButton) root.hide() }
            onWheel: (wheel) => wheel.accepted = true
        }
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(parent.width - 60, 720)
        height: Math.min(parent.height - 60, 560)
        radius: 14
        color: theme.surface
        border.width: 1
        border.color: theme.surfaceBorder

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onWheel: (wheel) => wheel.accepted = true
        }

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 64

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Row {
                    spacing: 10
                    Text {
                        text: root.sourceName
                        color: theme.text
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        height: 18
                        width: kindLabel.width + 14
                        radius: 9
                        color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.15)
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: kindLabel
                            anchors.centerIn: parent
                            text: root.sourceKind
                            color: theme.accent
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 0.6
                        }
                    }
                }

                Text {
                    text: root.fetching ? "Fetching versions…"
                        : root.versions.length > 0 ? root.versions.length + " versions available"
                        : root.errorMessage !== "" ? root.errorMessage
                        : "No versions loaded yet"
                    color: root.errorMessage !== "" ? theme.error : theme.textSubtle
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 16
                color: closeArea.containsMouse
                    ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.08)
                    : "transparent"

                SvgIcon {
                    anchors.centerIn: parent
                    name: "close"
                    size: 16
                    color: theme.text
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.hide()
                }
            }
        }

        Rectangle {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: theme.separator
        }

        ListView {
            id: list
            anchors.top: header.bottom
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            model: root.versions
            spacing: 0

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Text {
                anchors.centerIn: parent
                visible: list.count === 0
                text: root.fetching ? "Loading…"
                    : root.errorMessage !== "" ? "Couldn't load versions."
                    : "No versions available."
                color: theme.textSubtle
                font.pixelSize: 13
            }

            delegate: Item {
                required property int index
                required property var modelData

                readonly property string tag: modelData.tag || ""
                readonly property string publishedAt: modelData.published_at || ""
                readonly property int assetSize: modelData.asset_size || 0
                readonly property bool installed: root.installedTags[tag] === true
                // derived from activeInstalls so reopening mid-install shows the in-flight row as busy right away
                readonly property bool busy:
                    root.activeInstalls[root.category + "/" + root.sourceName + "/" + tag] !== undefined

                width: ListView.view.width
                height: 54

                Rectangle {
                    anchors.fill: parent
                    color: rowMouse.containsMouse
                        ? Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.03)
                        : "transparent"
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.right: actionSlot.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Text {
                        text: tag
                        color: theme.text
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.family: "monospace"
                        width: 220
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: publishedAt.length >= 10 ? publishedAt.substring(0, 10) : publishedAt
                        color: theme.textSubtle
                        font.pixelSize: 12
                        font.family: "monospace"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: assetSize > 0
                            ? (assetSize / (1024 * 1024)).toFixed(1) + " MB"
                            : ""
                        color: theme.textSubtle
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // fixed width so Install, check+delete, and Working all center on the same column witohut the row jumping right on state change
                Item {
                    id: actionSlot
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    width: 96
                    height: 30

                    Rectangle {
                        anchors.centerIn: parent
                        visible: !installed && !busy
                        width: 82
                        height: 28
                        radius: 14
                        color: installArea.containsMouse
                            ? Qt.darker(theme.accent, 1.1)
                            : theme.accent
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                            anchors.centerIn: parent
                            text: "Install"
                            color: theme.accentOn
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                        MouseArea {
                            id: installArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                archiveManager.installVersion(
                                    root.category,
                                    root.sourceName,
                                    JSON.stringify(modelData)
                                )
                            }
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        visible: installed && !busy
                        spacing: 8

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            height: 26
                            radius: 13
                            color: Qt.rgba(theme.success.r, theme.success.g, theme.success.b, 0.18)
                            SvgIcon {
                                anchors.centerIn: parent
                                name: "check_circle"
                                size: 14
                                color: theme.success
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            height: 28
                            radius: 14
                            color: deleteArea.containsMouse
                                ? Qt.rgba(theme.error.r, theme.error.g, theme.error.b, 0.18)
                                : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }
                            SvgIcon {
                                anchors.centerIn: parent
                                name: "close"
                                size: 14
                                color: deleteArea.containsMouse ? theme.error : theme.textMuted
                            }
                            MouseArea {
                                id: deleteArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    archiveManager.deleteVersion(root.category, root.sourceName, tag)
                                    root.refreshInstalled()
                                    root.versionDeleted(root.category, root.sourceName, tag)
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: busy
                        text: "Working…"
                        color: theme.textMuted
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: theme.separator
                    visible: index < (list.count - 1)
                }
            }
        }
    }
}
