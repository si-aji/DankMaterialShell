import QtQuick
import QtQuick.Controls
import qs.Common

Item {
    id: root

    property int currentSize: 50
    property bool isSlider: false
    property int widgetIndex: -1

    signal sizeChanged(int newSize)

    width: 28
    height: 28

    readonly property var availableSizes: isSlider ? [50, 100] : [25, 50, 75, 100]
    readonly property int currentSizeIndex: availableSizes.indexOf(currentSize)

    Canvas {
        id: pieCanvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            const centerX = width / 2
            const centerY = height / 2
            const radius = Math.min(width, height) / 2 - 2

            ctx.clearRect(0, 0, width, height)

            ctx.strokeStyle = Theme.primary
            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
            ctx.stroke()

            if (availableSizes.length > 0 && currentSizeIndex >= 0) {
                const segmentAngle = (2 * Math.PI) / availableSizes.length
                const startAngle = -Math.PI / 2
                const endAngle = startAngle + segmentAngle * (currentSizeIndex + 1)

                ctx.fillStyle = Theme.primary
                ctx.beginPath()
                ctx.moveTo(centerX, centerY)
                ctx.arc(centerX, centerY, radius - 1, startAngle, endAngle)
                ctx.closePath()
                ctx.fill()
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 12
        height: 12
        radius: 6
        color: Theme.surfaceContainer
        border.color: Theme.outline
        border.width: 1
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const nextIndex = (currentSizeIndex + 1) % availableSizes.length
            const newSize = availableSizes[nextIndex]
            currentSize = newSize
            pieCanvas.requestPaint()
            sizeChanged(newSize)
        }
    }

    onCurrentSizeChanged: {
        pieCanvas.requestPaint()
    }

    onIsSliderChanged: {
        if (isSlider && currentSize !== 50 && currentSize !== 100) {
            currentSize = 50
        }
        pieCanvas.requestPaint()
    }
}