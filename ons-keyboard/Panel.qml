import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null

    // SmartPanel properties - force to screen bottom center
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true
    
    // Force positioning
    readonly property bool panelAnchorBottom: true
    readonly property bool panelAnchorHorizontalCenter: true
    readonly property bool panelAnchorLeft: false
    readonly property bool panelAnchorRight: false
    readonly property bool panelAnchorTop: false
    readonly property bool panelAnchorVerticalCenter: false
    
    property real preferredWidth: 1100 * Style.uiScaleRatio
    property real preferredHeight: 400 * Style.uiScaleRatio

    Rectangle {
        id: panelContainer
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Style.marginL
        width: 1100 * Style.uiScaleRatio
        height: 400 * Style.uiScaleRatio
        color: Color.mSurface
        radius: Style.radiusL
        border.color: Color.mOutline
        border.width: Style.borderS
    }
}
