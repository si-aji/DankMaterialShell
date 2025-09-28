import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import qs.Common
import qs.Widgets

Item {
    id: root

    property int elapsedMilliseconds: 0
    property bool isRunning: false
    property bool isPaused: false
    property var startTime
    property var pauseTime
    property var pausedElapsed: 0
    property var lapTimes: []
    property string lapButtonText: "Add Lap"
    property string lapDebugInfo: "lapTimes: []"

    Timer {
        id: stopwatchTimer
        interval: 10
        running: root.isRunning
        repeat: true
        onTriggered: {
            root.elapsedMilliseconds = root.pausedElapsed + (Date.now() - root.startTime)
        }
    }

    Timer {
        id: resetButtonTextTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root.lapButtonText = "Add Lap"
        }
    }

    function formatTime(milliseconds) {
        var totalSeconds = Math.floor(milliseconds / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var hours = Math.floor(minutes / 60)
        var seconds = totalSeconds % 60
        var ms = Math.floor((milliseconds % 1000) / 10)

        return hours.toString().padStart(2, '0') + ":" +
               (minutes % 60).toString().padStart(2, '0') + ":" +
               seconds.toString().padStart(2, '0') + "." +
               ms.toString().padStart(2, '0')
    }

    function startStopwatch() {
        root.startTime = Date.now()
        root.isRunning = true
        root.isPaused = false
        root.pausedElapsed = 0
    }

    function pauseStopwatch() {
        root.isRunning = false
        root.isPaused = true
        root.pausedElapsed = root.elapsedMilliseconds
    }

    function resumeStopwatch() {
        root.startTime = Date.now()
        root.isRunning = true
        root.isPaused = false
    }

    function resetStopwatch() {
        root.isRunning = false
        root.isPaused = false
        root.elapsedMilliseconds = 0
        root.pausedElapsed = 0
        root.lapTimes = []
    }

    function addLap() {
        root.lapButtonText = "Clicked!"
        var newLap = {
            time: root.elapsedMilliseconds,
            formattedTime: formatTime(root.elapsedMilliseconds)
        }
        root.lapTimes = root.lapTimes.concat([newLap])
        root.lapDebugInfo = "Added lap #" + (root.lapTimes.length) + ": " + newLap.formattedTime
        // Reset text after 1 second
        resetButtonTextTimer.start()
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
                    text: formatTime(root.elapsedMilliseconds)
                    font.pixelSize: 48
                    font.family: Theme.monoFont
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    spacing: Theme.spacingM
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: startPauseButton
                        width: 100
                        height: 40
                        radius: Theme.cornerRadius
                        color: Theme.primary
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.isPaused ? "Resume" : (root.isRunning ? "Pause" : "Start")
                            color: Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (!root.isRunning && !root.isPaused) {
                                    startStopwatch()
                                } else if (root.isRunning) {
                                    pauseStopwatch()
                                } else if (root.isPaused) {
                                    resumeStopwatch()
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
                        color: enabled ? Theme.surface : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
                        border.color: enabled ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                        border.width: 1
                        enabled: root.isRunning || root.isPaused

                        Text {
                            anchors.centerIn: parent
                            text: "Reset"
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: resetStopwatch()
                            hoverEnabled: enabled
                            onEntered: if (enabled) cursorShape = Qt.PointingHandCursor
                            onExited: if (enabled) cursorShape = Qt.ArrowCursor
                        }
                    }

                    Rectangle {
                        id: lapButton
                        width: 80
                        height: 40
                        radius: Theme.cornerRadius
                        color: enabled ? Theme.surface : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
                        border.color: enabled ? Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08) : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.05)
                        border.width: 1
                        enabled: root.isRunning

                        Text {
                            anchors.centerIn: parent
                            text: root.lapButtonText
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: addLap()
                            hoverEnabled: enabled
                            onEntered: if (enabled) cursorShape = Qt.PointingHandCursor
                            onExited: if (enabled) cursorShape = Qt.ArrowCursor
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Debug: Lap Count = " + root.lapTimes.length
                    font.pixelSize: 16
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.8)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Debug: Timer Running = " + root.isRunning + ", Elapsed = " + formatTime(root.elapsedMilliseconds)
                    font.pixelSize: 12
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.lapDebugInfo
                    font.pixelSize: 12
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8)
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
                radius: Theme.radiusMedium
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
                            height += lapRepeater.count * 45 // 45 for each lap
                            return Math.max(height, lapFlickable.height) // ensure minimum height
                        }

                        Column {
                            id: lapColumn
                            width: parent.width
                            spacing: Theme.spacingS

                            Text {
                                id: instructionText
                                width: parent.width
                                text: root.lapTimes.length === 0 ?
                                      (root.isRunning ? "click on lap button to start tracking lap times" :
                                       "start stopwatch to start tracking lap time") : ""
                                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                visible: root.lapTimes.length === 0
                            }

                            Repeater {
                                id: lapRepeater
                                model: root.lapTimes
                                delegate: Item {
                                    width: parent.width
                                    height: 45

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                                        anchors.bottom: parent.bottom
                                        visible: index < root.lapTimes.length - 1
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.spacingM
                                        anchors.rightMargin: Theme.spacingM
                                        spacing: Theme.spacingS

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2

                                            Text {
                                                text: "Lap " + (index + 1)
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
                                                text: index === 0 ? "First lap" :
                                                      index === root.lapTimes.length - 1 ? "Latest lap" :
                                                      "+" + formatTime(modelData.time - root.lapTimes[index - 1].time)
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
}