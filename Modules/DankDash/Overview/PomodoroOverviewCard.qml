import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Card {
    id: root

    signal clicked()

    // Only show when Pomodoro timer is running
    visible: PomodoroService.isRunning

    // Pulse animation to draw attention when timer is active
    SequentialAnimation on border.color {
        running: PomodoroService.isRunning && !root.containsMouse
        loops: Animation.Infinite
        alwaysRunToEnd: true

        ColorAnimation {
            from: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            to: PomodoroService.isBreak ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.3) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
            duration: 2000
            easing.type: Easing.InOutQuad
        }

        ColorAnimation {
            from: PomodoroService.isBreak ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.3) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
            to: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            duration: 2000
            easing.type: Easing.InOutQuad
        }
    }

    property bool containsMouse: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()

        onEntered: root.containsMouse = true
        onExited: root.containsMouse = false
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingS

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingS

            // Pomodoro icon
            DankIcon {
                name: "local_cafe"
                size: 24
                color: PomodoroService.isBreak ? Theme.secondary : Theme.primary
            }

            // Session type indicator
            Column {
                spacing: 2

                Text {
                    text: PomodoroService.isBreak ? "Break" : "Focus"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: PomodoroService.isBreak ? Theme.secondary : Theme.primary
                }

                Text {
                    text: PomodoroService.formatTime()
                    font.pixelSize: 20
                    font.family: Theme.monoFont
                    font.weight: Font.Bold
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
                }
            }
        }

        // Progress indicator
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Repeater {
                model: PomodoroService.targetPomodoros
                delegate: Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: {
                        if (index < PomodoroService.completedPomodoros) {
                            return Theme.primary  // Completed
                        } else if (index === PomodoroService.completedPomodoros && PomodoroService.isRunning && !PomodoroService.isBreak) {
                            return Theme.secondary  // Current work session
                        } else if (index === PomodoroService.completedPomodoros && PomodoroService.isRunning && PomodoroService.isBreak) {
                            return Theme.tertiary  // Current break session
                        } else {
                            return Theme.surfaceVariant  // Upcoming
                        }
                    }
                }
            }
        }

        // Session info and reset button
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM

            Text {
                text: `${PomodoroService.completedPomodoros}/${PomodoroService.targetPomodoros} completed`
                font.pixelSize: 12
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            }

            // Reset button
            Rectangle {
                width: 24
                height: 24
                radius: Theme.cornerRadiusSmall
                color: Theme.error
                visible: PomodoroService.isRunning
                opacity: root.containsMouse ? 1 : 0.7

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                DankIcon {
                    anchors.centerIn: parent
                    name: "refresh"
                    size: 16
                    color: Theme.onError
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        PomodoroService.resetPomodoro()
                    }
                }
            }
        }
    }

    // Click hint
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.spacingXS
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingXS
        text: "Click for details →"
        font.pixelSize: 10
        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
        visible: root.containsMouse
    }
}