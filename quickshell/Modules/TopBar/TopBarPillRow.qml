import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.Common
import qs.Modules.TopBar.Widgets

Item {
    id: root

    required property var parentScreen
    required property var axis

    readonly property var componentMap: ({
        "clockDate": clockDateComponent,
        "weather": weatherComponent,
        "cpuMonitor": cpuMonitorComponent,
        "tray": trayComponent,
        "cpuTemp": cpuTempComponent,
        "gpuTemp": gpuTempComponent,
        "ram": ramComponent,
        "diskUsage": diskUsageComponent,
        "networkMonitor": networkMonitorComponent,
        "battery": batteryComponent,
        "capsLock": capsLockComponent,
        "idleInhibitor": idleInhibitorComponent,
        "privacyIndicator": privacyIndicatorComponent,
        "keyboardLayoutName": keyboardLayoutNameComponent,
        "media": mediaComponent,
        "launcherButton": launcherButtonComponent
    })

    readonly property var groups: computeGroups(SettingsData.topBarWidgets)

    function computeGroups(widgetList) {
        const enabled = widgetList.filter(w => w.enabled !== false);
        const groups = [];
        for (const w of enabled) {
            if (w.joinsPrevious && groups.length > 0) {
                groups[groups.length - 1].push(w);
            } else {
                groups.push([w]);
            }
        }
        return groups;
    }

    implicitWidth: pillRow.implicitWidth
    implicitHeight: 40

    // Hiding the whole window (autohide) and showing it again can leave a
    // loaded widget's own `visible` stuck false, which collapses its
    // memberWrapper out of the RowLayout and shrinks the pill to empty even
    // though the widget's content never actually changed. Forcing the
    // binding to re-evaluate once the window is visible again fixes it.
    function relayoutGroups() {
        for (let i = 0; i < pillRepeater.count; i++) {
            const pillItem = pillRepeater.itemAt(i);
            if (!pillItem)
                continue;
            for (let j = 0; j < pillItem.memberRepeater.count; j++) {
                const member = pillItem.memberRepeater.itemAt(j);
                if (member)
                    member.refreshVisibility();
            }
        }
    }

    Component {
        id: clockDateComponent
        ClockDateWidget {}
    }

    Component {
        id: weatherComponent
        WeatherWidget {}
    }

    Component {
        id: cpuMonitorComponent
        CpuMonitorWidget {}
    }

    Component {
        id: trayComponent
        TrayWidget {}
    }

    Component {
        id: cpuTempComponent
        CpuTemperatureWidget {}
    }

    Component {
        id: gpuTempComponent
        GpuTemperatureWidget {}
    }

    Component {
        id: ramComponent
        RamMonitorWidget {}
    }

    Component {
        id: diskUsageComponent
        DiskUsageWidget {}
    }

    Component {
        id: networkMonitorComponent
        NetworkMonitorWidget {}
    }

    Component {
        id: batteryComponent
        BatteryWidget {}
    }

    Component {
        id: capsLockComponent
        CapsLockIndicatorWidget {}
    }

    Component {
        id: idleInhibitorComponent
        IdleInhibitorWidget {}
    }

    Component {
        id: privacyIndicatorComponent
        PrivacyIndicatorWidget {}
    }

    Component {
        id: keyboardLayoutNameComponent
        KeyboardLayoutNameWidget {}
    }

    Component {
        id: mediaComponent
        MediaWidget {}
    }

    Component {
        id: launcherButtonComponent
        LauncherButtonWidget {}
    }

    Row {
        id: pillRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            id: pillRepeater
            model: root.groups

            Rectangle {
                id: pill
                required property var modelData
                readonly property var members: modelData
                readonly property alias memberRepeater: memberRepeater

                width: groupRow.implicitWidth + 32
                height: 40
                radius: 12
                color: Theme.surfaceContainerHigh
                border.width: 1
                // Theme.borderSoft doesn't exist in this fork's Theme.qml (that
                // token is from the old repo); outlineMedium is the closest
                // existing analog - it's DMS's own default border color for
                // floating surfaces (DankModal.borderColor).
                border.color: Theme.outlineMedium

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#8c000000"
                    blurMax: 24
                    shadowBlur: 1.0
                    shadowVerticalOffset: 4
                }

                RowLayout {
                    id: groupRow
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        id: memberRepeater
                        model: pill.members

                        RowLayout {
                            id: memberWrapper
                            required property var modelData
                            required property int index
                            spacing: 10
                            // Hide the whole member (divider included) when the
                            // loaded widget hides itself (e.g. WeatherWidget's
                            // own SettingsData.weatherEnabled binding) - RowLayout
                            // excludes invisible children from layout entirely,
                            // so this also closes the gap, not just the icon.
                            visible: !widgetHost.item || widgetHost.item.visible

                            // The window hiding (autohide) and showing again can leave
                            // widgetHost.item.visible stuck false, which this binding
                            // then propagates - re-evaluating it once the window is
                            // visible again clears the stuck value.
                            function refreshVisibility() {
                                memberWrapper.visible = true;
                                memberWrapper.visible = Qt.binding(function () {
                                    return !widgetHost.item || widgetHost.item.visible;
                                });
                            }

                            Rectangle {
                                visible: memberWrapper.index > 0
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                Layout.topMargin: 4
                                Layout.bottomMargin: 4
                                color: Theme.outlineVariant
                            }

                            // A Loader with an explicit size assigns that size to its
                            // item, which would clobber PluginComponent's own width
                            // binding. Sizing the WidgetHost from the layout while
                            // reading its item's width back would therefore collapse
                            // both to 0, so the layout sizes this wrapper instead and
                            // the WidgetHost stays unsized, as upstream DankBar does.
                            Item {
                                Layout.preferredWidth: widgetHost.item ? widgetHost.item.width : 0
                                Layout.preferredHeight: 40

                                WidgetHost {
                                    id: widgetHost
                                    anchors.verticalCenter: parent.verticalCenter
                                    widgetId: memberWrapper.modelData.id
                                    widgetData: memberWrapper.modelData
                                    components: root.componentMap
                                    axis: root.axis
                                    section: "center"
                                    parentScreen: root.parentScreen
                                    widgetThickness: 30
                                    barThickness: 40
                                    barConfig: ({
                                        "noBackground": true,
                                        "widgetPadding": 0,
                                        "removeWidgetPadding": true,
                                        "widgetTransparency": 1.0,
                                        "widgetOutlineEnabled": false
                                    })
                                    // sectionSpacing stays 0 and every member is its own
                                    // WidgetHost instance, so isFirst/isLast being hardcoded
                                    // true on all of them is inert today - each behaves as
                                    // a standalone single-widget section either way.
                                    isFirst: true
                                    isLast: true
                                    sectionSpacing: 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
