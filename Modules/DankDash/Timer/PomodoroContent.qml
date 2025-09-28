import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: root

    property bool isRunning: false
    property bool isPaused: false
    property bool isBreak: false
    property int workMinutes: 25
    property int breakMinutes: 5
    property int totalSeconds: workMinutes * 60
    property int displayHours: Math.floor(totalSeconds / 3600)
    property int displayMinutes: Math.floor((totalSeconds % 3600) / 60)
    property int displaySeconds: totalSeconds % 60

    function updateDisplayTime() {
        // Force recalculation of display time properties using Qt.callLater for stability
        Qt.callLater(function() {
            var temp = root.totalSeconds
            root.totalSeconds = temp
        })
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
    property int completedPomodoros: 0
    property int targetPomodoros: 4
    property bool showCongratulations: false
    property bool showConfirmation: false
    property string confirmationMessage: ""
    property var confirmationCallback: null
    readonly property bool isLastWorkSession: !root.isBreak && root.completedPomodoros === root.targetPomodoros - 1

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
                    // Show confirmation for switching sessions
                    root.showSessionSwitchConfirmation(false)
                }
            }
        }
    }

    Timer {
        id: congratsTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.showCongratulations = false
            root.resetPomodoro()
        }
    }

    Timer {
        id: layoutStabilizerTimer
        interval: 50
        repeat: false
        onTriggered: {
            root.updateDisplayTime()
        }
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
        }
    }

    function pausePomodoro() {
        root.isPaused = true
    }

    function resumePomodoro() {
        root.isPaused = false
    }

    function stopPomodoro() {
        pomodoroTimer.stop()
        root.isRunning = false
        root.isPaused = false
    }

    function resetPomodoro() {
        pomodoroTimer.stop()
        root.isRunning = false
        root.isPaused = false
        root.isBreak = false
        root.completedPomodoros = 0
        root.totalSeconds = root.workMinutes * 60
    }

    function showSessionSwitchConfirmation(isFromSkip) {
        if (!root.isBreak) {
            // Show confirmation for switching to break
            root.confirmationMessage = "Start break time?"
            root.confirmationCallback = function() {
                root.completedPomodoros++

                // Check if all pomodoros are completed
                if (root.completedPomodoros >= root.targetPomodoros) {
                    root.showCongratulations = true
                    // Show congratulations for 3 seconds then reset
                    congratsTimer.start()
                } else {
                    root.isBreak = true
                    root.totalSeconds = root.breakMinutes * 60
                    root.isRunning = true  // Start the timer automatically
                    pomodoroTimer.start()  // Start the countdown
                    // Use stabilizer timer to ensure layout stability
                layoutStabilizerTimer.start()
                }
                root.showConfirmation = false
            }
        } else {
            // Show confirmation for switching to work
            root.confirmationMessage = "Start work time?"
            root.confirmationCallback = function() {
                root.isBreak = false
                root.totalSeconds = root.workMinutes * 60
                root.isRunning = true  // Start the timer automatically
                    pomodoroTimer.start()  // Start the countdown
                // Use stabilizer timer to ensure layout stability
                layoutStabilizerTimer.start()
                root.showConfirmation = false
            }
        }
        root.showConfirmation = true
    }

    function skipSession() {
        root.showSessionSwitchConfirmation(true)
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
    }

    Column {
        id: mainColumn
        anchors.centerIn: parent
        spacing: Theme.spacingL
        width: Math.min(parent.width * 0.8, 400)  // Fixed width for stability
        height: implicitHeight  // Let height be content-driven

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Pomodoro"
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
            visible: !root.showCongratulations && !root.showConfirmation
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.isBreak ? "Break Time" : "Focus Time"
            font.pixelSize: 18
            font.weight: Font.Medium
            color: root.isBreak ? Theme.secondary : Theme.primary
            visible: !root.showCongratulations && !root.showConfirmation
        }

        // Progress Indicator
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingXS
            visible: !root.showCongratulations && !root.showConfirmation

            Repeater {
                model: root.targetPomodoros
                delegate: Rectangle {
                    id: sessionIndicator
                    width: 20
                    height: 20
                    radius: Theme.cornerRadiusSmall
                    color: root.getSessionColor(index)
                    border.color: Theme.outline
                    border.width: 1

                    // Add a subtle animation for color changes
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    // Check if this session is currently active
                    readonly property bool isActive: index === root.completedPomodoros && root.isRunning

                    // Pulsing animation for active session
                    SequentialAnimation on scale {
                        running: sessionIndicator.isActive && !root.showConfirmation && !root.showCongratulations
                        loops: Animation.Infinite
                        alwaysRunToEnd: true

                        ScaleAnimator {
                            from: 1.0
                            to: 1.2
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }

                        ScaleAnimator {
                            from: 1.2
                            to: 1.0
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                    }

                    // Breathing opacity animation for active session
                    SequentialAnimation on opacity {
                        running: sessionIndicator.isActive && !root.showConfirmation && !root.showCongratulations
                        loops: Animation.Infinite
                        alwaysRunToEnd: true

                        OpacityAnimator {
                            from: 1.0
                            to: 0.6
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }

                        OpacityAnimator {
                            from: 0.6
                            to: 1.0
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                    }

                    // Subtle glow effect for active session
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: parent.radius + 4
                        color: "transparent"
                        border.color: parent.color
                        border.width: sessionIndicator.isActive ? 2 : 0
                        opacity: sessionIndicator.isActive ? 0.5 : 0

                        Behavior on border.width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }
        }

        // Color Legend
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingS
            visible: !root.showCongratulations && !root.showConfirmation && !root.isRunning

            Rectangle {
                width: 12
                height: 12
                radius: 2
                color: Theme.primary
            }

            Text {
                text: "Done"
                font.pixelSize: 10
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            }

            Rectangle {
                width: 12
                height: 12
                radius: 2
                color: Theme.secondary
            }

            Text {
                text: "Current"
                font.pixelSize: 10
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            }

            Rectangle {
                width: 12
                height: 12
                radius: 2
                color: Theme.surfaceVariant
            }

            Text {
                text: "Upcoming"
                font.pixelSize: 10
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            }
        }

        // Congratulations Message
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "🎉 Congrats, session finished! 🎉"
            font.pixelSize: 24
            font.weight: Font.Bold
            color: Theme.primary
            visible: root.showCongratulations
            opacity: root.showCongratulations ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        
        // Time Configuration
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingL
            visible: !root.isRunning && !root.showCongratulations && !root.showConfirmation

            // Work Time Configuration
            Column {
                spacing: Theme.spacingXS

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Work"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                }

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
                            onClicked: decrementTime("work")
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }

                    Rectangle {
                        width: 50
                        height: 30
                        radius: Theme.cornerRadiusSmall
                        color: Theme.surfaceContainerHigh
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.workMinutes + "m"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Theme.primary
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
                            onClicked: incrementTime("work")
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }
                }
            }

            // Break Time Configuration
            Column {
                spacing: Theme.spacingXS

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Break"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                }

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
                            onClicked: decrementTime("break")
                            hoverEnabled: true
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onExited: cursorShape = Qt.ArrowCursor
                        }
                    }

                    Rectangle {
                        width: 50
                        height: 30
                        radius: Theme.cornerRadiusSmall
                        color: Theme.surfaceContainerHigh
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.breakMinutes + "m"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Theme.secondary
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
                            onClicked: incrementTime("break")
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
            visible: !root.showCongratulations && !root.showConfirmation

            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: {
                    if (root.isRunning && !root.isPaused) {
                        return Theme.secondary
                    } else if (root.isRunning && root.isPaused) {
                        return Theme.primary
                    } else {
                        return Theme.primary
                    }
                }
                border.color: {
                    if (root.isRunning) {
                        return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    } else {
                        return Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
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
                        } else {
                            return Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                        }
                    }
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.isRunning) {
                            if (root.isPaused) {
                                resumePomodoro()
                            } else {
                                pausePomodoro()
                            }
                        } else {
                            startPomodoro()
                        }
                    }
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }

            // Skip/Finish button
            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: root.isLastWorkSession ? Theme.primary : Theme.surface
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1
                visible: root.isRunning

                Text {
                    anchors.centerIn: parent
                    text: root.isLastWorkSession ? "Finish" : "Skip"
                    color: root.isLastWorkSession ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.isLastWorkSession) {
                            // On last work session, go directly to congratulations
                            root.completedPomodoros++
                            root.showCongratulations = true
                            congratsTimer.start()
                            pomodoroTimer.stop()
                            root.isRunning = false
                            root.isPaused = false
                        } else {
                            skipSession()
                        }
                    }
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }

            // Reset button
            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: Theme.error
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1
                visible: !root.isRunning && (root.completedPomodoros > 0 || root.isBreak)

                Text {
                    anchors.centerIn: parent
                    text: "Reset"
                    color: Theme.onError
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: resetPomodoro()
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }
        }
    }

    // Confirmation Dialog (positioned outside main Column for stability)
    Rectangle {
        id: confirmationDialog
        anchors.centerIn: parent
        width: 300
        height: 180
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.color: Theme.outline
        border.width: 1
        visible: root.showConfirmation
        opacity: root.showConfirmation ? 1 : 0
        z: 100  // Ensure it's above other content

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        // Ensure layout stability when dialog closes
        onVisibleChanged: {
            if (!visible) {
                // Force a layout update when dialog is hidden
                Qt.callLater(function() {
                    root.updateDisplayTime()
                })
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingL

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.confirmationMessage
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                horizontalAlignment: Text.AlignHCenter
                width: parent.width - Theme.spacingL * 2
                wrapMode: Text.WordWrap
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingM

                Rectangle {
                    width: 80
                    height: 40
                    radius: Theme.cornerRadius
                    color: Theme.primary
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Yes"
                        color: Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 1)
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.confirmationCallback) {
                                root.confirmationCallback()
                            }
                        }
                        hoverEnabled: true
                        onEntered: cursorShape = Qt.PointingHandCursor
                        onExited: cursorShape = Qt.ArrowCursor
                    }
                }

                Rectangle {
                    width: 80
                    height: 40
                    radius: Theme.cornerRadius
                    color: Theme.surface
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "No"
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.showConfirmation = false
                            // Resume the timer if user cancels
                            root.isRunning = true
                            pomodoroTimer.start()
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