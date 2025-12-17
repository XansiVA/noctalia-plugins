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
    
    // FileView to read system files directly
    FileView {
        id: hostnameFile
        path: "file:///etc/hostname"
        blockLoading: true
        
        Component.onCompleted: {
            console.log("hostnameFile loaded, text length:", text().length)
            console.log("hostnameFile content:", text())
        }
    }
    
    FileView {
        id: osReleaseFile
        path: "file:///etc/os-release"
        blockLoading: true
        
        Component.onCompleted: {
            console.log("osReleaseFile loaded, text length:", text().length)
        }
    }
    
    FileView {
        id: cpuinfoFile
        path: "file:///proc/cpuinfo"
        blockLoading: true
        
        Component.onCompleted: {
            console.log("cpuinfoFile loaded, text length:", text().length)
        }
    }
    
    FileView {
        id: meminfoFile
        path: "file:///proc/meminfo"
        blockLoading: true
        
        Component.onCompleted: {
            console.log("meminfoFile loaded, text length:", text().length)
        }
    }
    
    // Process for getting network type
    Process {
        id: networkProc
        command: ["sh", "-c", "ip route get 1.1.1.1 | grep -oP 'dev \\K\\S+' | head -n1"]
        running: true
    }
    
    // Process for getting GPU info
    Process {
        id: gpuProc
        command: ["sh", "-c", "lspci | grep -i 'vga\\|3d\\|display' | head -n1 | cut -d':' -f3"]
        running: true
    }
    
    // Process for WM detection
    Process {
        id: wmProc
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        running: true
    }
    
    // Process for package counts
    Process {
        id: pacmanProc
        command: ["sh", "-c", "pacman -Qq 2>/dev/null | wc -l"]
        running: true
    }
    
    Process {
        id: nixProc
        command: ["sh", "-c", "nix-env --query 2>/dev/null | wc -l"]
        running: true
    }
    
    Process {
        id: xbpsProc
        command: ["sh", "-c", "xbps-query -l 2>/dev/null | wc -l"]
        running: true
    }
    
    Process {
        id: gentooProc
        command: ["sh", "-c", "qlist -I 2>/dev/null | wc -l"]
        running: true
    }
    
    // Parse system info from files
    readonly property string hostname: {
        var text = hostnameFile.text().trim()
        console.log("Hostname:", text)
        return text || "Unknown"
    }
    
    readonly property string distro: {
        var text = osReleaseFile.text()
        console.log("os-release length:", text.length)
        if (text.length === 0) return "Linux"
        
        var lines = text.split('\n')
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].startsWith('PRETTY_NAME=')) {
                var result = lines[i].substring(13).replace(/"/g, '')
                console.log("Distro:", result)
                return result
            }
        }
        return "Linux"
    }
    
    readonly property string cpu: {
        var text = cpuinfoFile.text()
        console.log("cpuinfo length:", text.length)
        if (text.length === 0) return "Unknown CPU"
        
        var lines = text.split('\n')
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf('model name') !== -1) {
                var result = lines[i].split(':')[1].trim()
                console.log("CPU:", result)
                return result
            }
        }
        return "Unknown CPU"
    }
    
    readonly property string ramInfo: {
        var text = meminfoFile.text()
        console.log("meminfo length:", text.length)
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
            var result = usedGB + " GB / " + totalGB + " GB"
            console.log("RAM:", result)
            return result
        }
        return "? GB / ? GB"
    }
    
    readonly property string networkType: {
        var iface = networkProc.stdout.trim()
        console.log("Network interface:", iface)
        if (iface.startsWith('wl')) return "WiFi (" + iface + ")"
        if (iface.startsWith('en') || iface.startsWith('eth')) return "Ethernet (" + iface + ")"
        return iface || "Unknown"
    }
    
    readonly property string gpu: {
        var gpuText = gpuProc.stdout.trim()
        console.log("GPU:", gpuText)
        return gpuText || "Unknown GPU"
    }
    
    readonly property string wm: {
        var desktop = wmProc.stdout.trim().toLowerCase()
        console.log("XDG_CURRENT_DESKTOP:", desktop)
        
        // Check common WM names
        if (desktop.includes('niri')) return "niri"
        if (desktop.includes('hyprland')) return "Hyprland"
        if (desktop.includes('sway')) return "Sway"
        if (desktop.includes('mango')) return "mangowc"
        
        // Fallback - just return what we got
        return desktop || "Unknown WM"
    }
    
    readonly property string packages: {
        var pkgs = []
        
        var pacman = parseInt(pacmanProc.stdout.trim())
        if (pacman > 0) pkgs.push(pacman + " (pacman)")
        
        var nix = parseInt(nixProc.stdout.trim())
        if (nix > 0) pkgs.push(nix + " (nix)")
        
        var xbps = parseInt(xbpsProc.stdout.trim())
        if (xbps > 0) pkgs.push(xbps + " (xbps)")
        
        var gentoo = parseInt(gentooProc.stdout.trim())
        if (gentoo > 0) pkgs.push(gentoo + " (gentoo)")
        
        console.log("Packages:", pkgs.join(", "))
        return pkgs.length > 0 ? pkgs.join(", ") : "0"
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
                    value: hostname || "Unknown"
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
                    value: gpu
                }
                
                InfoRow {
                    label: "Network"
                    value: networkType
                }
                
                InfoRow {
                    label: "WM"
                    value: wm
                }
                
                InfoRow {
                    label: "Packages"
                    value: packages
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
