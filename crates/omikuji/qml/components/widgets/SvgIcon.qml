import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: icon

    property string name: ""
    property color color: "#ffffff"
    property int size: 20

    width: size
    height: size

    // does this even work? im blind, they all look blurry to me wtf
    layer.enabled: true
    layer.smooth: true
    layer.textureSize: Qt.size(size * 2, size * 2)

    Image {
        id: img
        anchors.fill: parent
        source: name ? "qrc:/qt/qml/omikuji/qml/icons/" + name + ".svg" : ""
        sourceSize: Qt.size(icon.size * 2, icon.size * 2)
        visible: false
    }

    ColorOverlay {
        anchors.fill: img
        source: img
        color: icon.color
    }
}
