import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services
import qs.Commons
import qs.Services.System
import qs.Widgets

Item {
    id: root
    property var pluginApi: null

    // SmartPanel properties
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true
    property real contentPreferredWidth: 300 * Style.uiScaleRatio
    property real contentPreferredHeight: 450 * Style.uiScaleRatio

    anchors.fill: parent

    property string lastUpdateTime: "Unknown"
    property int updateCount: 0
    property string updateList: ""
    property bool checking: false

    Component.onCompleted: {
        checkLastUpdateTime();
        checkForUpdates();
    }

    function checkLastUpdateTime() {
        var process = Quickshell.Process.get("sh", ["-c", "grep 'starting full system upgrade' /var/log/pacman.log | tail -1 | awk '{print $1, $2}'"]);
        process.finished.connect(function() {
            var output = process.readAll().trim();
            root.lastUpdateTime = output || "Never";
            Logger.i("UpdateIndicator", "Last update: " + root.lastUpdateTime);
        });
        process.running = true;
    }

    function checkForUpdates() {
        root.checking = true;
        root.updateList = "Checking...";
        
        var process = Quickshell.Process.get("sh", ["-c", "checkupdates 2>/dev/null"]);
        process.finished.connect(function() {
            var output = process.readAll().trim();
            if (output.length > 0) {
                root.updateList = output;
                root.updateCount = output.split('\n').length;
            } else {
                root.updateList = "No updates available";
                root.updateCount = 0;
            }
            root.checking = false;
            Logger.i("UpdateIndicator", "Update check complete: " + root.updateCount + " updates");
        });
        process.running = true;
    }

    function findTerminal() {
        var terminals = ["alacritty", "kitty", "konsole", "gnome-terminal", "xterm"];
        
        for (var i = 0; i < terminals.length; i++) {
            var process = Quickshell.Process.get("which", [terminals[i]]);
            process.finished.connect(function() {
                var output = process.readAll().trim();
                if (output.length > 0) {
                    Logger.i("UpdateIndicator", "Found terminal: " + terminals[i]);
                    return terminals[i];
                }
            });
            process.running = true;
        }
        
        return pluginApi?.pluginSettings?.preferredTerminal || "alacritty";
    }

    function runUpdateCommand(command) {
        var terminal = findTerminal();
        Logger.i("UpdateIndicator", "Running: " + terminal + " -e " + command);
        
        var process = Quickshell.Process.get(terminal, ["-e", "sh", "-c", command + "; echo 'Press ENTER to close'; read"]);
        process.running = true;
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: Color.transparent

        Rectangle {
            anchors.fill: parent
            anchors.margins: Style.marginL
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Color.mOutline
            border.width: Style.borderS

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginL
                spacing: Style.marginM

                // Header
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: pluginApi?.tr("panel.title") || "System Updates"
                    font.pointSize: Style.fontSizeXL
                    font.weight: Font.Bold
                    color: Color.mOnSurface
                }

                // Last Update Time
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    Text {
                        text: pluginApi?.tr("panel.lastUpdate") || "Last Update:"
                        font.pointSize: Style.fontSizeM
                        color: Color.mOnSurfaceVariant
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.lastUpdateTime
                        font.pointSize: Style.fontSizeM
                        font.weight: Font.Medium
                        color: Color.mOnSurface
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Update Count
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: root.updateCount > 0 ? Color.mErrorContainer : Color.mPrimaryContainer
                    radius: Style.radiusM

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.marginXS

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.checking ? "..." : root.updateCount.toString()
                            font.pointSize: Style.fontSizeXXL
                            font.weight: Font.Bold
                            color: root.updateCount > 0 ? Color.mOnErrorContainer : Color.mOnPrimaryContainer
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: pluginApi?.tr("panel.updatesAvailable") || "Updates Available"
                            font.pointSize: Style.fontSizeS
                            color: root.updateCount > 0 ? Color.mOnErrorContainer : Color.mOnPrimaryContainer
                        }
                    }
                }

                // Package List
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Color.mSurfaceContainer
                    radius: Style.radiusM
                    border.color: Color.mOutline
                    border.width: 1

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: Style.marginS
                        contentHeight: packageText.height
                        clip: true

                        Text {
                            id: packageText
                            width: parent.width
                            text: root.updateList
                            font.pointSize: Style.fontSizeS
                            font.family: "monospace"
                            color: Color.mOnSurface
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // Refresh Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: refreshMouseArea.containsMouse ? Color.mSecondaryContainer : Color.mSurfaceVariant
                    radius: Style.radiusM
                    border.color: Color.mOutline
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.checking ? (pluginApi?.tr("panel.checking") || "Checking...") : (pluginApi?.tr("panel.refresh") || "🔄 Refresh")
                        font.pointSize: Style.fontSizeM
                        font.weight: Font.Medium
                        color: Color.mOnSurface
                    }

                    MouseArea {
                        id: refreshMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            checkForUpdates();
                            checkLastUpdateTime();
                        }
                    }
                }

                // Action Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    // Refresh Database (Syy)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: syyMouseArea.containsMouse ? Color.mPrimaryContainer : Color.mSurfaceVariant
                        radius: Style.radiusM
                        border.color: Color.mPrimary
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: pluginApi?.tr("panel.refreshDb") || "Refresh DB"
                                font.pointSize: Style.fontSizeM
                                font.weight: Font.Bold
                                color: Color.mOnSurface
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "pacman -Syy"
                                font.pointSize: Style.fontSizeXS
                                font.family: "monospace"
                                color: Color.mOnSurfaceVariant
                            }
                        }

                        MouseArea {
                            id: syyMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: runUpdateCommand("sudo pacman -Syy")
                        }
                    }

                    // Full System Upgrade (Syu)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: syuMouseArea.containsMouse ? Color.mErrorContainer : Color.mSurfaceVariant
                        radius: Style.radiusM
                        border.color: root.updateCount > 0 ? Color.mError : Color.mPrimary
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: pluginApi?.tr("panel.upgrade") || "Upgrade"
                                font.pointSize: Style.fontSizeM
                                font.weight: Font.Bold
                                color: Color.mOnSurface
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "pacman -Syu"
                                font.pointSize: Style.fontSizeXS
                                font.family: "monospace"
                                color: Color.mOnSurfaceVariant
                            }
                        }

                        MouseArea {
                            id: syuMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: runUpdateCommand("sudo pacman -Syu")
                        }
                    }
                }
            }
        }
    }
}
