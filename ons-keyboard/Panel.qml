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
    
    property real contentPreferredWidth: 1600 * Style.uiScaleRatio
    property real contentPreferredHeight: 308 * Style.uiScaleRatio

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.margins: Style.marginL
        color: Color.mSurface
        radius: Style.radiusL
        border.color: Color.mOutline
        border.width: Style.borderS

        // Text inside the rectangle
        Text {
            id: testText
            text: "Xansi's magical test box :3"
            color: "white"  // Text color
            font.family: "Arial"  // Font
            font.pixelSize: 24  // Font size
            anchors.centerIn: parent  // Centers the text inside the rectangle
        }
    }
}
