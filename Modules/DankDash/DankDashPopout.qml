import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs.Common
import qs.Widgets
import qs.Modules.DankDash

DankPopout {
    id: root

    property bool dashVisible: false
    property string triggerSection: "center"
    property var triggerScreen: null
    property int currentTabIndex: 0
    property var timerTabComponent: null
    property int weatherTabIndex: SettingsData.weatherEnabled ? 2 : -1
    property int timerTabIndex: SettingsData.weatherEnabled ? 3 : 2
    property int todoTabIndex: SettingsData.weatherEnabled ? 4 : 3
    property int settingsTabIndex: SettingsData.weatherEnabled ? 5 : 4

    function setTriggerPosition(x, y, width, section, screen) {
        if (section === "center") {
            const screenWidth = screen ? screen.width : Screen.width
            triggerX = (screenWidth - popupWidth) / 2
            triggerWidth = popupWidth
        } else {
            triggerX = x
            triggerWidth = width
        }
        triggerY = y
        triggerSection = section
        triggerScreen = screen
    }

    popupWidth: 700
    popupHeight: contentLoader.item ? contentLoader.item.implicitHeight : 500
    triggerX: Screen.width - 620 - Theme.spacingL
    triggerY: Math.max(26 + SettingsData.dankBarInnerPadding + 4, Theme.barHeight - 4 - (8 - SettingsData.dankBarInnerPadding)) + SettingsData.dankBarSpacing + SettingsData.dankBarBottomGap - 2 + Theme.popupDistance
    triggerWidth: 80
    positioning: "center"
    shouldBeVisible: dashVisible
    visible: shouldBeVisible


    onDashVisibleChanged: {
        if (dashVisible) {
            open()
        } else {
            close()
        }
    }

    onBackgroundClicked: {
        dashVisible = false
    }

    content: Component {
        Rectangle {
            id: mainContainer

            implicitHeight: contentColumn.height + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            focus: true

            Component.onCompleted: {
                if (root.shouldBeVisible) {
                    forceActiveFocus()
                }
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.dashVisible = false
                    event.accepted = true
                }
            }

            Connections {
                function onShouldBeVisibleChanged() {
                    if (root.shouldBeVisible) {
                        Qt.callLater(function() {
                            mainContainer.forceActiveFocus()
                        })
                    }
                }
                target: root
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Theme.surfaceTint.r, Theme.surfaceTint.g, Theme.surfaceTint.b, 0.04)
                radius: parent.radius

                SequentialAnimation on opacity {
                    running: root.shouldBeVisible
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.08
                        duration: Theme.extraLongDuration
                        easing.type: Theme.standardEasing
                    }

                    NumberAnimation {
                        to: 0.02
                        duration: Theme.extraLongDuration
                        easing.type: Theme.standardEasing
                    }
                }
            }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS

                DankTabBar {
                    id: tabBar

                    width: parent.width
                    height: 48
                    currentIndex: root.currentTabIndex
                    spacing: Theme.spacingS
                    equalWidthTabs: true

                    model: {
                        let tabs = [
                            { icon: "dashboard", text: "Overview" },
                            { icon: "music_note", text: "Media" }
                        ]
                        
                        if (SettingsData.weatherEnabled) {
                            tabs.push({ icon: "wb_sunny", text: "Weather" })
                        }

                        tabs.push({ icon: "timer", text: "Timer" })
                        tabs.push({ icon: "done_all", text: "Todo" })

                        tabs.push({ icon: "settings", text: "Settings", isAction: true })
                        return tabs
                    }

                    onTabClicked: function(index) {
                        root.currentTabIndex = index
                    }

                    onActionTriggered: function(index) {
                        if (index === root.settingsTabIndex) {
                            dashVisible = false
                            settingsModal.show()
                        }
                    }

                }

                Item {
                    width: parent.width
                    height: Theme.spacingXS
                }

                StackLayout {
                    id: pages
                    width: parent.width
                    implicitHeight: {
                        if (root.currentTabIndex === 0) return overviewTab.implicitHeight
                        if (root.currentTabIndex === 1) return mediaTab.implicitHeight
                        if (SettingsData.weatherEnabled && root.currentTabIndex === root.weatherTabIndex) return weatherTab.implicitHeight
                        if (root.currentTabIndex === root.timerTabIndex) return timerTab.implicitHeight
                        if (root.currentTabIndex === root.todoTabIndex) return todoTab.implicitHeight
                        return overviewTab.implicitHeight
                    }
                    currentIndex: {
                        if (!SettingsData.weatherEnabled && root.currentTabIndex >= root.timerTabIndex) {
                            return root.currentTabIndex + 1
                        }
                        return root.currentTabIndex
                    }

                    OverviewTab {
                        id: overviewTab

                        onSwitchToWeatherTab: {
                            if (root.weatherTabIndex >= 0) {
                                tabBar.currentIndex = root.weatherTabIndex
                                tabBar.tabClicked(root.weatherTabIndex)
                            }
                        }

                        onSwitchToMediaTab: {
                            tabBar.currentIndex = 1
                            tabBar.tabClicked(1)
                        }

                        onSwitchToTimerTab: {
                            tabBar.currentIndex = root.timerTabIndex
                            tabBar.tabClicked(root.timerTabIndex)
                        }
                    }

                    MediaPlayerTab {
                        id: mediaTab
                    }

                    WeatherTab {
                        id: weatherTab
                        visible: SettingsData.weatherEnabled && root.currentTabIndex === root.weatherTabIndex
                    }

                    TimerTab {
                        id: timerTab
                        Component.onCompleted: root.timerTabComponent = this
                        onVisibleChanged: {
                            if (visible) {
                                root.timerTabComponent = this
                            }
                        }
                    }

                    TodoTab {
                        id: todoTab
                    }
                }
            }
        }
    }
}
