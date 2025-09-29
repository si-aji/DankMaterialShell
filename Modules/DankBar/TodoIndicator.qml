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

    property int pendingCount: 0
    property bool showCompletionMessage: false
    property int _previousPendingCount: 0

    readonly property bool hasPending: pendingCount > 0
    readonly property real horizontalPadding: SettingsData.dankBarNoBackground ? 2 : Theme.spacingXS
    readonly property bool shouldDisplay: hasPending || showCompletionMessage
    readonly property string displayText: showCompletionMessage
                                        ? "Congrats, all todo are finished"
                                        : (pendingCount === 1
                                           ? "1 todo left"
                                           : pendingCount + " todos left")

    width: shouldDisplay ? contentRow.implicitWidth + horizontalPadding * 2 : 0
    height: widgetHeight
    visible: shouldDisplay
    radius: SettingsData.dankBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.dankBarNoBackground) {
            return "transparent"
        }

        const base = hoverArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
        return Qt.rgba(base.r, base.g, base.b, base.a * Theme.widgetTransparency)
    }
    opacity: shouldDisplay ? 1 : 0

    Ref {
        service: TodoService
    }

    function refreshCounts() {
        pendingCount = TodoService.doingTasks ? TodoService.doingTasks.length : 0
    }

    function handleCountsUpdated() {
        const previous = _previousPendingCount
        refreshCounts()

        if (pendingCount === 0 && previous > 0) {
            showCompletionMessage = true
            completionTimer.restart()
        } else if (pendingCount > 0) {
            showCompletionMessage = false
            completionTimer.stop()
        }

        _previousPendingCount = pendingCount
    }

    Component.onCompleted: {
        refreshCounts()
        _previousPendingCount = pendingCount
    }

    Timer {
        id: completionTimer
        interval: 4000
        repeat: false
        onTriggered: showCompletionMessage = false
    }

    Connections {
        target: TodoService
        function onTasksUpdated() {
            handleCountsUpdated()
        }
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
            color: showCompletionMessage ? Theme.primary : Theme.secondary

            DankIcon {
                anchors.centerIn: parent
                name: showCompletionMessage ? "celebration" : "task"
                size: Theme.iconSize - 10
                color: showCompletionMessage ? Theme.onPrimary : Theme.onSecondary
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: displayText
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            const target = popupTarget
            if (!target) {
                return
            }

            if (target.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const screenX = currentScreen.x || 0
                const relativeX = globalPos.x - screenX
                target.setTriggerPosition(relativeX,
                                          SettingsData.getPopupYPosition(barHeight),
                                          width,
                                          section,
                                          currentScreen)
            }

            const todoIndex = target.todoTabIndex !== undefined ? target.todoTabIndex : (SettingsData.weatherEnabled ? 4 : 3)
            const wasVisible = target.dashVisible && target.currentTabIndex === todoIndex
            target.currentTabIndex = todoIndex
            target.dashVisible = !wasVisible
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
