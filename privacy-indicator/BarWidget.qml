import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Rectangle {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    readonly property string barPosition: Settings.data.bar.position
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"

    property int updateCount: 0
    property bool checking: false
    property string lastUpdateTime: "Unknown"

    implicitWidth: isVertical ? Style.capsuleHeight : Math.round(layout.implicitWidth + Style.marginM * 2)
    implicitHeight: isVertical ? Math.round(layout.implicitHeight + Style.marginM * 2) : Style.capsuleHeight

    Layout.alignment: Qt.AlignVCenter
    radius: Style.radiusM
    color: Style.capsuleColor

    Component.onCompleted: {
        checkForUpdates();
        checkLastUpdateTime();
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
            Logger.i("UpdateIndicator", "Found " + root.updateCount + " updates");
        });
        process.running = true;
    }

    function checkLastUpdateTime() {
        var process = Quickshell.Process.get("sh", ["-c", "grep 'starting full system upgrade' /var/log/pacman.log | tail -1 | awk '{print $1, $2}'"]);
        process.finished.connect(function() {
            var output = process.readAll().trim();
            root.lastUpdateTime = output || "Unknown";
            Logger.i("UpdateIndicator", "Last update: " + root.lastUpdateTime);
        });
        process.running = true;
    }

    function buildTooltip() {
        if (root.checking) return pluginApi?.tr("tooltip.checking") || "Checking for updates...";
        if (root.updateCount > 0) {
            return (pluginApi?.tr("tooltip.updatesAvailable") || "{count} updates available").replace("{count}", root.updateCount);
        }
        return pluginApi?.tr("tooltip.upToDate") || "System up to date";
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onEntered: {
            var tooltipText = buildTooltip();
            if (tooltipText) {
                TooltipService.show(root, tooltipText, BarService.getTooltipDirection());
            }
        }
        
        onExited: TooltipService.hide()
        
        onClicked: function(mouse) {
            TooltipService.hide();
            
            if (mouse.button === Qt.LeftButton) {
                Logger.i("UpdateIndicator", "Opening panel");
                if (pluginApi) {
                    pluginApi.openPanel(root.screen);
                }
            }
        }
    }

    Item {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: rowLayout.visible ? rowLayout.implicitWidth : colLayout.implicitWidth
        implicitHeight: rowLayout.visible ? rowLayout.implicitHeight : colLayout.implicitHeight

        RowLayout {
            id: rowLayout
            visible: !root.isVertical
            spacing: Style.marginXS

            NIcon {
                icon: root.updateCount > 0 ? "system-software-update" : "emblem-default"
                color: root.updateCount > 0 ? Color.mError : Color.mPrimary
            }

            Text {
                visible: root.updateCount > 0
                text: root.updateCount > 99 ? "99+" : root.updateCount
                color: Color.mOnSurface
                font.pointSize: Style.fontSizeS
                font.bold: true
            }
        }

        ColumnLayout {
            id: colLayout
            visible: root.isVertical
            spacing: Style.marginXS

            NIcon {
                icon: root.updateCount > 0 ? "system-software-update" : "emblem-default"
                color: root.updateCount > 0 ? Color.mError : Color.mPrimary
            }

            Text {
                visible: root.updateCount > 0
                text: root.updateCount > 99 ? "99+" : root.updateCount
                color: Color.mOnSurface
                font.pointSize: Style.fontSizeXS
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
