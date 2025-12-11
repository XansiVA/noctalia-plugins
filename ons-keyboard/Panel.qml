import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null

    // SmartPanel properties
    readonly property var geometryPlaceholder: panelContainer

    Rectangle {
        id: panelContainer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1100 * Style.uiScaleRatio
        height: 400 * Style.uiScaleRatio
        color: Color.transparent
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: Style.marginL
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Color.mOutline
            border.width: Style.borderS
        }
    }
}
