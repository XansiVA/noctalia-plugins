import QtQuick
import QtQuick.Layouts
import qs.Widgets
import qs.Commons

ColumnLayout {
    id: root
    
    property var pluginApi: null
    
    property int valueMinimumThreshold: pluginApi?.pluginSettings?.minimumThreshold || pluginApi?.manifest?.metadata?.defaultSettings?.minimumThreshold || 10
    property int valueAnimationSpeed: pluginApi?.pluginSettings?.animationSpeed || pluginApi?.manifest?.metadata?.defaultSettings?.animationSpeed || 100
    
    spacing: Style.marginM
    
    Component.onCompleted: {
        Logger.i("KeyboardWidget", "Settings UI loaded");
    }
    
    // Minimum Threshold Setting
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        
        NLabel {
            label: pluginApi?.tr("settings.minimumThreshold.label") || "Minimum CPU Threshold"
            description: pluginApi?.tr("settings.minimumThreshold.description") || "CPU usage percentage required to show active animation"
        }
        
        NSlider {
            id: thresholdSlider
            from: 1
            to: 50
            value: root.valueMinimumThreshold
            stepSize: 1
            onValueChanged: {
                root.valueMinimumThreshold = value
            }
        }
        
        Text {
            text: (pluginApi?.tr("settings.currentThreshold") || "Activate at {value}% CPU").replace("{value}", thresholdSlider.value)
            color: Color.mOnSurfaceVariant
            font.pointSize: Style.fontSizeS
        }
    }
    
    // Animation Speed Setting
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        
        NLabel {
            label: pluginApi?.tr("settings.animationSpeed.label") || "Animation Speed"
            description: pluginApi?.tr("settings.animationSpeed.description") || "Base speed for the animation (lower is faster)"
        }
        
        NSlider {
            id: speedSlider
            from: 50
            to: 300
            value: root.valueAnimationSpeed
            stepSize: 10
            onValueChanged: {
                root.valueAnimationSpeed = value
            }
        }
        
        Text {
            text: (pluginApi?.tr("settings.currentSpeed") || "Speed: {value}ms").replace("{value}", speedSlider.value)
            color: Color.mOnSurfaceVariant
            font.pointSize: Style.fontSizeS
        }
    }
    
    // Display Mode Setting
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginS
        
        NLabel {
            label: pluginApi?.tr("settings.displayMode.label") || "Display Mode"
            description: pluginApi?.tr("settings.displayMode.description") || "Choose how the indicator appears"
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS
            
            NButton {
                text: "Compact"
                highlighted: root.valueMinimumThreshold < 15
                onClicked: root.valueMinimumThreshold = 10
            }
            
            NButton {
                text: "Balanced"
                highlighted: root.valueMinimumThreshold >= 15 && root.valueMinimumThreshold < 25
                onClicked: root.valueMinimumThreshold = 20
            }
            
            NButton {
                text: "Relaxed"
                highlighted: root.valueMinimumThreshold >= 25
                onClicked: root.valueMinimumThreshold = 30
            }
        }
    }
    
    // Save function
    function saveSettings() {
        if (!pluginApi) {
            Logger.e("KeyboardWidget", "Cannot save settings: pluginApi is null");
            return;
        }
        
        pluginApi.pluginSettings.minimumThreshold = root.valueMinimumThreshold;
        pluginApi.pluginSettings.animationSpeed = root.valueAnimationSpeed;
        
        pluginApi.saveSettings();
        Logger.i("KeyboardWidget", "Settings saved successfully");
    }
}
