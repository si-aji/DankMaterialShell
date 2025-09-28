import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingL

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Pomodoro Timer"
            font.pixelSize: 36
            font.weight: Font.Bold
            color: Theme.primary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "25:00"
            font.pixelSize: 48
            font.family: Theme.monoFont
            color: Theme.primary
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
                    text: "Start"
                    color: Theme.onPrimary
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Start pomodoro")
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }

            Rectangle {
                width: 80
                height: 40
                radius: Theme.cornerRadius
                color: Theme.secondary
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Skip"
                    color: Theme.onSecondary
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Skip pomodoro")
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
                    text: "Reset"
                    color: Theme.onSurface
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Reset pomodoro")
                    hoverEnabled: true
                    onEntered: cursorShape = Qt.PointingHandCursor
                    onExited: cursorShape = Qt.ArrowCursor
                }
            }
        }
    }
}