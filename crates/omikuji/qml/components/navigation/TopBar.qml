import QtQuick
import QtQuick.Controls

import "../widgets"

Item {
    id: root

    property string currentTabLabel: ""
    property string subText: ""
    property bool showAddButton: true
    property bool showSearch: true
    property bool showDisplayOptions: false
    property real zoomValue: 1.0
    property int spacingValue: 16
    property alias searchText: searchInput.text

    // when populated, replaces the search bar so settings pages can promote their tabs into the TopBar
    property var tabs: []
    property int currentTabIndex: 0
    property real pillCenterX: width / 2

    signal addClicked()
    signal zoomMoved(real value)
    signal spacingMoved(int value)
    signal tabSelected(int index)
    signal consoleModeClicked()

    height: 54

    function defocusSearch() {
        searchInput.focus = false
    }

    // opaque fill becuase witout it lower-z dropdown popups bleed through the empty bar areas
    Rectangle {
        anchors.fill: parent
        color: theme.navBg
    }

    Item {
        id: titleArea
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(
            Math.max(titleText.width, subBelow.implicitWidth),
            titleArea.availWidth
        )
        height: titleArea.stacked
            ? titleText.implicitHeight + 2 + subBelowHeight
            : titleText.implicitHeight
        readonly property real subBelowHeight: 16

        Behavior on height {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        readonly property bool hasSub: root.subText !== ""
        readonly property real availWidth: centerTabs.visible
            ? Math.max(80, (root.width - centerTabs.width) / 2 - 24 - 16)
            : Math.max(80, root.width * 0.5)
        readonly property int gap: 10 + 4 + 10

        // pre-measured so layout decisions dont invalidate the Text's own binding
        TextMetrics {
            id: subMetrics
            font.pixelSize: 13
            font.family: "monospace"
            text: root.subText
        }
        readonly property real subNatural: hasSub ? subMetrics.advanceWidth : 0
        readonly property real titleNatural: titleText.implicitWidth

        readonly property bool stacked:
            hasSub && (titleNatural + gap + subNatural > availWidth)

        Text {
            id: titleText
            anchors.top: parent.top
            anchors.left: parent.left
            text: root.currentTabLabel
            color: theme.text
            font.pixelSize: titleArea.stacked ? 16 : 20
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            width: titleArea.hasSub && !titleArea.stacked
                ? Math.min(implicitWidth, titleArea.availWidth - titleArea.gap - titleArea.subNatural)
                : Math.min(implicitWidth, titleArea.availWidth)
        }

        Row {
            id: subInline
            anchors.left: titleText.right
            anchors.leftMargin: 10
            anchors.verticalCenter: titleText.verticalCenter
            spacing: 10
            opacity: titleArea.hasSub && !titleArea.stacked ? 1 : 0
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }

            Rectangle {
                width: 4; height: 4; radius: 2
                color: theme.dot
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.subText
                color: theme.textSubtle
                font.pixelSize: 13
                font.family: "monospace"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            id: subBelow
            anchors.top: titleText.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: titleText.horizontalCenter
            text: root.subText
            color: theme.textSubtle
            font.pixelSize: 11
            font.family: "monospace"
            opacity: titleArea.hasSub && titleArea.stacked ? 1 : 0
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }
    }

    TabPill {
        id: centerTabs
        x: Math.max(
            titleArea.x + titleArea.width + 16,
            Math.min(
                parent.width - width - 16,
                root.pillCenterX - width / 2
            )
        )
        anchors.verticalCenter: parent.verticalCenter
        tabs: root.tabs
        currentIndex: root.currentTabIndex
        visible: root.tabs.length > 0
        onTabClicked: (index, _kind) => root.tabSelected(index)
    }

    Rectangle {
        id: searchBar
        anchors.centerIn: parent
        width: Math.min(360, parent.width * 0.4)
        height: 34
        radius: 17
        color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.06)
        border.width: searchInput.activeFocus ? 1 : 0
        border.color: theme.accent
        visible: root.showSearch && root.tabs.length === 0

        Behavior on border.width {
            NumberAnimation { duration: 100 }
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            SvgIcon {
                name: "search"
                size: 16
                color: theme.textSubtle
                anchors.verticalCenter: parent.verticalCenter
            }

            TextInput {
                id: searchInput
                width: searchBar.width - 44
                color: theme.text
                font.pixelSize: 13
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                selectionColor: theme.accent
                selectedTextColor: theme.accentText

                Text {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search games..."
                    color: theme.textSubtle
                    font.pixelSize: 13
                    visible: !searchInput.text && !searchInput.activeFocus
                }
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        IconButton {
            id: consoleBtn
            icon: "sports_esports"
            size: 32
            rounded: true
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.consoleModeClicked()

            Tooltip {
                text: "Console Mode"
                tipVisible: consoleBtn.hovered
                y: parent.height + 8
            }
        }

        IconButton {
            id: displayBtn
            icon: "tune"
            size: 32
            rounded: true
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showDisplayOptions
            onClicked: displayPopup.visible ? displayPopup.close() : displayPopup.open()
        }

        IconButton {
            icon: "add"
            size: 32
            rounded: true
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showAddButton
            onClicked: root.addClicked()
        }
    }

    DisplayOptionsPopup {
        id: displayPopup
        parent: displayBtn
        x: displayBtn.width - width
        y: displayBtn.height + 8

        zoomValue: root.zoomValue
        spacingValue: root.spacingValue
        onZoomMoved: (v) => root.zoomMoved(v)
        onSpacingMoved: (v) => root.spacingMoved(v)
    }
}
