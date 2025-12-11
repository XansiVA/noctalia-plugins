import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Rectangle {
    id: root

    property real baseSize: Style.capsuleHeight
    property bool applyUiScale: false

    property url currentIconSource

    property string tooltipText: "Update Indicator"
    property string tooltipDirection: BarService.getTooltipDirection()
    property string density: Settings.data.bar.density
    property bool enabled: true
    property bool allowClickWhenDisabled: false
    property bool hovering: false

    property color colorBg: Color.mSurfaceVariant
    property color colorFg: Color.mPrimary
    property color colorBgHover: Color.mHover
    property color colorFgHover: Color.mOnHover
    property color colorBorder: Color.mOutline
    property color colorBorderHover: Color.mOutline
    property real customRadius: Style.radiusL

    signal entered
    signal exited
    signal clicked
    signal rightClicked
    signal middleClicked
    signal wheel(int angleDelta)

    implicitWidth: applyUiScale ? Math.round(baseSize * Style.uiScaleRatio) : Math.round(baseSize)
    implicitHeight: applyUiScale ? Math.round(baseSize * Style.uiScaleRatio) : Math.round(baseSize)

    opacity: root.enabled ? Style.opacityFull : Style.opacityMedium
    color: Color.mPrimary
    radius: Math.min((customRadius >= 0 ? customRadius : Style.iRadiusL), width / 2)
    border.color: Color.mOutline
    border.width: 1

    Behavior on color {
        ColorAnimation {
            duration: Style.animationNormal
            easing.type: Easing.InOutQuad
        }
    }

    // --- Update Indicator Specific Logic ---
    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    // JUST A TEXT THAT SAYS "UP"
    Text {
        anchors.centerIn: parent
        text: "UP"
        color: Color.mOnPrimary
        font.pointSize: Style.fontSizeM
        font.bold: true
    }

    MouseArea {
        enabled: true
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true
        onEntered: {
            root.hovering = root.enabled ? true : false;
            if (root.tooltipText) {
                TooltipService.show(parent, root.tooltipText, root.tooltipDirection);
            }
            root.entered();
        }
        onExited: {
            root.hovering = false;
            if (root.tooltipText) {
                TooltipService.hide();
            }
            root.exited();
        }
        onClicked: function (mouse) {
            if (root.tooltipText) {
                TooltipService.hide();
            }

            // Open Panel on click
            if (pluginApi) {
                pluginApi.openPanel(root.screen);
            }
            
            if (!root.enabled && !root.allowClickWhenDisabled) {
                return;
            }
            if (mouse.button === Qt.LeftButton) {
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else if (mouse.button === Qt.MiddleButton) {
                root.middleClicked();
            }
        }
        onWheel: wheel => root.wheel(wheel.angleDelta.y)
    }
}
