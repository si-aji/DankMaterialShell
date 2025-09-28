import QtQuick
import qs.Common

Row {
    id: root

    property bool isRunning: false
    property bool isPaused: false
    property bool awaitingContinuation: false
    property bool isLastWorkSession: false
    property bool showReset: false
    property bool skipEnabled: true

    signal startRequested()
    signal pauseRequested()
    signal resumeRequested()
    signal continueRequested()
    signal skipRequested()
    signal finishRequested()
    signal resetRequested()
    signal quitRequested()

    spacing: Theme.spacingM

    function primaryLabel() {
        if (awaitingContinuation) {
            return qsTr("Continue")
        }
        if (isRunning && !isPaused) {
            return qsTr("Pause")
        }
        if (isRunning && isPaused) {
            return qsTr("Resume")
        }
        return qsTr("Start")
    }

    function primaryColor() {
        if (awaitingContinuation || (isRunning && isPaused)) {
            return Theme.primary
        }
        if (isRunning && !isPaused) {
            return Theme.secondary
        }
        return Theme.primary
    }

    function primaryTextColor() {
        if (isRunning && !isPaused && !awaitingContinuation) {
            return Theme.onSecondary
        }
        return Theme.onPrimary
    }

    Rectangle {
        width: 80
        height: 40
        radius: Theme.cornerRadius
        color: root.primaryColor()
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: root.primaryLabel()
            color: root.primaryTextColor()
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.awaitingContinuation) {
                    root.continueRequested()
                } else if (root.isRunning) {
                    if (root.isPaused) {
                        root.resumeRequested()
                    } else {
                        root.pauseRequested()
                    }
                } else {
                    root.startRequested()
                }
            }
            hoverEnabled: true
            onEntered: cursorShape = Qt.PointingHandCursor
            onExited: cursorShape = Qt.ArrowCursor
        }
    }

    Rectangle {
        width: 80
        height: 40
        radius: Theme.cornerRadius
        color: root.isLastWorkSession ? Theme.primary : Theme.surface
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        visible: root.isRunning
        enabled: root.skipEnabled

        Text {
            anchors.centerIn: parent
            text: root.isLastWorkSession ? qsTr("Finish") : qsTr("Skip")
            color: root.isLastWorkSession ? Theme.onPrimary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 1)
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.enabled
            onClicked: {
                if (root.isLastWorkSession) {
                    root.finishRequested()
                } else {
                    root.skipRequested()
                }
            }
            hoverEnabled: true
            onEntered: cursorShape = parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onExited: cursorShape = Qt.ArrowCursor
        }
    }

    Rectangle {
        width: 80
        height: 40
        radius: Theme.cornerRadius
        color: Theme.error
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        visible: root.isRunning

        Text {
            anchors.centerIn: parent
            text: qsTr("Quit")
            color: Theme.onError
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.quitRequested()
            hoverEnabled: true
            onEntered: cursorShape = Qt.PointingHandCursor
            onExited: cursorShape = Qt.ArrowCursor
        }
    }

    Rectangle {
        width: 80
        height: 40
        radius: Theme.cornerRadius
        color: Theme.error
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        visible: root.showReset

        Text {
            anchors.centerIn: parent
            text: qsTr("Reset")
            color: Theme.onError
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.resetRequested()
            hoverEnabled: true
            onEntered: cursorShape = Qt.PointingHandCursor
            onExited: cursorShape = Qt.ArrowCursor
        }
    }
}
