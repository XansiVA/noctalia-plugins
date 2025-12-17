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
    
    // Adjusted size for neofetch display
    property real contentPreferredWidth: 800 * Style.uiScaleRatio
    property real contentPreferredHeight: 400 * Style.uiScaleRatio
    
    // SystemInfo object - create from C++ backend
    property var systemInfo: null
    
    Component.onCompleted: {
        console.log("Panel loaded - attempting to get system info from C++ backend")
        
        // Try to get SystemInfo from the plugin context
        if (pluginApi && pluginApi.systemInfo) {
            systemInfo = pluginApi.systemInfo
            console.log("SystemInfo loaded from pluginApi")
        }
    }
    
    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.margins: Style.marginL
        color: Color.mSurface
        radius: Style.radiusL
        border.color: Color.mOutline
        border.width: Style.borderS
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Style.marginXL
            spacing: Style.marginXL
            
            // Distro logo
            Image {
                id: distroLogo
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignVCenter
                source: "https://raw.githubusercontent.com/XansiVA/noctalia-plugins/main/ons-keyboard/icons/arch.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
                
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("Failed to load image from:", source)
                    } else if (status === Image.Ready) {
                        console.log("Image loaded successfully from GitHub")
                    } else if (status === Image.Loading) {
                        console.log("Loading image from GitHub...")
                    }
                }
            }
            
            // System info
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Style.marginM
                
                Text {
                    text: "Xansi's System Info :3"
                    color: Color.mPrimary
                    font.family: "Monospace"
                    font.pixelSize: 24
                    font.bold: true
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: Color.mOutline
                }
                
                InfoRow {
                    label: "Hostname"
                    value: systemInfo ? systemInfo.hostname : "Loading..."
                }
                
                InfoRow {
                    label: "Distro"
                    value: systemInfo ? systemInfo.distro : "Loading..."
                }
                
                InfoRow {
                    label: "CPU"
                    value: systemInfo ? systemInfo.cpu : "Loading..."
                }
                
                InfoRow {
                    label: "Memory"
                    value: systemInfo ? (systemInfo.ramUsed + " / " + systemInfo.ramTotal) : "Loading..."
                }
                
                InfoRow {
                    label: "CPU Temp"
                    value: systemInfo ? systemInfo.cpuTemp : "Loading..."
                }
                
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
    
    // Info row component
    component InfoRow: RowLayout {
        property string label: ""
        property string value: ""
        
        Layout.fillWidth: true
        spacing: Style.marginM
        
        Text {
            text: label + ":"
            color: Color.mSecondary
            font.family: "Monospace"
            font.pixelSize: 16
            font.bold: true
            Layout.preferredWidth: 100
        }
        
        Text {
            text: value
            color: "white"
            font.family: "Monospace"
            font.pixelSize: 16
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
