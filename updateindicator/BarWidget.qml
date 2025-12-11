import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

// Bar Widget Component
NIconButton {
    id: root
    
    property var pluginApi: null
    
    // Required properties for bar widgets
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    
    icon: "input-keyboard"
    tooltipText: pluginApi?.tr("tooltip.open-keyboard") || "Open Keyboard"
    tooltipDirection: BarService.getTooltipDirection()
    
    baseSize: Style.capsuleHeight
    applyUiScale: false
    density: Settings.data.bar.density
    customRadius: Style.radiusL
    
    colorBg: Style.capsuleColor
    colorFg: Color.mOnSurface
    colorBorder: Color.transparent
    colorBorderHover: Color.transparent
    
    onClicked: {
        Logger.i("KeyboardWidget", "Clicked! API:", !!pluginApi, "Screen:", screen ? screen.name : "null");
        
        if (pluginApi) {
            var result = pluginApi.openPanel(screen);
            Logger.i("KeyboardWidget", "OpenPanel result:", result);
        } else {
            Logger.e("KeyboardWidget", "PluginAPI is null");
        }
    }
}
