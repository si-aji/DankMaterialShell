import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property bool editMode: false
    property var widgetData: null
    property int widgetIndex: -1
    property bool isSlider: false
    property Component widgetComponent: null
    property real gridCellWidth: 100
    property real gridCellHeight: 60
    property int gridColumns: 4
    property var gridLayout: null

    signal widgetMoved(int fromIndex, int toIndex)
    signal removeWidget(int index)
    signal toggleWidgetSize(int index)

    width: {
        const widgetWidth = widgetData?.width || 50
        if (widgetWidth <= 25) return gridCellWidth
        else if (widgetWidth <= 50) return gridCellWidth * 2
        else if (widgetWidth <= 75) return gridCellWidth * 3
        else return gridCellWidth * 4
    }
    height: gridCellHeight

    Rectangle {
        id: dragIndicator
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.primary
        border.width: dragArea.drag.active ? 2 : 0
        radius: Theme.cornerRadius
        opacity: dragArea.drag.active ? 0.8 : 1.0
        z: dragArea.drag.active ? 1000 : 1

        Behavior on border.width {
            NumberAnimation { duration: 150 }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    Loader {
        id: widgetLoader
        anchors.fill: parent
        sourceComponent: widgetComponent
        property var widgetData: root.widgetData
        property int widgetIndex: root.widgetIndex
        property int globalWidgetIndex: root.widgetIndex
        property int widgetWidth: root.widgetData?.width || 50

        MouseArea {
            id: editModeBlocker
            anchors.fill: parent
            enabled: root.editMode
            acceptedButtons: Qt.AllButtons
            onPressed: mouse.accepted = true
            onWheel: wheel.accepted = true
            z: 100
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        enabled: editMode
        cursorShape: editMode ? Qt.OpenHandCursor : Qt.ArrowCursor
        drag.target: editMode ? root : null
        drag.axis: Drag.XAndYAxis
        drag.smoothed: true

        onPressed: {
            if (editMode) {
                cursorShape = Qt.ClosedHandCursor
                root.z = 1000
                root.parent.moveToTop(root)
            }
        }

        onReleased: {
            if (editMode) {
                cursorShape = Qt.OpenHandCursor
                root.z = 1
                root.snapToGrid()
            }
        }
    }

    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    function snapToGrid() {
        if (!editMode || !gridLayout) return

        const globalPos = root.mapToItem(gridLayout, 0, 0)
        const cellWidth = gridLayout.width / gridColumns
        const cellHeight = gridCellHeight + Theme.spacingS

        let targetCol = Math.max(0, Math.round(globalPos.x / cellWidth))
        let targetRow = Math.max(0, Math.round(globalPos.y / cellHeight))

        const widgetCells = Math.ceil(root.width / cellWidth)

        if (targetCol + widgetCells > gridColumns) {
            targetCol = Math.max(0, gridColumns - widgetCells)
        }

        const newIndex = findBestInsertionIndex(targetRow, targetCol)

        if (newIndex !== widgetIndex && newIndex >= 0 && newIndex < (SettingsData.controlCenterWidgets?.length || 0)) {
            widgetMoved(widgetIndex, newIndex)
        }
    }

    function findBestInsertionIndex(targetRow, targetCol) {
        const widgets = SettingsData.controlCenterWidgets || []
        if (!widgets.length) return 0

        const targetPosition = targetRow * gridColumns + targetCol

        // Find the widget position closest to our target
        let bestIndex = 0
        let bestDistance = Infinity

        for (let i = 0; i <= widgets.length; i++) {
            if (i === widgetIndex) continue

            let currentPos = calculatePositionForIndex(i)
            let distance = Math.abs(currentPos - targetPosition)

            if (distance < bestDistance) {
                bestDistance = distance
                bestIndex = i > widgetIndex ? i - 1 : i
            }
        }

        return Math.max(0, Math.min(bestIndex, widgets.length - 1))
    }

    function calculatePositionForIndex(index) {
        const widgets = SettingsData.controlCenterWidgets || []
        let currentX = 0
        let currentY = 0

        for (let i = 0; i < index && i < widgets.length; i++) {
            if (i === widgetIndex) continue

            const widget = widgets[i]
            const widgetWidth = widget.width || 50
            let cellsNeeded = widgetWidth <= 25 ? 1 : widgetWidth <= 50 ? 2 : widgetWidth <= 75 ? 3 : 4

            if (currentX + cellsNeeded > gridColumns) {
                currentX = 0
                currentY++
            }

            currentX += cellsNeeded
            if (currentX >= gridColumns) {
                currentX = 0
                currentY++
            }
        }

        return currentY * gridColumns + currentX
    }

    function getWidgetWidth(widgetWidth) {
        const cellWidth = gridLayout ? gridLayout.width / gridColumns : gridCellWidth
        if (widgetWidth <= 25) return cellWidth
        else if (widgetWidth <= 50) return cellWidth * 2
        else if (widgetWidth <= 75) return cellWidth * 3
        else return cellWidth * 4
    }

    Rectangle {
        width: 16
        height: 16
        radius: 8
        color: Theme.error
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: -4
        visible: editMode
        z: 10

        DankIcon {
            anchors.centerIn: parent
            name: "close"
            size: 12
            color: Theme.primaryText
        }

        MouseArea {
            anchors.fill: parent
            onClicked: removeWidget(widgetIndex)
        }
    }

    PieChartSizeControl {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: -6
        visible: editMode
        z: 10
        currentSize: root.widgetData?.width || 50
        isSlider: root.isSlider
        widgetIndex: root.widgetIndex
        onSizeChanged: (newSize) => {
            var widgets = SettingsData.controlCenterWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets[widgetIndex].width = newSize
                SettingsData.setControlCenterWidgets(widgets)
            }
        }
    }

    Rectangle {
        id: dragHandle
        width: 16
        height: 12
        radius: 2
        color: Theme.primary
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 4
        visible: editMode
        z: 15
        opacity: dragArea.drag.active ? 1.0 : 0.7

        DankIcon {
            anchors.centerIn: parent
            name: "drag_indicator"
            size: 10
            color: Theme.primaryText
        }

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: editMode ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08) : "transparent"
        radius: Theme.cornerRadius
        border.color: "transparent"
        border.width: 0
        z: -1

        Behavior on color {
            ColorAnimation { duration: Theme.shortDuration }
        }
    }
}