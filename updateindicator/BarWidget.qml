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

    property string tooltipText
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
    color: "transparent"
    radius: Math.min((customRadius >= 0 ? customRadius : Style.iRadiusL), width / 2)
    border.color: "transparent"
    border.width: 0

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

    property int updateCount: 0
    property bool checking: false
    
    // Detect Light Mode (Dark Text = Light Mode)
    readonly property bool isLightMode: (Color.mOnSurface.r * 0.299 + Color.mOnSurface.g * 0.587 + Color.mOnSurface.b * 0.114) < 0.5
    readonly property string iconPrefix: isLightMode ? "icons/black/" : "icons/"

    readonly property var updateIcon: root.iconPrefix + (updateCount > 0 ? "update-available.svg" : "update-none.svg")

    Component.onCompleted: {
        checkForUpdates();
    }

    Timer {
        interval: (pluginApi?.pluginSettings?.checkInterval || 3600) * 1000
        running: true
        repeat: true
        onTriggered: checkForUpdates()
    }

    function checkForUpdates() {
        root.checking = true;
        
        var process = Quickshell.Process.get("sh", ["-c", "checkupdates 2>/dev/null | wc -l"]);
        process.finished.connect(function() {
            var output = process.readAll().trim();
            root.updateCount = parseInt(output) || 0;
            root.checking = false;
        });
        process.running = true;
    }

    currentIconSource: Qt.resolvedUrl(root.updateIcon)

    tooltipText: {
        if (!pluginApi) return "No API";
        if (root.checking) return pluginApi.tr("tooltip.checking") || "Checking...";
        if (root.updateCount > 0) {
            return (pluginApi.tr("tooltip.updatesAvailable") || "{count} updates available").replace("{count}", root.updateCount);
        }
        return pluginApi.tr("tooltip.upToDate") || "Up to date";
    }
    
    Image {
        id: iconImage
        source: root.currentIconSource
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -3
        anchors.verticalCenterOffset: -1
        
        width: {
            switch (root.density) {
            case "compact":
                return Math.max(1, root.width * 0.85);
            default:
                return Math.max(1, root.width * 0.85);
            }
        }
        height: width
        
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        visible: true
    }
    
    // Update count badge
    Rectangle {
        visible: root.updateCount > 0
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 2
        width: Math.max(12, badgeText.width + 4)
        height: 12
        radius: 6
        color: Color.mError

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: root.updateCount > 99 ? "99+" : root.updateCount
            color: Color.mOnError
            font.pointSize: 6
            font.bold: true
        }
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
                var result = pluginApi.openPanel(root.screen);
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
