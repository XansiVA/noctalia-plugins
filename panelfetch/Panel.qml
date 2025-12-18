import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Io
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
    
    // State properties for dynamic data
    property string networkTypeValue: "Loading..."
    property string gpuValue: "Loading..."
    property string wmValue: "Loading..."
    property string packagesValue: "Loading..."
    
    // FileView to read system files directly
    FileView {
        id: hostnameFile
        path: "file:///etc/hostname"
        blockLoading: false
    }
    
    FileView {
        id: osReleaseFile
        path: "file:///etc/os-release"
        blockLoading: false
    }
    
    FileView {
        id: cpuinfoFile
        path: "file:///proc/cpuinfo"
        blockLoading: false
    }
    
    FileView {
        id: meminfoFile
        path: "file:///proc/meminfo"
        blockLoading: false
    }
    
    // Process for getting network type
    Process {
        id: networkProc
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \\K\\S+' | head -n1"]
        running: false
        
        onExited: {
            console.log("Network process exited with code:", exitCode)
            var iface = stdout.trim()
            console.log("Network interface output:", iface)
            if (iface.startsWith('wl')) networkTypeValue = "WiFi (" + iface + ")"
            else if (iface.startsWith('en') || iface.startsWith('eth')) networkTypeValue = "Ethernet (" + iface + ")"
            else if (iface) networkTypeValue = iface
            else networkTypeValue = "Unknown"
        }
        
        Component.onCompleted: {
            console.log("Starting network process...")
            running = true
        }
    }
    
    // Process for getting GPU info
    Process {
        id: gpuProc
        command: ["sh", "-c", "lspci 2>/dev/null | grep -i 'vga\\|3d\\|display' | head -n1 | cut -d':' -f3"]
        running: false
        
        onExited: {
            console.log("GPU process exited with code:", exitCode)
            var gpuText = stdout.trim()
            console.log("GPU output:", gpuText)
            gpuValue = gpuText || "Unknown GPU"
        }
        
        Component.onCompleted: {
            console.log("Starting GPU process...")
            running = true
        }
    }
    
    // Process for WM detection
    Process {
        id: wmProc
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        running: false
        
        onExited: {
            console.log("WM process exited with code:", exitCode)
            var desktop = stdout.trim().toLowerCase()
            console.log("XDG_CURRENT_DESKTOP output:", desktop)
            
            // Check common WM names
            if (desktop.includes('niri')) wmValue = "niri"
            else if (desktop.includes('hyprland')) wmValue = "Hyprland"
            else if (desktop.includes('sway')) wmValue = "Sway"
            else if (desktop.includes('mango')) wmValue = "mangowc"
            else if (desktop) wmValue = desktop
            else wmValue = "Unknown WM"
        }
        
        Component.onCompleted: {
            console.log("Starting WM process...")
            running = true
        }
    }
    
    // Process for package counts - combined into one script
    Process {
        id: packageProc
        command: ["sh", "-c", `
            PACMAN=$(pacman -Qq 2>/dev/null | wc -l)
            NIX=$(nix-env --query 2>/dev/null | wc -l)
            XBPS=$(xbps-query -l 2>/dev/null | wc -l)
            GENTOO=$(qlist -I 2>/dev/null | wc -l)
            echo "$PACMAN|$NIX|$XBPS|$GENTOO"
        `]
        running: false
        
        onExited: {
            console.log("Package process exited with code:", exitCode)
            console.log("Package output:", stdout)
            var counts = stdout.trim().split('|')
            var pkgs = []
            
            var pacman = parseInt(counts[0] || "0")
            if (pacman > 0) pkgs.push(pacman + " (pacman)")
            
            var nix = parseInt(counts[1] || "0")
            if (nix > 0) pkgs.push(nix + " (nix)")
            
            var xbps = parseInt(counts[2] || "0")
            if (xbps > 0) pkgs.push(xbps + " (xbps)")
            
            var gentoo = parseInt(counts[3] || "0")
            if (gentoo > 0) pkgs.push(gentoo + " (gentoo)")
            
            console.log("Parsed packages:", pkgs.join(", "))
            packagesValue = pkgs.length > 0 ? pkgs.join(", ") : "0"
        }
        
        Component.onCompleted: {
            console.log("Starting package process...")
            running = true
        }
    }
    
    // Parse system info from files
    readonly property string hostname: {
        var text = hostnameFile.text().trim()
        return text || "Unknown"
    }
    
    readonly property string distro: {
        var text = osReleaseFile.text()
        if (text.length === 0) return "Linux"
        
        var lines = text.split('\n')
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].startsWith('PRETTY_NAME=')) {
                return lines[i].substring(13).replace(/"/g, '')
            }
        }
        return "Linux"
    }
    
    readonly property string cpu: {
        var text = cpuinfoFile.text()
        if (text.length === 0) return "Unknown CPU"
        
        var lines = text.split('\n')
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf('model name') !== -1) {
                return lines[i].split(':')[1].trim()
            }
        }
        return "Unknown CPU"
    }
    
    readonly property string ramInfo: {
        var text = meminfoFile.text()
        if (text.length === 0) return "? GB / ? GB"
        
        var lines = text.split('\n')
        var total = 0
        var available = 0
        
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].startsWith('MemTotal:')) {
                total = parseInt(lines[i].split(/\s+/)[1])
            } else if (lines[i].startsWith('MemAvailable:')) {
                available = parseInt(lines[i].split(/\s+/)[1])
            }
        }
        
        if (total > 0) {
            var used = total - available
            var usedGB = (used / 1024 / 1024).toFixed(1)
            var totalGB = (total / 1024 / 1024).toFixed(1)
            return usedGB + " GB / " + totalGB + " GB"
        }
        return "? GB / ? GB"
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
            
            // Distro logo - moved to top left
            Image {
                id: distroLogo
                Layout.preferredWidth: 180
                Layout.preferredHeight: 180
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                source: "https://raw.githubusercontent.com/XansiVA/noctalia-plugins/main/panelfetch/icons/arch.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
                
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("Failed to load image from:", source)
                    } else if (status === Image.Ready) {
                        console.log("Image loaded successfully from GitHub")
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
                    value: hostname
                }
                
                InfoRow {
                    label: "Distro"
                    value: distro
                }
                
                InfoRow {
                    label: "CPU"
                    value: cpu
                }
                
                InfoRow {
                    label: "Memory"
                    value: ramInfo
                }
                
                InfoRow {
                    label: "GPU"
                    value: gpuValue
                }
                
                InfoRow {
                    label: "Network"
                    value: networkTypeValue
                }
                
                InfoRow {
                    label: "WM"
                    value: wmValue
                }
                
                InfoRow {
                    label: "Packages"
                    value: packagesValue
                }
                
                InfoRow {
                    label: "CPU Temp"
                    value: "N/A (needs sensors)"
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
