import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: root

    property bool isRunning: false
    property bool isPaused: false
    property bool isConfiguring: false
    property int configHours: 0
    property int configMinutes: 0
    property int configSeconds: 0
    property int totalSeconds: 0
    property int displayHours: Math.floor(totalSeconds / 3600)
    property int displayMinutes: Math.floor((totalSeconds % 3600) / 60)
    property int displaySeconds: totalSeconds % 60

    Timer {
        id: timer
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.totalSeconds > 0 && !root.isPaused) {
                root.totalSeconds--
            } else if (root.totalSeconds === 0) {
                timer.stop()
                root.isRunning = false
                root.isPaused = false
            }
        }
    }

    function formatTime() {
        let h, m, s

        if (root.isRunning) {
            // Show countdown time when running
            h = String(displayHours).padStart(2, '0')
            m = String(displayMinutes).padStart(2, '0')
            s = String(displaySeconds).padStart(2, '0')
        } else {
            // Show configuration time when not running
            h = String(configHours).padStart(2, '0')
            m = String(configMinutes).padStart(2, '0')
            s = String(configSeconds).padStart(2, '0')
        }

        return `${h}:${m}:${s}`
    }

    function startTimer() {
        if (!root.isRunning) {
            if (root.totalSeconds === 0) {
                applyConfiguration()
            }
            root.isRunning = true
            root.isPaused = false
            timer.start()
        }
    }

    function pauseTimer() {
        root.isPaused = true
    }

    function resumeTimer() {
        root.isPaused = false
    }

    function stopTimer() {
        timer.stop()
        root.isRunning = false
        root.isPaused = false
    }

    function resetTimer() {
        timer.stop()
        root.isRunning = false
        root.isPaused = false
        root.totalSeconds = 0

        // Also reset configuration to 0
        configHours = 0
        configMinutes = 0
        configSeconds = 0
    }

    function applyConfiguration() {
        root.totalSeconds = (configHours * 3600) + (configMinutes * 60) + configSeconds
    }

    function getConfiguredSeconds() {
        return (configHours * 3600) + (configMinutes * 60) + configSeconds
    }

    function incrementTime(unit) {
        if (isRunning) return

        switch (unit) {
            case "hour":
                configHours = (configHours + 1) % 24
                break
            case "minute":
                configMinutes = (configMinutes + 1) % 60
                break
            case "second":
                configSeconds = (configSeconds + 1) % 60
                break
        }
    }

    function decrementTime(unit) {
        if (isRunning) return

        switch (unit) {
            case "hour":
                configHours = configHours > 0 ? configHours - 1 : 23
                break
            case "minute":
                configMinutes = configMinutes > 0 ? configMinutes - 1 : 59
                break
            case "second":
                configSeconds = configSeconds > 0 ? configSeconds - 1 : 59
                break
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingL

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Timers"
            font.pixelSize: 36
            font.weight: Font.Bold
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
        }

        Text {
            id: timerDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: formatTime()
            font.pixelSize: 48
            font.family: Theme.monoFont
            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
        }

        // Time Configuration
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM
            visible: !root.isRunning

            Repeater {
                model: [
                    { unit: "hour", label: "H" },
                    { unit: "minute", label: "M" },
                    { unit: "second", label: "S" }
                ]

                Row {
                    spacing: Theme.spacingXS

                    Rectangle {
                        width: 30
                        height: 30
                        radius: Theme.cornerRadiusSmall
                        color: Theme.surface
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            font.pixelSize: 18
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: decrementTime(modelData.unit)
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 30
                        radius: Theme.cornerRadiusSmall
                        color: Theme.surfaceContainerHigh
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                        }
                    }

                    Rectangle {
                        width: 30
                        height: 30
                        radius: Theme.cornerRadiusSmall
                        color: Theme.surface
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 18
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.8)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: incrementTime(modelData.unit)
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }
                }
            }
        }

        // Control Buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM

            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: {
                    if (root.isRunning && !root.isPaused) {
                        return Theme.secondary
                    } else if (root.isRunning && root.isPaused) {
                        return Theme.primary
                    } else if (getConfiguredSeconds() > 0) {
                        return Theme.primary
                    } else {
                        return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5)
                    }
                }
                border.color: {
                    if (root.isRunning) {
                        return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    } else if (getConfiguredSeconds() > 0) {
                        return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    } else {
                        return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                    }
                }
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (root.isRunning && !root.isPaused) {
                            return "Pause"
                        } else if (root.isRunning && root.isPaused) {
                            return "Resume"
                        } else {
                            return "Start"
                        }
                    }
                    color: {
                        if (root.isRunning) {
                            if (root.isPaused) {
                                return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                            } else {
                                return Theme.onSecondary
                            }
                        } else if (getConfiguredSeconds() > 0) {
                            return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                        } else {
                            return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.6)
                        }
                    }
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.isRunning || getConfiguredSeconds() > 0
                    onClicked: {
                        if (root.isRunning) {
                            if (root.isPaused) {
                                resumeTimer()
                            } else {
                                pauseTimer()
                            }
                        } else {
                            startTimer()
                        }
                    }
                    hoverEnabled: root.isRunning || getConfiguredSeconds() > 0
                    onEntered: if (root.isRunning || getConfiguredSeconds() > 0) cursorShape = Qt.PointingHandCursor
                    onExited: if (root.isRunning || getConfiguredSeconds() > 0) cursorShape = Qt.ArrowCursor
                }
            }

            // Stop button (only visible when timer is running)
            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: Theme.error
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1
                visible: root.isRunning

                Text {
                    anchors.centerIn: parent
                    text: "Stop"
                    color: Theme.onError
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stopTimer()
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }

            // Reset button (only visible when timer is not running)
            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: root.totalSeconds > 0 ? Theme.surface : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
                border.color: root.totalSeconds > 0 ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                border.width: 1
                visible: !root.isRunning

                Text {
                    anchors.centerIn: parent
                    text: "Reset"
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: resetTimer()
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }
        }
    }
}