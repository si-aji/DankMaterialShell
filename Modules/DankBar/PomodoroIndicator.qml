import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property real widgetHeight: 30
    property real barHeight: 48
    property string section: "center"
    property var popupTarget: null
    property var parentScreen: null

    readonly property real horizontalPadding: SettingsData.dankBarNoBackground ? 2 : Theme.spacingXS
    readonly property bool pomodoroActive: PomodoroService.shouldDisplay
    readonly property bool awaitingConfirmation: PomodoroService.showConfirmation
            || (PomodoroService.pendingSessionSwitch && !PomodoroService.showCongratulations)
            || PomodoroService.awaitingContinuation
    readonly property string fallbackConfirmationText: PomodoroService.pendingTargetIsBreak
            ? qsTr("Start break time?")
            : qsTr("Start work time?")
    readonly property string timeText: {
        const hours = PomodoroService.displayHours || 0
        const minutes = String(PomodoroService.displayMinutes || 0).padStart(2, "0")
        const seconds = String(PomodoroService.displaySeconds || 0).padStart(2, "0")
        if (hours > 0) {
            return `${String(hours).padStart(2, "0")}:${minutes}:${seconds}`
        }
        return `${minutes}:${seconds}`
    }
    readonly property string displayText: awaitingConfirmation
            ? (PomodoroService.confirmationMessage && PomodoroService.confirmationMessage.length > 0
                ? PomodoroService.confirmationMessage
                : fallbackConfirmationText)
            : timeText

    width: pomodoroActive ? contentRow.implicitWidth + horizontalPadding * 2 : 0
    height: widgetHeight
    visible: pomodoroActive
    radius: SettingsData.dankBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.dankBarNoBackground) {
            return "transparent"
        }

        const base = hoverArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
        return Qt.rgba(base.r, base.g, base.b, base.a * Theme.widgetTransparency)
    }
    opacity: pomodoroActive ? 1 : 0

    Ref {
        service: PomodoroService
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: Theme.spacingXS

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.iconSize - 4
            height: Theme.iconSize - 4
            radius: (Theme.iconSize - 4) / 2
            color: awaitingConfirmation ? Theme.surfaceVariant : (PomodoroService.isBreak ? Theme.secondary : Theme.primary)

            DankIcon {
                anchors.centerIn: parent
                name: awaitingConfirmation ? "hourglass_empty" : (PomodoroService.isBreak ? "self_improvement" : "local_cafe")
                size: (Theme.iconSize - 10)
                color: awaitingConfirmation ? Theme.surfaceText : (PomodoroService.isBreak ? Theme.onSecondary : Theme.onPrimary)
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: displayText
            isMonospace: !awaitingConfirmation
            font.pixelSize: awaitingConfirmation ? Theme.fontSizeMedium : Theme.fontSizeMedium
            font.weight: awaitingConfirmation ? Font.Medium : Font.DemiBold
            color: Theme.surfaceText
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            visible: displayText.length > 0
        }
    }

    function enforcePomodoroMode() {
        if (!popupTarget) {
            return
        }

        const setMode = function() {
            if (popupTarget && popupTarget.timerTabComponent) {
                popupTarget.timerTabComponent.currentMode = 2
            }
        }

        setMode()
        Qt.callLater(setMode)
    }

    function togglePomodoroPopup(forceOpen) {
        const target = popupTarget
        if (!target) {
            Qt.callLater(function() {
                togglePomodoroPopup(true)
            })
            return
        }

        const timerIndex = SettingsData.weatherEnabled ? 3 : 2
        const alreadyOnPomodoro = target.dashVisible && target.currentTabIndex === timerIndex

        if (!forceOpen && alreadyOnPomodoro) {
            target.dashVisible = false
            return
        }

        if ((PomodoroService.pendingSessionSwitch || PomodoroService.awaitingContinuation)
                && !PomodoroService.showConfirmation
                && !PomodoroService.showCongratulations) {
            PomodoroService.showSessionSwitchConfirmation(false)
        }

        if (target.setTriggerPosition) {
            const globalPos = mapToGlobal(0, 0)
            const currentScreen = parentScreen || Screen
            const screenX = currentScreen.x || 0
            const relativeX = globalPos.x - screenX
            target.setTriggerPosition(relativeX, SettingsData.getPopupYPosition(barHeight), width, section, currentScreen)
        }

        target.currentTabIndex = timerIndex
        target.dashVisible = true
        enforcePomodoroMode()
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: togglePomodoroPopup(false)
    }

    Behavior on width {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }

    Connections {
        target: PomodoroService
        function onSessionSwitchPrompted(fromSkip) {
            togglePomodoroPopup(true)
        }

        function onShowConfirmationChanged() {
            if (!PomodoroService.showConfirmation
                    && popupTarget
                    && popupTarget.dashVisible) {
                enforcePomodoroMode()
            }
        }

        function onSessionSwitchCancelled() {
            if (popupTarget && popupTarget.dashVisible) {
                enforcePomodoroMode()
            }
        }
    }
}
