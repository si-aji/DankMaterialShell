pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Common

Singleton {
    id: root

    // Pomodoro state
    property bool isRunning: false
    property bool isPaused: false
    property bool isBreak: false
    property int workMinutes: 25
    property int breakMinutes: 5
    property int totalSeconds: workMinutes * 60
    property int displayHours: Math.floor(totalSeconds / 3600)
    property int displayMinutes: Math.floor((totalSeconds % 3600) / 60)
    property int displaySeconds: totalSeconds % 60
    property int completedPomodoros: 0
    property int targetPomodoros: 4

    // Timer instance
    Timer {
        id: pomodoroTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.totalSeconds > 0 && !root.isPaused) {
                root.totalSeconds--
            } else if (root.totalSeconds === 0) {
                pomodoroTimer.stop()
                root.isRunning = false
                root.isPaused = false

                // Check if this is the last work session
                if (root.isLastWorkSession) {
                    // Go directly to congratulations
                    root.completedPomodoros++
                    root.showCongratulations = true
                    congratsTimer.start()
                } else {
                    // Show notification for session completion
                    root.showSessionCompleteNotification()
                }
            }
        }
    }

    // Congratulations timer
    Timer {
        id: congratsTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.showCongratulations = false
            root.resetPomodoro()
        }
    }

    // UI state properties (for UI components to bind to)
    property bool showCongratulations: false
    property bool showConfirmation: false
    property string confirmationMessage: ""
    property var confirmationCallback: null

    // Derived properties
    readonly property bool isLastWorkSession: !root.isBreak && root.completedPomodoros === root.targetPomodoros - 1

    // Signals for UI updates
    signal timerUpdated
    signal sessionCompleted(int completedCount, bool isBreak)
    signal allSessionsCompleted
    signal congratulationsRequested

    function updateDisplayTime() {
        // Force recalculation of display time properties
        Qt.callLater(function() {
            var temp = root.totalSeconds
            root.totalSeconds = temp
        })
    }

    function formatTime() {
        let h, m, s
        h = String(displayHours).padStart(2, '0')
        m = String(displayMinutes).padStart(2, '0')
        s = String(displaySeconds).padStart(2, '0')
        return `${h}:${m}:${s}`
    }

    function startPomodoro() {
        if (!root.isRunning) {
            root.isRunning = true
            root.isPaused = false
            pomodoroTimer.start()
            timerUpdated()
        }
    }

    function pausePomodoro() {
        root.isPaused = true
        timerUpdated()
    }

    function resumePomodoro() {
        root.isPaused = false
        timerUpdated()
    }

    function stopPomodoro() {
        pomodoroTimer.stop()
        root.isRunning = false
        root.isPaused = false
        timerUpdated()
    }

    function resetPomodoro() {
        pomodoroTimer.stop()
        root.isRunning = false
        root.isPaused = false
        root.isBreak = false
        root.completedPomodoros = 0
        root.totalSeconds = root.workMinutes * 60
        root.showConfirmation = false
        root.confirmationMessage = ""
        root.confirmationCallback = null
        root.showCongratulations = false
        timerUpdated()
    }

    function showSessionSwitchConfirmation(isFromSkip) {
        root.showConfirmation = true
        if (!root.isBreak) {
            // Show confirmation for switching to break
            root.confirmationMessage = "Start break time?"
            root.confirmationCallback = function() {
                root.completedPomodoros++

                // Check if all pomodoros are completed
                if (root.completedPomodoros >= root.targetPomodoros) {
                    root.showCongratulations = true
                    congratulationsRequested()
                    congratsTimer.start()
                } else {
                    root.isBreak = true
                    root.totalSeconds = root.breakMinutes * 60
                    root.isRunning = true
                    pomodoroTimer.start()
                }
                root.showConfirmation = false
                sessionCompleted(root.completedPomodoros, true)
            }
        } else {
            // Show confirmation for switching to work
            root.confirmationMessage = "Start work time?"
            root.confirmationCallback = function() {
                root.isBreak = false
                root.totalSeconds = root.workMinutes * 60
                root.isRunning = true
                pomodoroTimer.start()
                root.showConfirmation = false
                sessionCompleted(root.completedPomodoros, false)
            }
        }
    }

    function skipSession() {
        if (root.isLastWorkSession) {
            // On last work session, go directly to congratulations
            root.completedPomodoros++
            root.showCongratulations = true
            congratulationsRequested()
            congratsTimer.start()
            pomodoroTimer.stop()
            root.isRunning = false
            root.isPaused = false
        } else {
            root.showSessionSwitchConfirmation(true)
        }
    }

    function incrementTime(unit) {
        if (isRunning) return

        switch (unit) {
            case "work":
                root.workMinutes = Math.min(root.workMinutes + 1, 60)
                if (!root.isBreak) {
                    root.totalSeconds = root.workMinutes * 60
                }
                break
            case "break":
                root.breakMinutes = Math.min(root.breakMinutes + 1, 30)
                if (root.isBreak) {
                    root.totalSeconds = root.breakMinutes * 60
                }
                break
        }
        timerUpdated()
    }

    function decrementTime(unit) {
        if (isRunning) return

        switch (unit) {
            case "work":
                root.workMinutes = Math.max(root.workMinutes - 1, 1)
                if (!root.isBreak) {
                    root.totalSeconds = root.workMinutes * 60
                }
                break
            case "break":
                root.breakMinutes = Math.max(root.breakMinutes - 1, 1)
                if (root.isBreak) {
                    root.totalSeconds = root.breakMinutes * 60
                }
                break
        }
        timerUpdated()
    }

    function getSessionColor(index) {
        if (index < root.completedPomodoros) {
            return Theme.primary  // Completed sessions
        } else if (index === root.completedPomodoros && root.isRunning && !root.isBreak) {
            return Theme.secondary  // Currently active work session
        } else if (index === root.completedPomodoros && root.isRunning && root.isBreak) {
            return Theme.tertiary  // Currently active break session
        } else {
            return Theme.surfaceVariant  // Future sessions
        }
    }

    function showSessionCompleteNotification() {
        // Show notification when session completes
        if (typeof ToastService !== 'undefined') {
            ToastService.show(root.isBreak ? "Work session completed!" : "Break session completed!")
        }
    }

    // Public function for UI to confirm session switch
    function confirmSessionSwitch() {
        if (root.confirmationCallback) {
            root.confirmationCallback()
        }
    }

    // Public function for UI to cancel session switch
    function cancelSessionSwitch() {
        root.showConfirmation = false
        // Resume the timer if user cancels
        root.isRunning = true
        pomodoroTimer.start()
    }
}
