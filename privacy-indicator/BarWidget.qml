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

    property int updateCount: 0
    property bool checking: false

    implicitWidth: Math.round(buttonText.implicitWidth + Style.marginM * 2)
    implicitHeight: Style.capsuleHeight

    Layout.alignment: Qt.AlignVCenter
    radius: Style.radiusM
    color: root.updateCount > 0 ? Color.mErrorContainer : Style.capsuleColor

    Component.onCompleted: {
        Logger.i("UpdateIndicator", "BAR WIDGET LOADED!!!");
        checkForUpdates();
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: checkForUpdates()
    }

    function checkForUpdates() {
        root.checking = true;
        Logger.i("UpdateIndicator", "Checking for updates...");
        
        var process = Quickshell.Process.get("sh", ["-c", "checkupdates 2>/dev/null | wc -l"]);
        process.finished.connect(function() {
            var output = process.readAll().trim();
            root.updateCount = parseInt(output) || 0;
            root.checking = false;
            Logger.i("UpdateIndicator", "Found " + root.updateCount + " updates");
        });
        process.running = true;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            Logger.i("UpdateIndicator", "CLICKED! Opening panel...");
            if (pluginApi) {
                pluginApi.openPanel(root.screen);
            } else {
                Logger.e("UpdateIndicator", "pluginApi is null!");
            }
        }
        
        onEntered: {
            TooltipService.show(root, root.updateCount + " updates", BarService.getTooltipDirection());
        }
        
        onExited: {
            TooltipService.hide();
        }
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        text: root.checking ? "..." : (root.updateCount > 0 ? "↓ " + root.updateCount : "✓")
        color: root.updateCount > 0 ? Color.mOnErrorContainer : Color.mOnSurface
        font.pointSize: Style.fontSizeM
        font.bold: true
    }
}
