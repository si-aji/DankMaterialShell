import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property bool showConflictDialog: false
    property string conflictMessage: ""
    property string pendingAction: ""

    function activeProcesses() {
        const processes = []
        if (PomodoroService.isRunning || PomodoroService.isPaused)
            processes.push("Pomodoro")
        if (StopwatchService.isRunning || StopwatchService.isPaused)
            processes.push("Stopwatch")
        return processes
    }

    function stopOtherProcesses() {
        if (PomodoroService.isRunning || PomodoroService.isPaused)
            PomodoroService.stopPomodoro()
        if (StopwatchService.isRunning || StopwatchService.isPaused)
            StopwatchService.resetStopwatch()
    }

    function executeAction(action) {
        if (action === "start")
            TimerService.startTimer()
        else if (action === "resume")
            TimerService.resumeTimer()
        pendingAction = ""
    }

    function requestStartOrResume(action) {
        const conflicts = activeProcesses()
        if (conflicts.length === 0) {
            executeAction(action)
            return
        }
        pendingAction = action
        conflictMessage = `Starting the timer will stop ${conflicts.join(" and ")}.
Continue?`
        showConflictDialog = true
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingL

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Timer"
            font.pixelSize: 36
            font.weight: Font.Bold
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
        }

        Text {
            id: timerDisplay
            anchors.horizontalCenter: parent.horizontalCenter
            text: TimerService.displayTime
            font.pixelSize: 48
            font.family: Theme.monoFont
            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM
            visible: !TimerService.isRunning && !TimerService.isPaused

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
                            onClicked: TimerService.decrementTime(modelData.unit)
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
                            text: {
                                switch (modelData.unit) {
                                case "hour":
                                    return String(TimerService.configHours).padStart(2, "0")
                                case "minute":
                                    return String(TimerService.configMinutes).padStart(2, "0")
                                default:
                                    return String(TimerService.configSeconds).padStart(2, "0")
                                }
                            }
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
                            onClicked: TimerService.incrementTime(modelData.unit)
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM

            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: {
                    if (TimerService.isRunning && !TimerService.isPaused) {
                        return Theme.secondary
                    } else if (TimerService.isRunning && TimerService.isPaused) {
                        return Theme.primary
                    } else if (TimerService.configuredSeconds > 0) {
                        return Theme.primary
                    } else {
                        return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5)
                    }
                }
                border.color: TimerService.isRunning || TimerService.configuredSeconds > 0
                              ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                              : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: TimerService.isRunning
                          ? (TimerService.isPaused ? "Resume" : "Pause")
                          : "Start"
                    color: {
                        if (TimerService.isRunning) {
                            return TimerService.isPaused ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                                                         : Theme.onSecondary
                        } else if (TimerService.configuredSeconds > 0) {
                            return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                        }
                        return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.6)
                    }
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: TimerService.isRunning || TimerService.configuredSeconds > 0
                    onClicked: {
                        if (TimerService.isRunning) {
                            if (TimerService.isPaused) {
                                requestStartOrResume("resume")
                            } else {
                                TimerService.pauseTimer()
                            }
                        } else {
                            requestStartOrResume("start")
                        }
                    }
                    hoverEnabled: enabled
                    onEntered: if (enabled) cursorShape = Qt.PointingHandCursor
                    onExited: if (enabled) cursorShape = Qt.ArrowCursor
                }
            }

            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: Theme.error
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1
                visible: TimerService.isRunning

                Text {
                    anchors.centerIn: parent
                    text: "Stop"
                    color: Theme.onError
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: TimerService.stopTimer()
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }

            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: TimerService.totalSeconds > 0 ? Theme.surface : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
                border.color: TimerService.totalSeconds > 0 ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                                                           : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                border.width: 1
                visible: !TimerService.isRunning && !TimerService.isPaused && TimerService.totalSeconds > 0

                Text {
                    anchors.centerIn: parent
                    text: "Reset"
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: TimerService.resetTimer()
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }
        }
    }

    Rectangle {
        id: conflictDialog
        visible: showConflictDialog
        anchors.centerIn: parent
        width: Math.min(Math.max(240, parent.width - Theme.spacingL * 2), 340)
        height: dialogColumn.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.color: Theme.outline
        border.width: 1
        z: 200

        Column {
            id: dialogColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.spacingM
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacingM
            spacing: Theme.spacingM
            width: parent.width - Theme.spacingL * 2

            Text {
                text: conflictMessage
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingM

                Rectangle {
                    width: 100
                    height: 36
                    radius: Theme.cornerRadius
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Yes"
                        color: Theme.onPrimary
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stopOtherProcesses()
                            executeAction(pendingAction)
                            pendingAction = ""
                            showConflictDialog = false
                        }
                        hoverEnabled: true
                        onEntered: cursorShape = Qt.PointingHandCursor
                        onExited: cursorShape = Qt.ArrowCursor
                    }
                }

                Rectangle {
                    width: 100
                    height: 36
                    radius: Theme.cornerRadius
                    color: Theme.surface
                    border.color: Theme.outline
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pendingAction = ""
                            showConflictDialog = false
                        }
                        hoverEnabled: true
                        onEntered: cursorShape = Qt.PointingHandCursor
                        onExited: cursorShape = Qt.ArrowCursor
                    }
                }
            }
        }
    }
}
