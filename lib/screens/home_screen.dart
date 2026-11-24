import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../widgets/city_search_delegate.dart';
import '../widgets/weather_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final weather = provider.weather;
    if (provider.isLoading && weather == null) {
      return const WeatherLoadingSkeleton();
    }
    if (weather == null) {
      return _loadError(context, provider);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final content = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 36 : 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context, provider, weather),
              if (provider.error != null) _errorBanner(context, provider),
              if (provider.alertsEnabled && _hasWeatherAlert(weather))
                _weatherAlert(context, weather),
              const SizedBox(height: 22),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WeatherHero(
                            weather: weather,
                            city: provider.selectedCity,
                          ),
                          const SizedBox(height: 22),
                          const SectionHeading('Next 24 hours'),
                          const SizedBox(height: 12),
                          HourlyForecastStrip(items: weather.hourly),
                          const SizedBox(height: 22),
                          _sunCard(context, weather),
                        ],
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeading('Weather details'),
                          const SizedBox(height: 12),
                          _detailsGrid(context, weather),
                          const SizedBox(height: 22),
                          const SectionHeading('This week'),
                          const SizedBox(height: 12),
                          WeeklyForecastList(
                            items: weather.daily,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                WeatherHero(weather: weather, city: provider.selectedCity),
                const SizedBox(height: 22),
                const SectionHeading('Next 24 hours'),
                const SizedBox(height: 12),
                HourlyForecastStrip(items: weather.hourly),
                const SizedBox(height: 22),
                _sunCard(context, weather),
                const SizedBox(height: 22),
                const SectionHeading('Weather details'),
                const SizedBox(height: 12),
                _detailsGrid(context, weather),
                const SizedBox(height: 22),
                const SectionHeading('This week'),
                const SizedBox(height: 12),
                WeeklyForecastList(items: weather.daily, compact: true),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
        return _scroll(content);
      },
    );
  }

  Widget _scroll(Widget child) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: child,
      ),
    ),
  );

  Widget _topBar(
    BuildContext context,
    WeatherProvider provider,
    WeatherSnapshot weather,
  ) {
    final time = weather.time;
    final date =
        '${_weekday(time.weekday)}, ${_month(time.month)} ${time.day} · ${_clock(time)}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SkyCast',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Search city',
          onPressed: () => showSearch<CityLocation?>(
            context: context,
            delegate: CitySearchDelegate(provider),
          ),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'Use current location',
          onPressed: provider.isRefreshing ? null : provider.useCurrentLocation,
          icon: provider.isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded),
        ),
        IconButton(
          tooltip: provider.isFavorite(provider.selectedCity)
              ? 'Remove saved location'
              : 'Save location',
          onPressed: () => provider.toggleFavorite(provider.selectedCity),
          icon: Icon(
            provider.isFavorite(provider.selectedCity)
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Refresh weather',
          onPressed: provider.isRefreshing
              ? null
              : () => provider.loadWeather(refresh: true),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _detailsGrid(BuildContext context, WeatherSnapshot weather) {
    final items = [
      WeatherMetricCard(
        title: 'Humidity',
        value: '${weather.humidity}%',
        icon: Icons.water_drop_outlined,
        caption: 'Relative humidity',
      ),
      WeatherMetricCard(
        title: 'Wind',
        value:
            '${context.read<WeatherProvider>().windSpeed(weather.windSpeed)} ${weather.windCardinal}',
        icon: Icons.air_rounded,
        caption: 'Wind direction',
      ),
      WeatherMetricCard(
        title: 'UV index',
        value: weather.uvIndex.toStringAsFixed(1),
        icon: Icons.wb_sunny_outlined,
        caption: _uvLabel(weather.uvIndex),
      ),
      WeatherMetricCard(
        title: 'Visibility',
        value: '${weather.visibility.toStringAsFixed(1)} km',
        icon: Icons.visibility_outlined,
        caption: 'Horizontal range',
      ),
      WeatherMetricCard(
        title: 'Pressure',
        value: '${weather.pressure.round()} hPa',
        icon: Icons.speed_rounded,
        caption: 'Sea-level pressure',
      ),
      WeatherMetricCard(
        title: 'Cloud cover',
        value: '${weather.cloudCover}%',
        icon: Icons.cloud_outlined,
        caption: 'Sky coverage',
      ),
      WeatherMetricCard(
        title: 'Dew point',
        value: context.read<WeatherProvider>().temperature(weather.dewPoint),
        icon: Icons.thermostat_outlined,
        caption: 'Moisture in air',
      ),
      WeatherMetricCard(
        title: 'Air quality',
        value: weather.airQualityIndex?.toString() ?? '—',
        icon: Icons.air_rounded,
        caption: weather.airQualityIndex == null
            ? 'AQI unavailable'
            : _aqiLabel(weather.airQualityIndex!),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        crossAxisCount: constraints.maxWidth > 520 ? 2 : 2,
        childAspectRatio: constraints.maxWidth > 520 ? 1.7 : 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items,
      ),
    );
  }

  Widget _sunCard(BuildContext context, WeatherSnapshot weather) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: _sunTime(
              context,
              Icons.wb_twilight_rounded,
              'Sunrise',
              weather.sunrise,
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: _sunTime(
              context,
              Icons.wb_twilight_rounded,
              'Sunset',
              weather.sunset,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sunTime(
    BuildContext context,
    IconData icon,
    String label,
    DateTime time,
  ) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          Text(
            '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ],
  );

  Widget _loadError(BuildContext context, WeatherProvider provider) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 46),
          const SizedBox(height: 12),
          Text(
            provider.error ?? 'Weather is taking a moment to load.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => provider.loadWeather(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );

  Widget _errorBanner(BuildContext context, WeatherProvider provider) =>
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Material(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.cloud_off_outlined),
            title: Text(provider.error!),
            trailing: IconButton(
              tooltip: 'Retry',
              onPressed: () => provider.loadWeather(refresh: true),
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
      );

  Widget _weatherAlert(
    BuildContext context,
    WeatherSnapshot weather,
  ) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6D8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF98502F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              weather.weatherCode >= 95
                  ? 'Thunderstorms nearby. Check conditions before heading out.'
                  : 'Rain may arrive soon. ${weather.precipitationProbability}% chance in the current hour.',
              style: const TextStyle(color: Color(0xFF6D3E2A), fontSize: 13),
            ),
          ),
        ],
      ),
    ),
  );

  bool _hasWeatherAlert(WeatherSnapshot weather) =>
      weather.weatherCode >= 95 || weather.precipitationProbability >= 60;
  String _weekday(int day) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][day - 1];
  String _month(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
  String _clock(DateTime time) =>
      '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}';
  String _uvLabel(double value) => value < 3
      ? 'Low'
      : value < 6
      ? 'Moderate'
      : value < 8
      ? 'High'
      : 'Very high';
  String _aqiLabel(int value) => value <= 50
      ? 'Good'
      : value <= 100
      ? 'Moderate'
      : 'Elevated';
}
