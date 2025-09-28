import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.DankDash.Timer

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410

    property int currentMode: 0 // 0: Timer, 1: Stopwatch, 2: Pomodoro

    Row {
        anchors.fill: parent
        spacing: Theme.spacingM

        // Left column - Tab buttons
        Column {
            width: parent.width * 0.2
            height: parent.height
            spacing: Theme.spacingS

            TimerTabButton {
                width: parent.width
                height: (parent.height - Theme.spacingS * 2) / 3
                title: "Timers"
                icon: "hourglass_top"
                active: root.currentMode === 0
                onClicked: root.currentMode = 0
            }

            TimerTabButton {
                width: parent.width
                height: (parent.height - Theme.spacingS * 2) / 3
                title: "Stopwatch"
                icon: "timer"
                active: root.currentMode === 1
                onClicked: root.currentMode = 1
            }

            TimerTabButton {
                width: parent.width
                height: (parent.height - Theme.spacingS * 2) / 3
                title: "Pomodoro"
                icon: "local_cafe"
                active: root.currentMode === 2
                onClicked: root.currentMode = 2
            }
        }

        // Right column - Content area
        Rectangle {
            x: parent.width * 0.2 + Theme.spacingM
            width: parent.width * 0.8 - Theme.spacingM
            height: parent.height
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            border.width: 1

            TimerContent {
                anchors.fill: parent
                visible: root.currentMode === 0
            }

            StopwatchContent {
                anchors.fill: parent
                visible: root.currentMode === 1
            }

            PomodoroContent {
                anchors.fill: parent
                visible: root.currentMode === 2
            }
        }
    }
}
