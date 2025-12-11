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
    property real contentPreferredWidth: 400 * Style.uiScaleRatio
    property real contentPreferredHeight: 400 * Style.uiScaleRatio

    anchors.fill: parent

    Rectangle {
        id: panelContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 400 * Style.uiScaleRatio
        color: Color.transparent

        }
    }
