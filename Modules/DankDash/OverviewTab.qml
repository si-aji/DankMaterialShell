import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.DankDash.Overview

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410

    signal switchToWeatherTab()
    signal switchToMediaTab()
    signal switchToTimerTab()

    Item {
        anchors.fill: parent
        // Clock - top left (narrower and shorter)
        ClockCard {
            x: 0
            y: 0
            width: parent.width * 0.2 - Theme.spacingM * 2
            height: 180
        }

        // Weather - top middle-left (narrower)
        WeatherOverviewCard {
            x: SettingsData.weatherEnabled ? parent.width * 0.2 - Theme.spacingM : 0
            y: 0
            width: SettingsData.weatherEnabled ? parent.width * 0.25 : 0
            height: 100
            visible: SettingsData.weatherEnabled

            onClicked: root.switchToWeatherTab()
        }

        // Pomodoro - top middle (only shows when running)
        PomodoroOverviewCard {
            x: SettingsData.weatherEnabled ? parent.width * 0.45 - Theme.spacingM : parent.width * 0.2 - Theme.spacingM
            y: 0
            width: SettingsData.weatherEnabled ? parent.width * 0.15 : parent.width * 0.3
            height: 100

            onClicked: root.switchToTimerTab()
        }

        // UserInfo - top middle-right (extend when weather disabled)
        UserInfoCard {
            x: SettingsData.weatherEnabled ? parent.width * 0.6 : parent.width * 0.5 - Theme.spacingM
            y: 0
            width: SettingsData.weatherEnabled ? parent.width * 0.4 : parent.width * 0.5
            height: 100
        }

        // SystemMonitor - middle left (narrow and shorter)
        SystemMonitorCard {
            x: 0
            y: 180 + Theme.spacingM
            width: parent.width * 0.2 - Theme.spacingM * 2
            height: 220
        }

        // Calendar - bottom middle (wider and taller)
        CalendarOverviewCard {
            x: parent.width * 0.2 - Theme.spacingM
            y: 100 + Theme.spacingM
            width: parent.width * 0.6
            height: 300
        }

        // Media - bottom right (narrow and taller)
        MediaOverviewCard {
            x: parent.width * 0.8
            y: 100 + Theme.spacingM
            width: parent.width * 0.2
            height: 300

            onClicked: root.switchToMediaTab()
        }
    }
}