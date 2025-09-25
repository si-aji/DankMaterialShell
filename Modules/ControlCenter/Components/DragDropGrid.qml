import QtQuick
import qs.Common
import qs.Services
import qs.Modules.ControlCenter.Widgets
import qs.Modules.ControlCenter.Components

Item {
    id: root

    property bool editMode: false
    property string expandedSection: ""
    property int expandedWidgetIndex: -1
    property var model: null
    property var expandedWidgetData: null

    signal expandClicked(var widgetData, int globalIndex)
    signal removeWidget(int index)
    signal moveWidget(int fromIndex, int toIndex)
    signal toggleWidgetSize(int index)

    readonly property int gridColumns: 4
    readonly property real cellWidth: (width - (gridSpacing + 1) * (gridColumns - 1)) / gridColumns
    readonly property real cellHeight: 60
    readonly property real gridSpacing: 4

    height: {
        const dummy = [SettingsData.controlCenterWidgets?.length, widgetPositions.length]
        return calculateGridHeight() + (detailHost.active ? detailHost.height + Theme.spacingL : 0)
    }

    function calculateGridHeight() {
        const widgets = SettingsData.controlCenterWidgets || []
        if (widgets.length === 0)
            return 0

        let rows = []
        let currentRow = []
        let currentWidth = 0
        const spacing = gridSpacing
        const baseWidth = width

        for (var i = 0; i < widgets.length; i++) {
            const widget = widgets[i]
            const widgetWidth = widget.width || 50

            let itemWidth
            if (widgetWidth <= 25) {
                itemWidth = (baseWidth - spacing * 3) / 4
            } else if (widgetWidth <= 50) {
                itemWidth = (baseWidth - spacing) / 2
            } else if (widgetWidth <= 75) {
                itemWidth = (baseWidth - spacing * 2) * 0.75
            } else {
                itemWidth = baseWidth
            }

            if (currentRow.length > 0 && (currentWidth + spacing + itemWidth > baseWidth)) {
                rows.push([...currentRow])
                currentRow = [widget]
                currentWidth = itemWidth
            } else {
                currentRow.push(widget)
                currentWidth += (currentRow.length > 1 ? spacing : 0) + itemWidth
            }
        }

        if (currentRow.length > 0) {
            rows.push(currentRow)
        }

        return rows.length * cellHeight + (rows.length > 0 ? (rows.length - 1) * spacing : 0)
    }

    DragDropDetailHost {
        id: detailHost
        y: calculateGridHeight()
        anchors.left: parent.left
        anchors.right: parent.right
        expandedSection: root.expandedSection
        expandedWidgetData: root.expandedWidgetData
    }

    function moveToTop(item) {
        const children = root.children
        for (var i = 0; i < children.length; i++) {
            if (children[i] === item)
                continue
            if (children[i].z)
                children[i].z = Math.min(children[i].z, 999)
        }
        item.z = 1000
    }

    Repeater {
        id: widgetRepeater
        model: SettingsData.controlCenterWidgets || []

        DragDropWidgetWrapper {
            id: widgetWrapper

            editMode: root.editMode
            widgetData: modelData
            widgetIndex: index
            gridCellWidth: root.cellWidth
            gridCellHeight: root.cellHeight
            gridColumns: root.gridColumns
            gridLayout: root
            isSlider: {
                const id = modelData.id || ""
                return id === "volumeSlider" || id === "brightnessSlider" || id === "inputVolumeSlider"
            }

            widgetComponent: {
                const id = modelData.id || ""
                if (id === "wifi" || id === "bluetooth" || id === "audioOutput" || id === "audioInput") {
                    return compoundPillComponent
                } else if (id === "volumeSlider") {
                    return audioSliderComponent
                } else if (id === "brightnessSlider") {
                    return brightnessSliderComponent
                } else if (id === "inputVolumeSlider") {
                    return inputAudioSliderComponent
                } else if (id === "battery") {
                    const widgetWidth = modelData.width || 50
                    return widgetWidth <= 25 ? smallBatteryComponent : batteryPillComponent
                } else if (id === "diskUsage") {
                    return diskUsagePillComponent
                } else {
                    const widgetWidth = modelData.width || 50
                    return widgetWidth <= 25 ? smallToggleComponent : toggleButtonComponent
                }
            }

            x: calculateWidgetX(index)
            y: calculateWidgetY(index)

            onWidgetMoved: (fromIndex, toIndex) => root.moveWidget(fromIndex, toIndex)
            onRemoveWidget: index => root.removeWidget(index)
            onToggleWidgetSize: index => root.toggleWidgetSize(index)

            Behavior on x {
                enabled: !editMode
                NumberAnimation {
                    duration: Theme.mediumDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on y {
                enabled: !editMode
                NumberAnimation {
                    duration: Theme.mediumDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    property var widgetPositions: calculateAllWidgetPositions()

    function calculateAllWidgetPositions() {
        const widgets = SettingsData.controlCenterWidgets || []
        let positions = []
        let currentX = 0
        let currentY = 0

        for (var i = 0; i < widgets.length; i++) {
            const widget = widgets[i]
            const widgetWidth = widget.width || 50
            let cellsNeeded = 1

            if (widgetWidth <= 25)
                cellsNeeded = 1
            else if (widgetWidth <= 50)
                cellsNeeded = 2
            else if (widgetWidth <= 75)
                cellsNeeded = 3
            else
                cellsNeeded = 4

            if (currentX + cellsNeeded > gridColumns) {
                currentX = 0
                currentY++
            }

            const horizontalSpacing = gridSpacing
            positions[i] = {
                "x": currentX * cellWidth + (currentX > 0 ? currentX * horizontalSpacing : 0),
                "y": currentY * cellHeight + (currentY > 0 ? currentY * gridSpacing : 0),
                "cellsUsed": cellsNeeded
            }

            currentX += cellsNeeded

            if (currentX >= gridColumns) {
                currentX = 0
                currentY++
            }
        }

        return positions
    }

    function calculateWidgetX(widgetIndex) {
        if (widgetIndex < 0 || widgetIndex >= widgetPositions.length)
            return 0
        return widgetPositions[widgetIndex].x
    }

    function calculateWidgetY(widgetIndex) {
        if (widgetIndex < 0 || widgetIndex >= widgetPositions.length)
            return 0
        return widgetPositions[widgetIndex].y
    }

    Connections {
        target: SettingsData
        function onControlCenterWidgetsChanged() {
            widgetPositions = calculateAllWidgetPositions()
        }
    }

    Component {
        id: compoundPillComponent
        CompoundPill {
            property var widgetData: parent.widgetData || {}
            property int widgetIndex: parent.widgetIndex || 0
            property var widgetDef: root.model?.getWidgetForId(widgetData.id || "")
            width: parent.width
            height: cellHeight
            iconName: {
                switch (widgetData.id || "") {
                case "wifi":
                {
                    if (NetworkService.wifiToggling)
                        return "sync"
                    if (NetworkService.networkStatus === "ethernet")
                        return "settings_ethernet"
                    if (NetworkService.networkStatus === "wifi")
                        return NetworkService.wifiSignalIcon
                    if (NetworkService.wifiEnabled)
                        return "wifi_off"
                    return "wifi_off"
                }
                case "bluetooth":
                {
                    if (!BluetoothService.available)
                        return "bluetooth_disabled"
                    if (!BluetoothService.adapter || !BluetoothService.adapter.enabled)
                        return "bluetooth_disabled"
                    const primaryDevice = (() => {
                                               if (!BluetoothService.adapter || !BluetoothService.adapter.devices)
                                               return null
                                               let devices = [...BluetoothService.adapter.devices.values.filter(dev => dev && (dev.paired || dev.trusted))]
                                               for (let device of devices) {
                                                   if (device && device.connected)
                                                   return device
                                               }
                                               return null
                                           })()
                    if (primaryDevice)
                        return BluetoothService.getDeviceIcon(primaryDevice)
                    return "bluetooth"
                }
                case "audioOutput":
                {
                    if (!AudioService.sink)
                        return "volume_off"
                    let volume = AudioService.sink.audio.volume
                    let muted = AudioService.sink.audio.muted
                    if (muted || volume === 0.0)
                        return "volume_off"
                    if (volume <= 0.33)
                        return "volume_down"
                    if (volume <= 0.66)
                        return "volume_up"
                    return "volume_up"
                }
                case "audioInput":
                {
                    if (!AudioService.source)
                        return "mic_off"
                    let muted = AudioService.source.audio.muted
                    return muted ? "mic_off" : "mic"
                }
                default:
                    return widgetDef?.icon || "help"
                }
            }
            primaryText: {
                switch (widgetData.id || "") {
                case "wifi":
                {
                    if (NetworkService.wifiToggling)
                        return NetworkService.wifiEnabled ? "Disabling WiFi..." : "Enabling WiFi..."
                    if (NetworkService.networkStatus === "ethernet")
                        return "Ethernet"
                    if (NetworkService.networkStatus === "wifi" && NetworkService.currentWifiSSID)
                        return NetworkService.currentWifiSSID
                    if (NetworkService.wifiEnabled)
                        return "Not connected"
                    return "WiFi off"
                }
                case "bluetooth":
                {
                    if (!BluetoothService.available)
                        return "Bluetooth"
                    if (!BluetoothService.adapter)
                        return "No adapter"
                    if (!BluetoothService.adapter.enabled)
                        return "Disabled"
                    return "Enabled"
                }
                case "audioOutput":
                    return AudioService.sink?.description || "No output device"
                case "audioInput":
                    return AudioService.source?.description || "No input device"
                default:
                    return widgetDef?.text || "Unknown"
                }
            }
            secondaryText: {
                switch (widgetData.id || "") {
                case "wifi":
                {
                    if (NetworkService.wifiToggling)
                        return "Please wait..."
                    if (NetworkService.networkStatus === "ethernet")
                        return "Connected"
                    if (NetworkService.networkStatus === "wifi")
                        return NetworkService.wifiSignalStrength > 0 ? NetworkService.wifiSignalStrength + "%" : "Connected"
                    if (NetworkService.wifiEnabled)
                        return "Select network"
                    return ""
                }
                case "bluetooth":
                {
                    if (!BluetoothService.available)
                        return "No adapters"
                    if (!BluetoothService.adapter || !BluetoothService.adapter.enabled)
                        return "Off"
                    const primaryDevice = (() => {
                                               if (!BluetoothService.adapter || !BluetoothService.adapter.devices)
                                               return null
                                               let devices = [...BluetoothService.adapter.devices.values.filter(dev => dev && (dev.paired || dev.trusted))]
                                               for (let device of devices) {
                                                   if (device && device.connected)
                                                   return device
                                               }
                                               return null
                                           })()
                    if (primaryDevice)
                        return primaryDevice.name || primaryDevice.alias || primaryDevice.deviceName || "Connected Device"
                    return "No devices"
                }
                case "audioOutput":
                {
                    if (!AudioService.sink)
                        return "Select device"
                    if (AudioService.sink.audio.muted)
                        return "Muted"
                    return Math.round(AudioService.sink.audio.volume * 100) + "%"
                }
                case "audioInput":
                {
                    if (!AudioService.source)
                        return "Select device"
                    if (AudioService.source.audio.muted)
                        return "Muted"
                    return Math.round(AudioService.source.audio.volume * 100) + "%"
                }
                default:
                    return widgetDef?.description || ""
                }
            }
            isActive: {
                switch (widgetData.id || "") {
                case "wifi":
                {
                    if (NetworkService.wifiToggling)
                        return false
                    if (NetworkService.networkStatus === "ethernet")
                        return true
                    if (NetworkService.networkStatus === "wifi")
                        return true
                    return NetworkService.wifiEnabled
                }
                case "bluetooth":
                    return !!(BluetoothService.available && BluetoothService.adapter && BluetoothService.adapter.enabled)
                case "audioOutput":
                    return !!(AudioService.sink && !AudioService.sink.audio.muted)
                case "audioInput":
                    return !!(AudioService.source && !AudioService.source.audio.muted)
                default:
                    return false
                }
            }
            enabled: !root.editMode && (widgetDef?.enabled ?? true)
            onToggled: {
                if (root.editMode)
                    return
                switch (widgetData.id || "") {
                case "wifi":
                {
                    if (NetworkService.networkStatus !== "ethernet" && !NetworkService.wifiToggling) {
                        NetworkService.toggleWifiRadio()
                    }
                    break
                }
                case "bluetooth":
                {
                    if (BluetoothService.available && BluetoothService.adapter) {
                        BluetoothService.adapter.enabled = !BluetoothService.adapter.enabled
                    }
                    break
                }
                case "audioOutput":
                {
                    if (AudioService.sink && AudioService.sink.audio) {
                        AudioService.sink.audio.muted = !AudioService.sink.audio.muted
                    }
                    break
                }
                case "audioInput":
                {
                    if (AudioService.source && AudioService.source.audio) {
                        AudioService.source.audio.muted = !AudioService.source.audio.muted
                    }
                    break
                }
                }
            }
            onExpandClicked: {
                if (!root.editMode)
                    root.expandClicked(widgetData, widgetIndex)
            }
            onWheelEvent: function (wheelEvent) {
                if (root.editMode)
                    return
                const id = widgetData.id || ""
                if (id === "audioOutput") {
                    if (!AudioService.sink || !AudioService.sink.audio)
                        return
                    let delta = wheelEvent.angleDelta.y
                    let currentVolume = AudioService.sink.audio.volume * 100
                    let newVolume
                    if (delta > 0)
                        newVolume = Math.min(100, currentVolume + 5)
                    else
                        newVolume = Math.max(0, currentVolume - 5)
                    AudioService.sink.audio.muted = false
                    AudioService.sink.audio.volume = newVolume / 100
                    wheelEvent.accepted = true
                } else if (id === "audioInput") {
                    if (!AudioService.source || !AudioService.source.audio)
                        return
                    let delta = wheelEvent.angleDelta.y
                    let currentVolume = AudioService.source.audio.volume * 100
                    let newVolume
                    if (delta > 0)
                        newVolume = Math.min(100, currentVolume + 5)
                    else
                        newVolume = Math.max(0, currentVolume - 5)
                    AudioService.source.audio.muted = false
                    AudioService.source.audio.volume = newVolume / 100
                    wheelEvent.accepted = true
                }
            }
        }
    }

    Component {
        id: audioSliderComponent
        AudioSliderRow {
            width: parent.width
            height: 14
            enabled: !root.editMode
            property color sliderTrackColor: Theme.surfaceContainerHigh
        }
    }

    Component {
        id: brightnessSliderComponent
        BrightnessSliderRow {
            width: parent.width
            height: 14
            enabled: !root.editMode
            property color sliderTrackColor: Theme.surfaceContainerHigh
        }
    }

    Component {
        id: inputAudioSliderComponent
        InputAudioSliderRow {
            width: parent.width
            height: 14
            enabled: !root.editMode
            property color sliderTrackColor: Theme.surfaceContainerHigh
        }
    }

    Component {
        id: batteryPillComponent
        BatteryPill {
            width: parent.width
            height: cellHeight
            enabled: !root.editMode
            onExpandClicked: {
                if (!root.editMode)
                    root.expandClicked(parent.widgetData, parent.widgetIndex)
            }
        }
    }

    Component {
        id: smallBatteryComponent
        SmallBatteryButton {
            width: parent.width
            height: 48
            enabled: !root.editMode
            onClicked: {
                if (!root.editMode)
                    root.expandClicked(parent.widgetData, parent.widgetIndex)
            }
        }
    }

    Component {
        id: toggleButtonComponent
        ToggleButton {
            property var widgetData: parent.widgetData || {}
            property int widgetIndex: parent.widgetIndex || 0
            property var widgetDef: root.model?.getWidgetForId(widgetData.id || "")
            width: parent.width
            height: cellHeight

            iconName: {
                switch (widgetData.id || "") {
                case "nightMode":
                    return DisplayService.nightModeEnabled ? "nightlight" : "dark_mode"
                case "darkMode":
                    return "contrast"
                case "doNotDisturb":
                    return SessionData.doNotDisturb ? "do_not_disturb_on" : "do_not_disturb_off"
                case "idleInhibitor":
                    return SessionService.idleInhibited ? "motion_sensor_active" : "motion_sensor_idle"
                default:
                    return widgetDef?.icon || "help"
                }
            }

            text: {
                switch (widgetData.id || "") {
                case "nightMode":
                    return "Night Mode"
                case "darkMode":
                    return SessionData.isLightMode ? "Light Mode" : "Dark Mode"
                case "doNotDisturb":
                    return "Do Not Disturb"
                case "idleInhibitor":
                    return SessionService.idleInhibited ? "Keeping Awake" : "Keep Awake"
                default:
                    return widgetDef?.text || "Unknown"
                }
            }

            iconRotation: widgetData.id === "darkMode" && SessionData.isLightMode ? 180 : 0

            isActive: {
                switch (widgetData.id || "") {
                case "nightMode":
                    return DisplayService.nightModeEnabled || false
                case "darkMode":
                    return !SessionData.isLightMode
                case "doNotDisturb":
                    return SessionData.doNotDisturb || false
                case "idleInhibitor":
                    return SessionService.idleInhibited || false
                default:
                    return false
                }
            }

            enabled: !root.editMode && (widgetDef?.enabled ?? true)

            onClicked: {
                if (root.editMode)
                    return
                switch (widgetData.id || "") {
                case "nightMode":
                {
                    if (DisplayService.automationAvailable)
                        DisplayService.toggleNightMode()
                    break
                }
                case "darkMode":
                {
                    Theme.toggleLightMode()
                    break
                }
                case "doNotDisturb":
                {
                    SessionData.setDoNotDisturb(!SessionData.doNotDisturb)
                    break
                }
                case "idleInhibitor":
                {
                    SessionService.toggleIdleInhibit()
                    break
                }
                }
            }
        }
    }

    Component {
        id: smallToggleComponent
        SmallToggleButton {
            property var widgetData: parent.widgetData || {}
            property int widgetIndex: parent.widgetIndex || 0
            property var widgetDef: root.model?.getWidgetForId(widgetData.id || "")
            width: parent.width
            height: 48

            iconName: {
                switch (widgetData.id || "") {
                case "nightMode":
                    return DisplayService.nightModeEnabled ? "nightlight" : "dark_mode"
                case "darkMode":
                    return "contrast"
                case "doNotDisturb":
                    return SessionData.doNotDisturb ? "do_not_disturb_on" : "do_not_disturb_off"
                case "idleInhibitor":
                    return SessionService.idleInhibited ? "motion_sensor_active" : "motion_sensor_idle"
                default:
                    return widgetDef?.icon || "help"
                }
            }

            iconRotation: widgetData.id === "darkMode" && SessionData.isLightMode ? 180 : 0

            isActive: {
                switch (widgetData.id || "") {
                case "nightMode":
                    return DisplayService.nightModeEnabled || false
                case "darkMode":
                    return !SessionData.isLightMode
                case "doNotDisturb":
                    return SessionData.doNotDisturb || false
                case "idleInhibitor":
                    return SessionService.idleInhibited || false
                default:
                    return false
                }
            }

            enabled: !root.editMode && (widgetDef?.enabled ?? true)

            onClicked: {
                if (root.editMode)
                    return
                switch (widgetData.id || "") {
                case "nightMode":
                {
                    if (DisplayService.automationAvailable)
                        DisplayService.toggleNightMode()
                    break
                }
                case "darkMode":
                {
                    Theme.toggleLightMode()
                    break
                }
                case "doNotDisturb":
                {
                    SessionData.setDoNotDisturb(!SessionData.doNotDisturb)
                    break
                }
                case "idleInhibitor":
                {
                    SessionService.toggleIdleInhibit()
                    break
                }
                }
            }
        }
    }

    Component {
        id: diskUsagePillComponent
        DiskUsagePill {
            width: parent.width
            height: cellHeight
            enabled: !root.editMode
            mountPath: parent.widgetData?.mountPath || "/"
            instanceId: parent.widgetData?.instanceId || ""
            onExpandClicked: {
                if (!root.editMode)
                    root.expandClicked(parent.widgetData, parent.widgetIndex)
            }
        }
    }
}
