import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
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
        if (TimerService.isRunning || TimerService.isPaused)
            processes.push("Timer")
        if (PomodoroService.isRunning || PomodoroService.isPaused)
            processes.push("Pomodoro")
        return processes
    }

    function stopOtherProcesses() {
        if (TimerService.isRunning || TimerService.isPaused)
            TimerService.stopTimer()
        if (PomodoroService.isRunning || PomodoroService.isPaused)
            PomodoroService.stopPomodoro()
    }

    function executeAction(action) {
        if (action === "start")
            StopwatchService.startStopwatch()
        else if (action === "resume")
            StopwatchService.resumeStopwatch()
        pendingAction = ""
    }

    function requestStartOrResume(action) {
        const conflicts = activeProcesses()
        if (conflicts.length === 0) {
            executeAction(action)
            return
        }
        pendingAction = action
        conflictMessage = `Starting the stopwatch will stop ${conflicts.join(" and ")}. Continue?`
        showConflictDialog = true
    }

    function formatTime(milliseconds) {
        return StopwatchService.formatTime(milliseconds)
    }

    Row {
        anchors.fill: parent
        spacing: Theme.spacingLarge

        Item {
            id: timerColumn
            width: parent.width * 0.6
            height: parent.height

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingL

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Stopwatch"
                    font.pixelSize: 36
                    font.weight: Font.Bold
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                }

                Text {
                    id: timerDisplay
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: formatTime(StopwatchService.elapsedMilliseconds)
                    font.pixelSize: 48
                    font.family: Theme.monoFont
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                }

                Row {
                    spacing: Theme.spacingM
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: startPauseButton
                        width: 100
                        height: 40
                        radius: Theme.cornerRadius
                        color: {
                            if (StopwatchService.isRunning && !StopwatchService.isPaused) {
                                return Theme.secondary
                            } else if (StopwatchService.isRunning && StopwatchService.isPaused) {
                                return Theme.primary
                            } else {
                                return Theme.primary
                            }
                        }
                        border.color: {
                            if (StopwatchService.isRunning) {
                                return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                            } else {
                                return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                            }
                        }
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: StopwatchService.isPaused ? "Resume" : (StopwatchService.isRunning ? "Pause" : "Start")
                            color: {
                                if (StopwatchService.isRunning) {
                                    if (StopwatchService.isPaused) {
                                        return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                                    } else {
                                        return Theme.onSecondary
                                    }
                                } else {
                                    return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                                }
                            }
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (!StopwatchService.isRunning && !StopwatchService.isPaused) {
                                    requestStartOrResume("start")
                                } else if (StopwatchService.isRunning) {
                                    StopwatchService.pauseStopwatch()
                                } else if (StopwatchService.isPaused) {
                                    requestStartOrResume("resume")
                                }
                            }
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }

                    Rectangle {
                        id: resetButton
                        width: 80
                        height: 40
                        radius: Theme.cornerRadius
                        color: Theme.error
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1
                        visible: StopwatchService.isRunning || StopwatchService.isPaused

                        Text {
                            anchors.centerIn: parent
                            text: "Reset"
                            color: Theme.onError
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: StopwatchService.resetStopwatch()
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }

                    Rectangle {
                        id: lapButton
                        width: 80
                        height: 40
                        radius: Theme.cornerRadius
                        color: StopwatchService.elapsedMilliseconds > 0 ? Theme.surface : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
                        border.color: StopwatchService.elapsedMilliseconds > 0 ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                        border.width: 1
                        visible: StopwatchService.isRunning

                        Text {
                            anchors.centerIn: parent
                            text: "Lap"
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: StopwatchService.addLap()
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }
                }
            }
        }

        Item {
            id: cardColumn
            width: parent.width * 0.4
            height: parent.height

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: parent.height * 0.9
                radius: Theme.cornerRadius
                color: Theme.surfaceContainer
                border.color: Theme.outline
                border.width: 1
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Lap Times"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                    }

                    DankFlickable {
                        id: lapFlickable
                        width: parent.width
                        height: parent.height - y - Theme.spacingM
                        contentHeight: contentHeightCalc
                        contentWidth: parent.width
                        clip: true

                        property int contentHeightCalc: {
                            var height = 0
                            if (instructionText.visible) height += 50 // estimated height for instruction text
                            height += StopwatchService.displayLapTimes.length * 55 // 55 for each lap
                            return Math.max(height, lapFlickable.height) // ensure minimum height
                        }

                        Column {
                            id: lapColumn
                            width: parent.width
                            spacing: Theme.spacingS

                            Text {
                                id: instructionText
                                width: parent.width
                                text: StopwatchService.lapTimes.length === 0 ?
                                      (StopwatchService.isRunning ? "Click on Lap button to start tracking lap times" :
                                       "Start stopwatch to enable tracking lap time") : ""
                                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                visible: StopwatchService.lapTimes.length === 0
                            }

                            Repeater {
                                id: lapRepeater
                                model: StopwatchService.displayLapTimes
                                delegate: Item {
                                    width: parent.width
                                    height: 55

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                                        anchors.bottom: parent.bottom
                                        visible: index < StopwatchService.displayLapTimes.length - 1
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.spacingM
                                        anchors.rightMargin: Theme.spacingM
                                        anchors.topMargin: 6
                                        spacing: Theme.spacingS

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2

                                            Text {
                                                text: "Lap " + (StopwatchService.lapTimes.length - index)
                                                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                text: modelData.formattedTime
                                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                                                font.pixelSize: 20
                                                font.family: Theme.monoFont
                                                font.weight: Font.Bold
                                            }
                                        }

                                        Column {
                                            anchors.top: parent.top
                                            anchors.topMargin: 2
                                            anchors.right: parent.right
                                            spacing: 2

                                            Text {
                                                text: index === 0 ? "Latest lap" :
                                                      index === StopwatchService.displayLapTimes.length - 1 ? "First lap" :
                                                      "+" + formatTime(modelData.time - StopwatchService.displayLapTimes[index + 1].time)
                                                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                                                font.pixelSize: 11
                                                horizontalAlignment: Text.AlignRight
                                                width: 80
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: conflictDialog
        visible: showConflictDialog
        anchors.centerIn: parent
        width: 280
        height: 160
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.color: Theme.outline
        border.width: 1
        z: 200

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingM
            width: parent.width - Theme.spacingL * 2

            Text {
                text: conflictMessage
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
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
