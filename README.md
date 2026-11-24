# SkyCast

SkyCast is a responsive Flutter weather app for Android and the web. It uses
Open-Meteo for forecasts, city search, and air-quality data, and RainViewer for
the optional radar layer. No API key is required.

## Run

Install Flutter 3.47 or later, then run:

```powershell
flutter pub get
flutter run
```

To launch the web version in Chrome:

```powershell
flutter run -d chrome
```

Android location access is requested at runtime. If permission is declined or
unavailable, SkyCast loads San Francisco and still supports city search.

## Features

- Current conditions, apparent temperature, daily high/low, sunrise and sunset.
- Scrolling 24-hour outlook and 7-day forecast with precipitation probability.
- Humidity, wind, UV, visibility, pressure, cloud cover, dew point, and AQI.
- Worldwide city search, GPS refresh, and locally saved favorite locations.
- Celsius/Fahrenheit conversion and persistent light/dark appearance settings.
- OpenStreetMap view with RainViewer radar on Android; web uses the base map because radar tiles block browser CORS.
- Responsive phone navigation and a split dashboard/navigation rail on wide screens.
- Loading placeholders, retry states, and threshold-based in-app rain/storm advisories.

Weather advisories are generated from forecast conditions and appear in the app;
they are not official emergency alerts or operating-system push notifications.
OpenStreetMap and RainViewer data are subject to their respective service terms.
GPS coordinates are reverse-geocoded through OpenStreetMap Nominatim; if that
lookup is unavailable, the app continues to show a generic current-location label.

## Project layout

```text
lib/
	models/       Weather and location models
	providers/    Shared app state and preferences
	screens/      Dashboard, forecast, map, locations, and settings
	services/     Open-Meteo API integration
	themes/       Light and dark Material themes
	widgets/      Reusable forecast and search widgets
```

Run checks with `flutter analyze` and `flutter test`.