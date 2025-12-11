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
    
    property real contentPreferredWidth: 1600 * Style.uiScaleRatio
    property real contentPreferredHeight: 308 * Style.uiScaleRatio

    // Persistent data for system specs
    readonly property var systemSpecs: {
        os: "",
        kernel: "",
        ram: "",
        cpu: "",
        disk: ""
    }

    // Container for the panel
    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.margins: Style.marginL
        color: Color.mSurface
        radius: Style.radiusL
        border.color: Color.mOutline
        border.width: Style.borderS

        Column {
            spacing: 10
            anchors.centerIn: parent
            anchors.margins: 20

            // Display the distro logo (SVG)
            Image {
                id: distroLogo
                width: 120
                height: 120
                source: "icons/distro-namelogo.svg"  // Replace with your actual SVG logo
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // System Specs Display
            Text {
                id: osText
                text: "OS: " + systemSpecs.os
                color: "white"
                font.family: "Courier New"
                font.pixelSize: 18
            }

            Text {
                id: kernelText
                text: "Kernel: " + systemSpecs.kernel
                color: "white"
                font.family: "Courier New"
                font.pixelSize: 18
            }

            Text {
                id: ramText
                text: "RAM: " + systemSpecs.ram
                color: "white"
                font.family: "Courier New"
                font.pixelSize: 18
            }

            Text {
                id: cpuText
                text: "CPU: " + systemSpecs.cpu
                color: "white"
                font.family: "Courier New"
                font.pixelSize: 18
            }

            Text {
                id: diskText
                text: "Disk: " + systemSpecs.disk
                color: "white"
                font.family: "Courier New"
                font.pixelSize: 18
            }

            // Button to refresh system specs
            Button {
                text: "Refresh System Info"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    getSystemSpecs()
                }
            }
        }
    }

    // Settings to store and load system specs
    Settings {
        id: systemSpecsSettings
        property string os: ""
        property string kernel: ""
        property string ram: ""
        property string cpu: ""
        property string disk: ""
    }

    // Function to fetch system specs (this is just a mock function for now)
    function getSystemSpecs() {
        // Here you can implement real system queries with QProcess (e.g., uname, free, df)
        var systemData = {
            os: "Ubuntu 20.04 LTS",
            kernel: "5.11.0-34-generic",
            ram: "16GB (8GB used)",
            cpu: "Intel Core i7-9700K @ 3.60GHz",
            disk: "256GB SSD (120GB used)"
        };

        // Store in settings
        systemSpecsSettings.os = systemData.os;
        systemSpecsSettings.kernel = systemData.kernel;
        systemSpecsSettings.ram = systemData.ram;
        systemSpecsSettings.cpu = systemData.cpu;
        systemSpecsSettings.disk = systemData.disk;

        // Update UI with the fetched data
        osText.text = "OS: " + systemSpecsSettings.os;
        kernelText.text = "Kernel: " + systemSpecsSettings.kernel;
        ramText.text = "RAM: " + systemSpecsSettings.ram;
        cpuText.text = "CPU: " + systemSpecsSettings.cpu;
        diskText.text = "Disk: " + systemSpecsSettings.disk;
    }

    // Load saved system specs on startup
    Component.onCompleted: {
        if (systemSpecsSettings.os === "") {
            getSystemSpecs();  // Fetch and store the data if not saved yet
        } else {
            // Use saved data to populate the UI
            osText.text = "OS: " + systemSpecsSettings.os;
            kernelText.text = "Kernel: " + systemSpecsSettings.kernel;
            ramText.text = "RAM: " + systemSpecsSettings.ram;
            cpuText.text = "CPU: " + systemSpecsSettings.cpu;
            diskText.text = "Disk: " + systemSpecsSettings.disk;
        }
    }
}
