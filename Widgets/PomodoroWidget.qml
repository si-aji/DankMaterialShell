import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property real widgetHeight: 30
    property bool isAtBottom: false

    width: 120
    height: widgetHeight

    // Bind to PomodoroService
    property bool isRunning: PomodoroService.isRunning
    property bool isBreak: PomodoroService.isBreak
    property string displayTime: PomodoroService.formatTime()
    property int completedPomodoros: PomodoroService.completedPomodoros

    // Background
    Rectangle {
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: {
            if (SettingsData.dankBarNoBackground) {
                return "transparent"
            }
            const baseColor = Theme.widgetBaseBackgroundColor
            return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
        }
        border.color: {
            if (!root.isRunning) return "transparent"
            return root.isBreak ? Theme.secondary : Theme.primary
        }
        border.width: root.isRunning ? 2 : 0

        // Subtle pulse animation when running
        SequentialAnimation on border.width {
            running: root.isRunning
            loops: Animation.Infinite
            alwaysRunToEnd: true

            NumberAnimation {
                from: 2
                to: 3
                duration: 1000
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                from: 3
                to: 2
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        // Pomodoro icon
        DankIcon {
            name: "local_cafe"
            size: 16
            color: {
                if (!root.isRunning) return Theme.surfaceText
                return root.isBreak ? Theme.secondary : Theme.primary
            }
        }

        // Timer display
        Text {
            text: root.displayTime
            font.pixelSize: 12
            font.family: Theme.monoFont
            font.weight: Font.Medium
            color: {
                if (!root.isRunning) return Theme.surfaceText
                return root.isBreak ? Theme.secondary : Theme.primary
            }
        }

        // Progress indicator
        Rectangle {
            width: 4
            height: 4
            radius: 2
            color: root.isBreak ? Theme.secondary : Theme.primary
            visible: root.isRunning

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Mouse interaction
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            // Open DankDash to Timer tab when clicked
            if (typeof dankDashPopout !== 'undefined') {
                dankDashPopout.dashVisible = true
                dankDashPopout.currentTabIndex = 2 // Timer tab
            }
        }

        onEntered: {
            // Show tooltip with status
            let status = root.isRunning ?
                        (root.isBreak ? "Break time" : "Focus time") :
                        "Pomodoro Timer"
            let completed = `${root.completedPomodoros}/4 completed`

            // You could show a tooltip here if you have a tooltip system
        }
    }

    // Connect to PomodoroService signals for updates
    Connections {
        target: PomodoroService
        function onTimerUpdated() {
            // Force update of display time
            root.displayTime = Qt.binding(function() { return PomodoroService.formatTime() })
        }
    }
}