pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell

Singleton {
    id: root

    property bool isRunning: false
    property bool isPaused: false
    property int configHours: 0
    property int configMinutes: 0
    property int configSeconds: 0
    property int totalSeconds: 0

    readonly property int configuredSeconds: configHours * 3600 + configMinutes * 60 + configSeconds
    readonly property int displayHours: Math.floor(totalSeconds / 3600)
    readonly property int displayMinutes: Math.floor((totalSeconds % 3600) / 60)
    readonly property int displaySeconds: totalSeconds % 60
    readonly property string formattedRemaining: formatSeconds(totalSeconds)
    readonly property string formattedConfigured: formatSeconds(configuredSeconds)
    readonly property string displayTime: (isRunning || isPaused) ? formattedRemaining : formattedConfigured

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: root.isRunning && !root.isPaused
        onTriggered: {
            if (root.totalSeconds > 0) {
                root.totalSeconds = Math.max(0, root.totalSeconds - 1)
            }

            if (root.totalSeconds === 0) {
                root.isRunning = false
                root.isPaused = false
            }
        }
    }

    function formatSeconds(seconds) {
        const safeSeconds = Math.max(0, seconds || 0)
        const hours = Math.floor(safeSeconds / 3600)
        const minutes = Math.floor((safeSeconds % 3600) / 60)
        const secs = safeSeconds % 60
        return String(hours).padStart(2, "0") + ":" +
               String(minutes).padStart(2, "0") + ":" +
               String(secs).padStart(2, "0")
    }

    function startTimer() {
        if (root.isRunning)
            return

        if (root.totalSeconds <= 0) {
            root.applyConfiguration()
        }

        if (root.totalSeconds <= 0)
            return

        root.isRunning = true
        root.isPaused = false
    }

    function pauseTimer() {
        if (!root.isRunning)
            return
        root.isPaused = true
    }

    function resumeTimer() {
        if (!root.isRunning || !root.isPaused)
            return
        root.isPaused = false
    }

    function stopTimer() {
        root.isRunning = false
        root.isPaused = false
    }

    function resetTimer() {
        root.stopTimer()
        root.totalSeconds = 0
        root.configHours = 0
        root.configMinutes = 0
        root.configSeconds = 0
    }

    function applyConfiguration() {
        root.totalSeconds = root.configuredSeconds
    }

    function incrementTime(unit) {
        if (root.isRunning && !root.isPaused)
            return

        switch (unit) {
        case "hour":
            root.configHours = (root.configHours + 1) % 24
            break
        case "minute":
            root.configMinutes = (root.configMinutes + 1) % 60
            break
        case "second":
            root.configSeconds = (root.configSeconds + 1) % 60
            break
        }
    }

    function decrementTime(unit) {
        if (root.isRunning && !root.isPaused)
            return

        switch (unit) {
        case "hour":
            root.configHours = root.configHours > 0 ? root.configHours - 1 : 23
            break
        case "minute":
            root.configMinutes = root.configMinutes > 0 ? root.configMinutes - 1 : 59
            break
        case "second":
            root.configSeconds = root.configSeconds > 0 ? root.configSeconds - 1 : 59
            break
        }
    }
}

