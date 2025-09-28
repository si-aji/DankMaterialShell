import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Services

Item {
    id: root

    // Bind all properties to the service
    property bool isRunning: PomodoroService.isRunning
    property bool isPaused: PomodoroService.isPaused
    property bool isBreak: PomodoroService.isBreak
    property int workMinutes: PomodoroService.workMinutes
    property int breakMinutes: PomodoroService.breakMinutes
    property int totalSeconds: PomodoroService.totalSeconds
    property int displayHours: PomodoroService.displayHours
    property int displayMinutes: PomodoroService.displayMinutes
    property int displaySeconds: PomodoroService.displaySeconds
    property int completedPomodoros: PomodoroService.completedPomodoros
    property int targetPomodoros: PomodoroService.targetPomodoros
    property bool showCongratulations: PomodoroService.showCongratulations
    property bool showConfirmation: PomodoroService.showConfirmation
    property string confirmationMessage: PomodoroService.confirmationMessage
    readonly property bool isLastWorkSession: PomodoroService.isLastWorkSession


    function formatTime() {
        return PomodoroService.formatTime()
    }

    function startPomodoro() {
        PomodoroService.startPomodoro()
    }

    function pausePomodoro() {
        PomodoroService.pausePomodoro()
    }

    function resumePomodoro() {
        PomodoroService.resumePomodoro()
    }

    function stopPomodoro() {
        PomodoroService.stopPomodoro()
    }

    function resetPomodoro() {
        PomodoroService.resetPomodoro()
    }

    function skipSession() {
        PomodoroService.skipSession()
    }

    function incrementTime(unit) {
        PomodoroService.incrementTime(unit)
    }

    function decrementTime(unit) {
        PomodoroService.decrementTime(unit)
    }

    function getSessionColor(index) {
        return PomodoroService.getSessionColor(index)
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
                            PomodoroService.skipSession()
                        } else {
                            skipSession()
                        }
                    }
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }

            // Quit button
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
                    text: "Quit"
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
                    PomodoroService.updateDisplayTime()
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
                            PomodoroService.confirmSessionSwitch()
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
                            PomodoroService.cancelSessionSwitch()
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
