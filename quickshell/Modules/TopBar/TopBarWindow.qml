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
        if (loader.item.requestTab)
            loader.item.requestTab(tabId);
        PopoutManager.requestPopout(loader.item, undefined, "topbar-" + tabId);
        return true;
    }

    function triggerWallpaperBrowser() {
        triggerDashTab("wallpaper");
    }

    TopBarPillRow {
        id: pillRow
        y: 12
        anchors.horizontalCenter: parent.horizontalCenter
        parentScreen: win.screen
        axis: QtObject { readonly property bool isVertical: false; readonly property string edge: "top" }
    }
}
