pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell

Singleton {
    id: root

    property bool isRunning: false
    property bool isPaused: false
    property real elapsedMilliseconds: 0
    property real pausedElapsed: 0
    property real startTimestamp: 0
    property var lapTimes: []
    property var displayLapTimes: []

    Timer {
        id: stopwatchTimer
        interval: 10
        running: root.isRunning
        repeat: true
        onTriggered: root.updateElapsed()
    }

    function updateElapsed() {
        const now = Date.now()
        root.elapsedMilliseconds = root.pausedElapsed + (now - root.startTimestamp)
    }

    function formatTime(milliseconds) {
        const totalSeconds = Math.floor(milliseconds / 1000)
        const minutes = Math.floor(totalSeconds / 60)
        const hours = Math.floor(minutes / 60)
        const seconds = totalSeconds % 60
        const ms = Math.floor((milliseconds % 1000) / 10)

        return String(hours).padStart(2, "0") + ":" +
               String(minutes % 60).padStart(2, "0") + ":" +
               String(seconds).padStart(2, "0") + "." +
               String(ms).padStart(2, "0")
    }

    function startStopwatch() {
        root.startTimestamp = Date.now()
        root.pausedElapsed = 0
        root.elapsedMilliseconds = 0
        root.isRunning = true
        root.isPaused = false
    }

    function pauseStopwatch() {
        if (!root.isRunning)
            return
        root.isRunning = false
        root.isPaused = true
        root.pausedElapsed = root.elapsedMilliseconds
    }

    function resumeStopwatch() {
        if (!root.isPaused)
            return
        root.startTimestamp = Date.now()
        root.isRunning = true
        root.isPaused = false
    }

    function resetStopwatch() {
        root.isRunning = false
        root.isPaused = false
        root.elapsedMilliseconds = 0
        root.pausedElapsed = 0
        root.startTimestamp = 0
        root.lapTimes = []
        root.displayLapTimes = []
    }

    function addLap() {
        if (!root.isRunning)
            return
        const lap = {
            "time": root.elapsedMilliseconds,
            "formattedTime": formatTime(root.elapsedMilliseconds)
        }
        root.lapTimes = root.lapTimes.concat([lap])
        root.displayLapTimes = root.lapTimes.slice().reverse()
    }
}
