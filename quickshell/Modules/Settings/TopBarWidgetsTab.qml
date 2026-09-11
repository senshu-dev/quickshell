import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Settings.Widgets

Item {
    id: root

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    property var parentModal: null

    readonly property var widgets: SettingsData.topBarWidgets || []

    readonly property var installablePlugins: PluginService.getAllPluginVariants()

    function moveEntry(index, delta) {
        const list = root.widgets.slice();
        const target = index + delta;
        if (target < 0 || target >= list.length)
            return;
        [list[index], list[target]] = [list[target], list[index]];
        SettingsData.setTopBarWidgets(list);
    }

    function setEnabled(index, enabled) {
        const list = root.widgets.slice();
        list[index] = Object.assign({}, list[index], {
            enabled: enabled
        });
        SettingsData.setTopBarWidgets(list);
    }

    function setJoinsPrevious(index, joins) {
        const list = root.widgets.slice();
        list[index] = Object.assign({}, list[index], {
            joinsPrevious: joins
        });
        SettingsData.setTopBarWidgets(list);
    }

    function removeEntry(index) {
        const list = root.widgets.slice();
        list.splice(index, 1);
        SettingsData.setTopBarWidgets(list);
    }

    function addWidget(widgetId) {
        if (!widgetId || root.widgets.some(w => w.id === widgetId))
            return;
        const list = root.widgets.slice();
        list.push({
            id: widgetId,
            enabled: true,
            joinsPrevious: false
        });
        SettingsData.setTopBarWidgets(list);
    }

    function showPluginBrowser() {
        pluginBrowserLoader.active = true;
        if (pluginBrowserLoader.item)
            pluginBrowserLoader.item.show();
    }

    LazyLoader {
        id: pluginBrowserLoader
        active: false

        PluginBrowser {
            parentModal: root.parentModal
        }
    }

    focus: true

    DankFlickable {
        anchors.fill: parent
        clip: true
        contentHeight: mainColumn.height + Theme.spacingXL
        contentWidth: width

        Column {
            id: mainColumn
            topPadding: 4
            width: Math.min(550, parent.width - Theme.spacingL * 2)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingXL

            SettingsCard {
                settingKey: "topBarWidgets"
                tags: ["topbar", "widgets", "plugins", "clock", "weather", "pill"]
                width: parent.width
                iconName: "view_agenda"
                title: I18n.tr("Top Bar Widgets")

                Column {
                    width: parent.width - Theme.spacingM * 2
                    x: Theme.spacingM
                    spacing: Theme.spacingM

                    StyledText {
                        width: parent.width
                        text: I18n.tr("Enable, reorder, and group the widgets shown in the top bar. Widgets marked \"joins previous\" share a pill with the widget above them.")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS

                        Repeater {
                            id: widgetRepeater
                            model: root.widgets

                            Rectangle {
                                id: entryRow
                                required property var modelData
                                required property int index

                                width: parent.width
                                height: 44
                                radius: Theme.cornerRadius
                                color: Theme.floatingWindowFieldColor

                                Row {
                                    anchors.left: parent.left
                                    anchors.right: entryActions.left
                                    anchors.leftMargin: Theme.spacingS
                                    anchors.rightMargin: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingS

                                    DankToggle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        checked: entryRow.modelData.enabled !== false
                                        onToggled: checked => root.setEnabled(entryRow.index, checked)
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entryRow.modelData.id
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Theme.surfaceText
                                        width: 150
                                        elide: Text.ElideRight
                                    }

                                    DankToggle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        checked: entryRow.modelData.joinsPrevious === true
                                        onToggled: checked => root.setJoinsPrevious(entryRow.index, checked)
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: I18n.tr("Joins previous")
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }

                                Row {
                                    id: entryActions
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingXXS

                                    DankActionButton {
                                        iconName: "arrow_upward"
                                        iconSize: 16
                                        buttonSize: 28
                                        enabled: entryRow.index > 0
                                        onClicked: root.moveEntry(entryRow.index, -1)
                                    }

                                    DankActionButton {
                                        iconName: "arrow_downward"
                                        iconSize: 16
                                        buttonSize: 28
                                        enabled: entryRow.index < widgetRepeater.count - 1
                                        onClicked: root.moveEntry(entryRow.index, 1)
                                    }

                                    DankActionButton {
                                        iconName: "delete"
                                        iconSize: 16
                                        buttonSize: 28
                                        iconColor: Theme.error
                                        onClicked: root.removeEntry(entryRow.index)
                                    }
                                }
                            }
                        }

                        StyledText {
                            width: parent.width
                            visible: root.widgets.length === 0
                            text: I18n.tr("No widgets configured")
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }
                }
            }

            SettingsCard {
                tags: ["topbar", "plugins", "browse", "add"]
                width: parent.width
                iconName: "store"
                title: I18n.tr("Add a Plugin Widget")

                Column {
                    width: parent.width - Theme.spacingM * 2
                    x: Theme.spacingM
                    spacing: Theme.spacingM

                    StyledText {
                        width: parent.width
                        text: I18n.tr("Browse and install plugins, then add an installed widget plugin to the top bar below.")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                    }

                    DankButton {
                        text: I18n.tr("Browse Plugins")
                        iconName: "store"
                        onClicked: root.showPluginBrowser()
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: root.installablePlugins.length > 0

                        Repeater {
                            model: root.installablePlugins

                            Rectangle {
                                id: pluginRow
                                required property var modelData

                                width: parent.width
                                height: 40
                                radius: Theme.cornerRadius
                                color: Theme.floatingWindowFieldColor

                                Row {
                                    anchors.left: parent.left
                                    anchors.right: addPluginBtn.left
                                    anchors.leftMargin: Theme.spacingS
                                    anchors.rightMargin: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingS

                                    DankIcon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: pluginRow.modelData.icon || "extension"
                                        size: Theme.iconSizeSmall
                                        color: Theme.primary
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - Theme.iconSizeSmall - Theme.spacingS
                                        spacing: 0

                                        StyledText {
                                            width: parent.width
                                            text: pluginRow.modelData.name
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceText
                                            elide: Text.ElideRight
                                        }

                                        StyledText {
                                            width: parent.width
                                            visible: !pluginRow.modelData.loaded
                                            text: I18n.tr("Plugin is disabled - enable in Plugins settings to use")
                                            font.pixelSize: Theme.fontSizeSmall - 1
                                            color: Theme.warning
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                DankActionButton {
                                    id: addPluginBtn
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter
                                    iconName: "add"
                                    iconSize: 16
                                    buttonSize: 28
                                    enabled: pluginRow.modelData.loaded && !root.widgets.some(w => w.id === pluginRow.modelData.fullId)
                                    onClicked: root.addWidget(pluginRow.modelData.fullId)
                                }
                            }
                        }
                    }

                    StyledText {
                        width: parent.width
                        visible: root.installablePlugins.length === 0
                        text: I18n.tr("No plugins with a widget surface are installed yet")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }
            }
        }
    }
}
