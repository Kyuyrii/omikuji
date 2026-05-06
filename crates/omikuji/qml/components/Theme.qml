import QtQuick

QtObject {
    id: theme

    property SystemPalette active: SystemPalette { colorGroup: SystemPalette.Active }
    property SystemPalette inactive: SystemPalette { colorGroup: SystemPalette.Inactive }

    property color accent: active.highlight
    property color accentText: active.highlightedText
    property color accentOn: accent.hslLightness > 0.5 ? "#000000" : "#ffffff"

    property color bg: active.window
    property color bgAlt: Qt.darker(active.window, 1.1)
    property color surface: active.base
    property color surfaceHover: Qt.lighter(active.base, 1.1)
    property color surfaceBorder: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.08)

    property color text: active.windowText
    property color textMuted: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.55)
    property color textSubtle: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.35)
    property color textFaint: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.2)

    property color navBg: active.window
    property color navSeparator: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.06)

    property color cardBg: Qt.lighter(active.base, 1.08)
    property color cardBorder: "transparent"
    property color cardBorderHover: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.12)

    property color barBg: Qt.rgba(active.window.r, active.window.g, active.window.b, 0.92)
    property color barBorder: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.08)

    property bool mutedIcons: false
    property color icon: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, mutedIcons ? 0.55 : 0.92)
    property color iconHover: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, mutedIcons ? 0.9 : 1.0)

    property color separator: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.06)
    property color dot: Qt.rgba(active.windowText.r, active.windowText.g, active.windowText.b, 0.15)

    property color popup: Qt.hsla(active.window.hslHue, active.window.hslSaturation, active.window.hslLightness, 1.0)

    property color tooltipBg: active.windowText
    property color tooltipText: active.window

    property color error: active.window.hslLightness > 0.5 ? "#d32f2f" : "#ef5350"
    property color success: active.window.hslLightness > 0.5 ? "#388e3c" : "#66bb6a"
    property color warning: active.window.hslLightness > 0.5 ? "#f57c00" : "#ffa726"
}
