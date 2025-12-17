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
    
    // System info properties
    property string hostname: ""
    property string distro: "Arch Linux"
    property string cpu: ""
    property string ramUsed: ""
    property string ramTotal: ""
    property string cpuTemp: ""
    
    Component.onCompleted: {
        fetchSystemInfo()
    }
    
    function fetchSystemInfo() {
        // Hostname
        var hostnameProc = pluginApi.createProcess("hostname")
        hostnameProc.readyReadStandardOutput.connect(function() {
            hostname = hostnameProc.readAllStandardOutput().trim()
        })
        hostnameProc.start()
        
        // CPU info
        var cpuProc = pluginApi.createProcess("sh")
        cpuProc.setArguments(["-c", "cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d':' -f2"])
        cpuProc.readyReadStandardOutput.connect(function() {
            cpu = cpuProc.readAllStandardOutput().trim()
        })
        cpuProc.start()
        
        // RAM info
        var ramProc = pluginApi.createProcess("sh")
        ramProc.setArguments(["-c", "free -h | awk '/^Mem:/ {print $3 \" / \" $2}'"])
        ramProc.readyReadStandardOutput.connect(function() {
            var ramInfo = ramProc.readAllStandardOutput().trim()
            ramUsed = ramInfo
        })
        ramProc.start()
        
        // CPU Temperature
        var tempProc = pluginApi.createProcess("sh")
        tempProc.setArguments(["-c", "sensors | grep 'Package id 0:' | awk '{print $4}' || sensors | grep 'Tdie:' | awk '{print $2}' || echo 'N/A'"])
        tempProc.readyReadStandardOutput.connect(function() {
            cpuTemp = tempProc.readAllStandardOutput().trim()
        })
        tempProc.start()
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
                source: "file:///icons/arch.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
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
                    value: hostname || "fetching..."
                }
                
                InfoRow {
                    label: "Distro"
                    value: distro
                }
                
                InfoRow {
                    label: "CPU"
                    value: cpu || "fetching..."
                }
                
                InfoRow {
                    label: "Memory"
                    value: ramUsed || "fetching..."
                }
                
                InfoRow {
                    label: "CPU Temp"
                    value: cpuTemp || "fetching..."
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
