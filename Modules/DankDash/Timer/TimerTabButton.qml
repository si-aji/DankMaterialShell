import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Rectangle {
    id: button

    property string title: "Button"
    property string icon: "clock"
    property bool active: false

    signal clicked()

    radius: Theme.cornerRadius
    color: active ? Theme.primaryContainer : Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
    border.width: 1

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()

        hoverEnabled: true
        onEntered: cursorShape = Qt.PointingHandCursor
        onExited: cursorShape = Qt.ArrowCursor
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingS

        DankIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: button.icon
            size: 32
            // color: button.active ? Theme.onPrimaryContainer : Theme.surfaceText
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: button.title
            font.pixelSize: 14
            font.weight: Font.Medium
            // color: button.active ? Theme.onPrimaryContainer : Theme.surfaceText
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 1)
        }
    }
}