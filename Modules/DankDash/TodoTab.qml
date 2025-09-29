import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

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
                        text: modelData.label
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
                text: "Tracking: ~/TODO.md"
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
                        // TODO: Implement clear all functionality
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
                        // TODO: Implement finish all functionality
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
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: "Add new task..."
                font.pixelSize: Theme.fontSizeMedium

                onAccepted: {
                    if (text.trim() !== "") {
                        // TODO: Add task functionality
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
                        // TODO: Add task functionality
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

            Item {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                visible: root.currentFilter === 0

                StyledText {
                    text: "Doing tasks will appear here"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    anchors.centerIn: parent
                }
            }

            Item {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                visible: root.currentFilter === 1

                StyledText {
                    text: "Finished tasks will appear here"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    anchors.centerIn: parent
                }
            }
        }
    }
}
