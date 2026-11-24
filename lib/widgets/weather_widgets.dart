import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';

IconData weatherIcon(int code, {bool isDay = true}) => switch (code) {
  0 when !isDay => Icons.nightlight_round,
  0 || 1 => Icons.wb_sunny_rounded,
  2 => Icons.cloud_queue_rounded,
  3 || 45 || 48 => Icons.cloud_rounded,
  51 ||
  53 ||
  55 ||
  56 ||
  57 ||
  61 ||
  63 ||
  65 ||
  66 ||
  67 ||
  80 ||
  81 ||
  82 => Icons.grain_rounded,
  71 || 73 || 75 || 77 || 85 || 86 => Icons.ac_unit_rounded,
  95 || 96 || 99 => Icons.thunderstorm_rounded,
  _ => Icons.cloud_queue_rounded,
};

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      ?trailing,
    ],
  );
}

class WeatherHero extends StatelessWidget {
  const WeatherHero({super.key, required this.weather, required this.city});

  final WeatherSnapshot weather;
  final CityLocation city;

  List<Color> get _colors {
    if (weather.weatherCode >= 95) {
      return const [Color(0xFF315467), Color(0xFF528587)];
    }
    if (weather.weatherCode >= 51 && weather.weatherCode <= 82) {
      return const [Color(0xFF3D677A), Color(0xFF77AFAE)];
    }
    if (weather.weatherCode >= 71 && weather.weatherCode <= 86) {
      return const [Color(0xFF66889B), Color(0xFFB7CFCC)];
    }
    if (weather.weatherCode >= 2 && weather.weatherCode <= 48) {
      return const [Color(0xFF547B87), Color(0xFFA8C5BC)];
    }
    return const [Color(0xFFE88B62), Color(0xFFF2C27D)];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final colors = _colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      city.country,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(
                weatherIcon(weather.weatherCode, isDay: weather.isDay),
                color: Colors.white.withValues(alpha: 0.95),
                size: 46,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    provider.temperature(weather.temperature),
                    key: ValueKey(
                      '${weather.temperature}-${provider.isCelsius}',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 66,
                      height: 1,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              Text(
                weather.condition,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Feels like ${provider.temperature(weather.apparentTemperature)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 19),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  context,
                  Icons.arrow_upward_rounded,
                  'High',
                  provider.temperature(weather.high),
                ),
              ),
              Expanded(
                child: _heroStat(
                  context,
                  Icons.arrow_downward_rounded,
                  'Low',
                  provider.temperature(weather.low),
                ),
              ),
              Expanded(
                child: _heroStat(
                  context,
                  Icons.water_drop_outlined,
                  'Rain',
                  '${weather.precipitationProbability}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Row(
    children: [
      Icon(icon, size: 17, color: Colors.white70),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  );
}

class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({super.key, required this.items});

  final List<HourlyForecast> items;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    return Card(
      child: SizedBox(
        height: 150,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            final hour = item.time.hour;
            return SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    index == 0
                        ? 'Now'
                        : '${hour % 12 == 0 ? 12 : hour % 12}${hour < 12 ? 'a' : 'p'}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Icon(
                    weatherIcon(item.weatherCode, isDay: hour > 6 && hour < 19),
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  Text(
                    provider.temperature(item.temperature),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${item.precipitationProbability}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class WeeklyForecastList extends StatelessWidget {
  const WeeklyForecastList({
    super.key,
    required this.items,
    this.compact = false,
  });

  final List<DailyForecast> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final shown = compact ? items.take(5).toList() : items;
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < shown.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      index == 0 ? 'Today' : _weekday(shown[index].date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    weatherIcon(shown[index].weatherCode),
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  if (!compact)
                    Expanded(
                      child: Text(
                        weatherDescription(shown[index].weatherCode),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (shown[index].precipitationProbability > 0) ...[
                    const Icon(
                      Icons.water_drop_rounded,
                      size: 12,
                      color: Color(0xFF4A9DAD),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${shown[index].precipitationProbability}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4A9DAD),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  const Spacer(),
                  Text(
                    provider.temperature(shown[index].minimum),
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 38,
                    child: Text(
                      provider.temperature(shown[index].maximum),
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WeatherMetricCard extends StatelessWidget {
  const WeatherMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.caption,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? caption;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(letterSpacing: 0, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
        ],
      ),
    ),
  );
}

class WeatherLoadingSkeleton extends StatelessWidget {
  const WeatherLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.07);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 130,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 145,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              4,
              (_) => Container(
                width: 145,
                height: 104,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _weekday(DateTime date) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
