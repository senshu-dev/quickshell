import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    horizontalBarPill: Component {
        Column {
            spacing: 0

            SystemClock {
                id: systemClock
                enabled: true
                precision: SystemClock.Minutes
            }

            StyledText {
                text: SettingsData.use24HourClock
                    ? (systemClock.date ? Qt.formatTime(systemClock.date, "HH:mm") : "--:--")
                    : (systemClock.date ? Qt.formatTime(systemClock.date, "h:mm AP") : "--:--")
                color: Theme.surfaceText
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 13
            }

            StyledText {
                text: systemClock.date
                    ? systemClock.date.toLocaleDateString(Qt.locale("en_US"), "dddd, MMM d")
                    : "--"
                color: Theme.surfaceTextMedium
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }
        }
    }
}
