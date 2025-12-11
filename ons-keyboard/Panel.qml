import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null

    // SmartPanel properties - full width bottom panel
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: false
    property real contentPreferredWidth: 10  // 0 = full width
    property real contentPreferredHeight: 400 * Style.uiScaleRatio

    anchors.fill: parent

    Rectangle {
        id: panelContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 900 * Style.uiScaleRatio
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
