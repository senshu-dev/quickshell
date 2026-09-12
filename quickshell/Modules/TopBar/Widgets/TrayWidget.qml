import QtQuick
import QtQuick.Window
import Quickshell.Services.SystemTray
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

BasePill {
    id: root

    enableBackgroundHover: false
    enableCursor: false

    property var widgetData: null

    content: Component {
        // ponytail: no overflow popup / drag-reorder like stock DankBar's
        // SystemTrayBar - all icons render inline, pill just grows. Fine at
        // a handful of tray items; revisit if it ever overflows the bar.
        Row {
            spacing: Theme.spacingS

            Repeater {
                model: SystemTray.items.values

                Item {
                    id: trayIcon
                    required property var modelData
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.fill: parent
                        source: trayIcon.modelData.icon
                        sourceSize: Qt.size(18, 18)
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton || trayIcon.modelData.hasMenu)
                                trayIcon.modelData.display(trayIcon.Window.window, mouse.x, mouse.y);
                            else
                                trayIcon.modelData.activate();
                        }
                    }
                }
            }

            StyledText {
                visible: SystemTray.items.values.length === 0
                text: I18n.tr("No tray items")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
