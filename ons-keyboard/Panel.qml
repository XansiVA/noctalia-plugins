import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.XmlListModel 2.15
import Qt.labs.settings 1.0  // For saving settings (system specs)

Item {
    id: neoPanel
    width: 600
    height: 400
    color: "#2D2D2D"  // Dark background like a terminal

    // Logo (SVG) from the distro
    Image {
        id: distroLogo
        width: 150
        height: 150
        source: "icons/distro-namelogo.svg"  // SVG logo of the distro
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20
    }

    // Text displaying system specs (loaded on startup)
    Column {
        anchors.top: distroLogo.bottom
        anchors.left: parent.left
        anchors.margins: 20
        spacing: 10

        Text {
            id: osText
            text: "OS: Loading..."
            color: "white"
            font.family: "Courier New"
            font.pixelSize: 18
        }

        Text {
            id: kernelText
            text: "Kernel: Loading..."
            color: "white"
            font.family: "Courier New"
            font.pixelSize: 18
        }

        Text {
            id: ramText
            text: "RAM: Loading..."
            color: "white"
            font.family: "Courier New"
            font.pixelSize: 18
        }

        Text {
            id: cpuText
            text: "CPU: Loading..."
            color: "white"
            font.family: "Courier New"
            font.pixelSize: 18
        }

        Text {
            id: diskText
            text: "Disk: Loading..."
            color: "white"
            font.family: "Courier New"
            font.pixelSize: 18
        }

        // Button to refresh the system data
        Button {
            text: "Refresh System Info"
            onClicked: {
                getSystemSpecs()
            }
            anchors.top: ramText.bottom
            anchors.left: parent.left
            anchors.margins: 20
        }
    }

    // Settings to store and load system specs (persistent data)
    Settings {
        id: systemSpecs
        property string os: ""
        property string kernel: ""
        property string ram: ""
        property string cpu: ""
        property string disk: ""
    }

    // Function to get system specs
    function getSystemSpecs() {
        // For demo, we simulate fetching system specs.
        // In a real-world scenario, you would use QProcess to get this data from the system.
        
        // Example data (you would replace these with actual system queries)
        var systemData = {
            os: "Ubuntu 20.04 LTS",
            kernel: "5.11.0-34-generic",
            ram: "16GB (8GB used)",
            cpu: "Intel Core i7-9700K @ 3.60GHz",
            disk: "256GB SSD (120GB used)"
        };

        // Set system specs into settings
        systemSpecs.os = systemData.os;
        systemSpecs.kernel = systemData.kernel;
        systemSpecs.ram = systemData.ram;
        systemSpecs.cpu = systemData.cpu;
        systemSpecs.disk = systemData.disk;

        // Update UI with the fetched data
        osText.text = "OS: " + systemSpecs.os;
        kernelText.text = "Kernel: " + systemSpecs.kernel;
        ramText.text = "RAM: " + systemSpecs.ram;
        cpuText.text = "CPU: " + systemSpecs.cpu;
        diskText.text = "Disk: " + systemSpecs.disk;
    }

    // Load saved system specs on startup
    Component.onCompleted: {
        if (systemSpecs.os === "") {
            getSystemSpecs();  // Fetch and store the data if not saved yet
        } else {
            // Use the saved data to populate the UI
            osText.text = "OS: " + systemSpecs.os;
            kernelText.text = "Kernel: " + systemSpecs.kernel;
            ramText.text = "RAM: " + systemSpecs.ram;
            cpuText.text = "CPU: " + systemSpecs.cpu;
            diskText.text = "Disk: " + systemSpecs.disk;
        }
    }
}
