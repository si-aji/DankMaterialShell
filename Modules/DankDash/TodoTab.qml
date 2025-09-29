import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Services

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410

    property int currentFilter: 0 // 0: Doing, 1: Finished
    property int filterButtonHeight: 44
    property var filters: [
        { label: "Ongoing", available: true },
        { label: "Finished", available: true }
    ]
    property int doingCount: 0
    property int finishedCount: 0

    function updateCounts() {
        root.doingCount = TodoService.doingTasks.length
        root.finishedCount = TodoService.finishedTasks.length
    }

    // Connect to TodoService signals
    Connections {
        target: TodoService
        function onTasksUpdated() {
            // Force UI update by toggling visibility
            console.log("Tasks updated, doing:", TodoService.doingTasks.length, "finished:", TodoService.finishedTasks.length)
            root.updateCounts()
            forceUpdateTimer.restart()
        }
    }

    Component.onCompleted: root.updateCounts()

    Timer {
        id: forceUpdateTimer
        interval: 100
        repeat: false
        onTriggered: {
            // Force ListView refresh by reassigning models
            const doingList = doingListView
            const finishedList = finishedListView
            if (doingList) doingList.model = null
            if (finishedList) finishedList.model = null
            if (doingList) doingList.model = TodoService.doingTasks
            if (finishedList) finishedList.model = TodoService.finishedTasks
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingM

        // Top row: Doing/Finished filter buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.filterButtonHeight
            spacing: Theme.spacingS

            Repeater {
                id: filterRepeater
                model: root.filters

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.filterButtonHeight
                    radius: Theme.cornerRadius
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b,
                                           modelData.available ? 0.08 : 0.04)
                    border.width: 1
                    color: root.currentFilter === index
                           ? Theme.primaryContainer
                           : (modelData.available
                              ? Theme.surfaceContainerHigh
                              : Qt.rgba(Theme.surfaceContainerHigh.r,
                                        Theme.surfaceContainerHigh.g,
                                        Theme.surfaceContainerHigh.b,
                                        0.6))

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.label + " (" + (index === 0 ? root.doingCount : root.finishedCount) + ")"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        color: Qt.rgba(Theme.surfaceText.r,
                                       Theme.surfaceText.g,
                                       Theme.surfaceText.b,
                                       modelData.available ? 1 : 0.6)
                    }

                    StateLayer {
                        stateColor: Theme.surfaceText
                        cornerRadius: parent.radius
                        disabled: !modelData.available
                        enabled: modelData.available
                        onClicked: root.currentFilter = index
                    }
                }
            }
        }

        // Second row: Task input and action buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: Theme.spacingS

            StyledText {
                Layout.fillWidth: true
                text: {
                    const path = TodoService.todoFilePath || ""
                    if (!path)
                        return "No file loaded"
                    const shortened = Paths.shortenHome(path)
                    const displayPath = shortened.length > 0 ? shortened : path
                    return "Tracking: " + displayPath
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                verticalAlignment: Text.AlignVCenter
            }

            // Clear All button - only visible for Finished tasks
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 32
                radius: Theme.cornerRadius
                color: Theme.surfaceContainer
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1
                visible: root.currentFilter === 1

                StyledText {
                    anchors.centerIn: parent
                    text: "Clear All"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }

                StateLayer {
                    stateColor: Theme.surfaceText
                    cornerRadius: parent.radius
                    onClicked: {
                        TodoService.clearAllTasks()
                    }
                }
            }

            // Finish All button - only visible for Doing tasks
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 32
                radius: Theme.cornerRadius
                color: Theme.surfaceContainer
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1
                visible: root.currentFilter === 0

                StyledText {
                    anchors.centerIn: parent
                    text: "Finish All"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                }

                StateLayer {
                    stateColor: Theme.surfaceText
                    cornerRadius: parent.radius
                    onClicked: {
                        TodoService.finishAllTasks()
                    }
                }
            }
        }

        // Third row: Task input (only visible for Doing tasks)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: Theme.spacingS
            visible: root.currentFilter === 0

            DankTextField {
                id: taskInput
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: "Add new task..."
                font.pixelSize: Theme.fontSizeMedium

                onAccepted: {
                    if (text.trim() !== "") {
                        TodoService.addTask(text)
                        text = ""
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: Theme.cornerRadius
                color: Theme.primary
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1

                StyledText {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.onPrimary
                }

                StateLayer {
                    stateColor: Theme.onPrimary
                    cornerRadius: parent.radius
                    onClicked: {
                        if (taskInput.text.trim() !== "") {
                            TodoService.addTask(taskInput.text)
                            taskInput.text = ""
                        }
                    }
                }
            }
        }

        // Fourth row: Main content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
            border.width: 1

            // Doing tasks list
            DankListView {
                id: doingListView
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                visible: root.currentFilter === 0
                model: TodoService.doingTasks
                spacing: Theme.spacingXS

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 48
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainer
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingS

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: Math.max(4, Theme.cornerRadius / 2)
                            color: Theme.surface
                            border.color: Theme.outline
                            border.width: 2

                            StyledText {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Bold
                                color: Theme.primary
                                visible: false
                            }

                            StateLayer {
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                onClicked: {
                                    TodoService.finishTask(index)
                                }
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Math.max(4, Theme.cornerRadius / 2)
                            color: Theme.errorContainer

                            DankIcon {
                                anchors.centerIn: parent
                                name: "delete"
                                size: Theme.iconSizeSmall
                                color: Theme.onErrorContainer
                            }

                            StateLayer {
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                onClicked: {
                                    TodoService.removeDoingTask(index)
                                }
                            }
                        }
                    }
                }

                // Show empty state when no tasks
                StyledText {
                    anchors.centerIn: parent
                    text: "No ongoing tasks"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    visible: TodoService.doingTasks.length === 0
                }
            }

            // Finished tasks list
            DankListView {
                id: finishedListView
                anchors.fill: parent
                anchors.margins: Theme.spacingS
                visible: root.currentFilter === 1
                model: TodoService.finishedTasks
                spacing: Theme.spacingXS

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 48
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainer
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingS

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: Math.max(4, Theme.cornerRadius / 2)
                            color: Theme.primaryContainer
                            border.color: Theme.primary
                            border.width: 2

                            StyledText {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Bold
                                color: Theme.onPrimaryContainer
                            }

                            StateLayer {
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                onClicked: {
                                    TodoService.unfinishTask(index)
                                }
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.text
                            font.pixelSize: Theme.fontSizeMedium
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Math.max(4, Theme.cornerRadius / 2)
                            color: Theme.errorContainer

                            DankIcon {
                                anchors.centerIn: parent
                                name: "delete"
                                size: Theme.iconSizeSmall
                                color: Theme.onErrorContainer
                            }

                            StateLayer {
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                onClicked: {
                                    TodoService.removeFinishedTask(index)
                                }
                            }
                        }
                    }
                }

                // Show empty state when no tasks
                StyledText {
                    anchors.centerIn: parent
                    text: "No finished tasks"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    visible: TodoService.finishedTasks.length === 0
                }
            }
        }
    }
}
