import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../widgets/weather_widgets.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final weather = provider.weather;
    if (weather == null) return const WeatherLoadingSkeleton();
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forecast',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.selectedCity.name}  ·  ${weather.condition}',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 26),
                const SectionHeading('Hourly outlook'),
                const SizedBox(height: 12),
                HourlyForecastStrip(items: weather.hourly),
                const SizedBox(height: 10),
                Text(
                  'Rain probability is shown beneath each hour.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 28),
                const SectionHeading('7-day forecast'),
                const SizedBox(height: 12),
                WeeklyForecastList(items: weather.daily),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
