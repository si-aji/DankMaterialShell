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
    readonly property bool pomodoroActive: PomodoroService.isRunning
    readonly property string timeText: {
        const hours = PomodoroService.displayHours || 0
        const minutes = String(PomodoroService.displayMinutes || 0).padStart(2, "0")
        const seconds = String(PomodoroService.displaySeconds || 0).padStart(2, "0")
        if (hours > 0) {
            return `${String(hours).padStart(2, "0")}:${minutes}:${seconds}`
        }
        return `${minutes}:${seconds}`
    }

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
            color: PomodoroService.isBreak ? Theme.secondary : Theme.primary

            DankIcon {
                anchors.centerIn: parent
                name: PomodoroService.isBreak ? "self_improvement" : "local_cafe"
                size: (Theme.iconSize - 10)
                color: PomodoroService.isBreak ? Theme.onSecondary : Theme.onPrimary
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: timeText
            isMonospace: true
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.DemiBold
            color: Theme.surfaceText
        }
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const screenX = currentScreen.x || 0
                const relativeX = globalPos.x - screenX
                popupTarget.setTriggerPosition(relativeX, SettingsData.getPopupYPosition(barHeight), width, section, currentScreen)
            }

            const timerIndex = SettingsData.weatherEnabled ? 3 : 2
            if (popupTarget) {
                const wasVisible = popupTarget.dashVisible && popupTarget.currentTabIndex === timerIndex
                popupTarget.currentTabIndex = timerIndex
                popupTarget.dashVisible = !wasVisible
                if (popupTarget.timerTabComponent) {
                    popupTarget.timerTabComponent.currentMode = 2
                }
            }
        }
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
}
