import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services

PluginComponent {
    id: root

    visible: SettingsData.weatherEnabled

    Component.onCompleted: WeatherService.addRef()
    Component.onDestruction: WeatherService.removeRef()

    horizontalBarPill: Component {
        RowLayout {
            spacing: 6

            DankIcon {
                name: WeatherService.getWeatherIcon(WeatherService.weather.wCode, WeatherService.weather.isDay)
                size: 15
                color: Theme.primary
            }

            StyledText {
                text: WeatherService.weather.available
                    ? (SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp) + "°"
                    : "--°"
                color: Theme.primary
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 13
            }
        }
    }
}
