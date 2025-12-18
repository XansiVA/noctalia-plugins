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
    
    // State properties for dynamic data that needs Process
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
    
    // GPU info from sysfs
    FileView {
        id: gpuVendorFile
        path: "file:///sys/class/drm/card0/device/vendor"
        blockLoading: false
    }
    
    FileView {
        id: gpuDeviceFile
        path: "file:///sys/class/drm/card0/device/device"
        blockLoading: false
    }
    
    // Network - check for active interfaces
    FileView {
        id: netDevFile
        path: "file:///proc/net/dev"
        blockLoading: false
    }
    
    // Fallback Process for WM (needs environment variable)
    Process {
        id: wmProc
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP || wmctrl -m 2>/dev/null | grep Name | cut -d' ' -f2"]
        running: false
        
        onExited: {
            console.log("WM process exited with code:", exitCode)
            var desktop = stdout.trim().toLowerCase()
            console.log("WM output:", desktop)
            
            if (desktop.includes('niri')) wmValue = "niri"
            else if (desktop.includes('hyprland')) wmValue = "Hyprland"
            else if (desktop.includes('sway')) wmValue = "Sway"
            else if (desktop.includes('mango')) wmValue = "mangowc"
            else if (desktop.includes('kde')) wmValue = "KDE"
            else if (desktop.includes('gnome')) wmValue = "GNOME"
            else if (desktop) wmValue = desktop
            else wmValue = "Unknown WM"
        }
        
        Component.onCompleted: {
            running = true
        }
    }
    
    // Process for package counts
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
            
            packagesValue = pkgs.length > 0 ? pkgs.join(", ") : "0"
        }
        
        Component.onCompleted: {
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
    
    readonly property string gpu: {
        var vendor = gpuVendorFile.text().trim()
        var device = gpuDeviceFile.text().trim()
        
        // Map vendor IDs to names
        var vendorName = ""
        if (vendor === "0x8086") vendorName = "Intel"
        else if (vendor === "0x10de") vendorName = "NVIDIA"
        else if (vendor === "0x1002") vendorName = "AMD"
        
        // If we have vendor info, show it
        if (vendorName) {
            return vendorName + " GPU (Device: " + device + ")"
        }
        
        // Fallback: try to read modalias which often has useful info
        return "GPU " + device
    }
    
    readonly property string networkType: {
        var text = netDevFile.text()
        if (text.length === 0) return "Unknown"
        
        var lines = text.split('\n')
        // Skip header lines
        for (var i = 2; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.length === 0) continue
            
            var iface = line.split(':')[0].trim()
            // Skip loopback
            if (iface === 'lo') continue
            
            // Check if interface has activity (received bytes > 0)
            var parts = line.split(/\s+/)
            if (parts.length > 1 && parseInt(parts[1]) > 0) {
                if (iface.startsWith('wl')) return "WiFi (" + iface + ")"
                if (iface.startsWith('en') || iface.startsWith('eth')) return "Ethernet (" + iface + ")"
                return iface
            }
        }
        return "No active connection"
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
                Layout.preferredWidth: 180
                Layout.preferredHeight: 180
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                source: "https://raw.githubusercontent.com/XansiVA/noctalia-plugins/main/panelfetch/icons/arch.svg"
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
                    value: gpu
                }
                
                InfoRow {
                    label: "Network"
                    value: networkType
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
