import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

BasePill {
    id: root

    property var widgetData: null

    signal cpuClicked

    Component.onCompleted: DgopService.addRef(["cpu"])
    Component.onDestruction: DgopService.removeRef(["cpu"])

    content: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "memory"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: {
                    if (DgopService.cpuUsage > 80)
                        return Theme.tempDanger;
                    if (DgopService.cpuUsage > 60)
                        return Theme.tempWarning;
                    return Theme.widgetIconColor;
                }
                anchors.verticalCenter: parent.verticalCenter
            }

            NumericText {
                isMonospace: false
                text: {
                    const v = DgopService.cpuUsage;
                    if (v === undefined || v === null || v === 0)
                        return "--%";
                    return v.toFixed(0) + "%";
                }
                reserveText: "100%"
                width: Math.ceil(Math.max(implicitWidth, reservedWidth))
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    MouseArea {
        x: -root.leftMargin
        y: -root.topMargin
        width: root.width + root.leftMargin + root.rightMargin
        height: root.height + root.topMargin + root.bottomMargin
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onPressed: mouse => {
            root.triggerRipple(this, mouse.x, mouse.y);
            DgopService.setSortBy("cpu");
            cpuClicked();
        }
    }
}
