pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool batteryAvailable: device && device.ready && device.isLaptopBattery
    readonly property real batteryLevel: batteryAvailable ? Math.round(device.percentage * 100) : 0
    readonly property bool isCharging: batteryAvailable && device.state === UPowerDeviceState.Charging && device.changeRate > 0
    readonly property bool isPluggedIn: batteryAvailable && (device.state !== UPowerDeviceState.Discharging && device.state !== UPowerDeviceState.Empty)
    readonly property bool isLowBattery: batteryAvailable && batteryLevel <= 20
    readonly property string batteryHealth: {
        if (!batteryAvailable) {
            return "N/A"
        }

        if (device.healthSupported && device.healthPercentage > 0) {
            return `${Math.round(device.healthPercentage)}%`
        }

        if (batteryHealthUpower > 0) {
            return `${batteryHealthUpower}%`
        }

        return "N/A"
    }
    readonly property real batteryCapacity: batteryAvailable && device.energyCapacity > 0 ? device.energyCapacity : 0
    readonly property string batteryStatus: {
        if (!batteryAvailable) {
            return "No Battery"
        }

        if (device.state === UPowerDeviceState.Charging && device.changeRate <= 0) {
            return "Plugged In"
        }

        return UPowerDeviceState.toString(device.state)
    }
    readonly property bool suggestPowerSaver: batteryAvailable && isLowBattery && UPower.onBattery && (typeof PowerProfiles !== "undefined" && PowerProfiles.profile !== PowerProfile.PowerSaver)

    readonly property var bluetoothDevices: {
        const btDevices = []
        const bluetoothTypes = [UPowerDeviceType.BluetoothGeneric, UPowerDeviceType.Headphones, UPowerDeviceType.Headset, UPowerDeviceType.Keyboard, UPowerDeviceType.Mouse, UPowerDeviceType.Speakers]

        for (var i = 0; i < UPower.devices.count; i++) {
            const dev = UPower.devices.get(i)
            if (dev && dev.ready && bluetoothTypes.includes(dev.type)) {
                btDevices.push({
                                   "name": dev.model || UPowerDeviceType.toString(dev.type),
                                   "percentage": Math.round(dev.percentage),
                                   "type": dev.type
                               })
            }
        }
        return btDevices
    }

    readonly property string capacityBaseCmd: `upower -i /org/freedesktop/UPower/devices/battery_DEVICE_REPLACE_ME | awk -F': *' '/^\\s*capacity:/ {gsub(/%/,"",$2); print $2; exit}'`
    property var batteryHealthUpower: -1

    Component.onCompleted: {
        // ! TODO - quickshell doesnt seem to expose health correctly all the time, so this is a janky workaround
        for (const device of UPower.devices.values) {
            if (device.isLaptopBattery) {
                batteryCapacityProcess.command = ["sh", "-c", capacityBaseCmd.replace("DEVICE_REPLACE_ME", device.nativePath)]
                console.log("Executing battery capacity command: " + batteryCapacityProcess.command)
            batteryCapacityProcess.running = true
                break                
            }
        }
    }

    Process {
        id: batteryCapacityProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Battery capacity (upower) raw: " + text)
                const capacity = parseFloat(text.trim())
                if (!isNaN(capacity) && capacity > 0 && capacity <= 100) {
                    root.batteryHealthUpower = Math.round(capacity)
                    console.log("Battery health (upower): " + root.batteryHealthUpower + "%")
                } else {
                    root.batteryHealthUpower = -1
                }
            }
        }
    }

    function formatTimeRemaining() {
        if (!batteryAvailable) {
            return "Unknown"
        }

        const timeSeconds = isCharging ? device.timeToFull : device.timeToEmpty

        if (!timeSeconds || timeSeconds <= 0 || timeSeconds > 86400) {
            return "Unknown"
        }

        const hours = Math.floor(timeSeconds / 3600)
        const minutes = Math.floor((timeSeconds % 3600) / 60)

        if (hours > 0) {
            return `${hours}h ${minutes}m`
        }

        return `${minutes}m`
    }
}
