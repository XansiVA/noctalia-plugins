import QtQuick
import QtQuick.Layouts
import qs.Widgets
import qs.Commons


//I hate QML so much I had to dig in docs for this shi.
ColumnLayout {
    id: root
    
    property var pluginApi: null
    
    property int valueCheckInterval: pluginApi?.pluginSettings?.checkInterval || pluginApi?.manifest?.metadata?.defaultSettings?.checkInterval || 3600
    property string valuePreferredTerminal: pluginApi?.pluginSettings?.preferredTerminal || pluginApi?.manifest?.metadata?.defaultSettings?.preferredTerminal || "alacritty"
    
    spacing: Style.marginM
    
    Component.onCompleted: {
        Logger.i("UpdateIndicator", "Settings UI loaded");
    }
    
    // Check Interval Setting
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        
        NLabel {
            label: pluginApi?.tr("settings.checkInterval.label") || "Check Interval"
            description: pluginApi?.tr("settings.checkInterval.description") || "How often to check for updates (in minutes)"
        }
        
        NSlider {
            id: intervalSlider
            from: 5
            to: 180
            value: root.valueCheckInterval / 60
            stepSize: 5
            onValueChanged: {
                root.valueCheckInterval = value * 60
            }
        }
        
        Text {
            text: (pluginApi?.tr("settings.currentInterval") || "Check every {value} minutes").replace("{value}", intervalSlider.value)
            color: Color.mOnSurfaceVariant
            font.pointSize: Style.fontSizeS
        }
    }
    
    // Terminal Preference Setting
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        
        NLabel {
            label: pluginApi?.tr("settings.terminal.label") || "Preferred Terminal"
            description: pluginApi?.tr("settings.terminal.description") || "Which terminal to use for running updates"
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS
            
            NButton {
                text: "alacritty"
                highlighted: root.valuePreferredTerminal === "alacritty"
                onClicked: root.valuePreferredTerminal = "alacritty"
            }
            
            NButton {
                text: "kitty"
                highlighted: root.valuePreferredTerminal === "kitty"
                onClicked: root.valuePreferredTerminal = "kitty"
            }
            
            NButton {
                text: "konsole"
                highlighted: root.valuePreferredTerminal === "konsole"
                onClicked: root.valuePreferredTerminal = "konsole"
            }
        }
        
        Text {
            text: (pluginApi?.tr("settings.currentTerminal") || "Selected: {terminal}").replace("{terminal}", root.valuePreferredTerminal)
            color: Color.mOnSurfaceVariant
            font.pointSize: Style.fontSizeS
        }
    }
    
    // Save function
    function saveSettings() {
        if (!pluginApi) {
            Logger.e("UpdateIndicator", "Cannot save settings: pluginApi is null");
            return;
        }
        
        pluginApi.pluginSettings.checkInterval = root.valueCheckInterval;
        pluginApi.pluginSettings.preferredTerminal = root.valuePreferredTerminal;
        
        pluginApi.saveSettings();
        Logger.i("UpdateIndicator", "Settings saved successfully");
    }
}
