import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

PanelWindow {
    id: win

    // screen: inherited from PanelWindow (WindowInterface.screen), don't redeclare
    color: "transparent"
    anchors { top: true; left: true; right: true }
    implicitHeight: 70

    property bool autohidden: false
    visible: !autohidden
    exclusiveZone: autohidden ? 0 : (12 + 40 + 2)

    function toggleAutohide(): void { win.autohidden = !win.autohidden }

    // Hiding this window (autohide) can leave a loaded widget's own
    // `visible` stuck false when the window reappears, collapsing the pill
    // even though the widget's content never changed. Re-evaluate it once
    // we're visible again.
    onVisibleChanged: if (win.visible) pillRow.relayoutGroups()

    IpcHandler {
        target: "topbar"
        function toggle(): void { win.toggleAutohide() }
    }

    IpcHandler {
        target: "thememenu"
        function toggle(): void {
            SessionData.setLightMode(!SessionData.isLightMode);
        }
    }

    IpcHandler {
        target: "panel"
        function toggle(): void {
            win.togglePanels();
        }
    }

    mask: Region { item: pillRow }

    property alias controlCenterButtonRef: pillRow
    property alias clockButtonRef: pillRow

    function triggerControlCenter() {
        const loader = PopoutService.controlCenterLoader;
        if (!loader)
            return;
        loader.active = true;
        if (!loader.item)
            return;
        loader.item.triggerScreen = win.screen;
        loader.item.triggerX = win.screen.width;
        loader.item.toggle();
    }

    function triggerDashTab(tabId, position) {
        const loader = PopoutService.dankDashPopoutLoader;
        if (!loader)
            return false;
        loader.active = true;
        if (!loader.item)
            return false;
        loader.item.triggerScreen = win.screen;
        loader.item.triggerX = 0;
        if (loader.item.requestTab)
            loader.item.requestTab(tabId);
        PopoutManager.requestPopout(loader.item, undefined, "topbar-" + tabId);
        return true;
    }

    function triggerWallpaperBrowser() {
        triggerDashTab("wallpaper");
    }

    function togglePanels() {
        const dashOpen = PopoutService.dankDashPopoutLoader?.item?.dashVisible ?? false;
        if (dashOpen) {
            PopoutService.dankDashPopoutLoader.item.dashVisible = false;
            if (PopoutService.controlCenterLoader?.item?.shouldBeVisible)
                PopoutService.controlCenterLoader.item.close();
        } else {
            triggerDashTab("overview");
            if (!(PopoutService.controlCenterLoader?.item?.shouldBeVisible ?? false))
                triggerControlCenter();
        }
    }

    TopBarPillRow {
        id: pillRow
        y: 12
        anchors.horizontalCenter: parent.horizontalCenter
        parentScreen: win.screen
        axis: QtObject { readonly property bool isVertical: false; readonly property string edge: "top" }
    }
}
