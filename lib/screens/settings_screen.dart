import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              'Make SkyCast feel like yours.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 28),
            _sectionTitle(context, 'DISPLAY'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temperature units',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Celsius'),
                          icon: Icon(Icons.thermostat),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Fahrenheit'),
                          icon: Icon(Icons.device_thermostat),
                        ),
                      ],
                      selected: {provider.isCelsius},
                      onSelectionChanged: (value) =>
                          provider.setCelsius(value.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  provider.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: const Text('Dark appearance'),
                subtitle: const Text('Use a darker color palette'),
                value: provider.isDarkMode,
                onChanged: provider.setDarkMode,
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'WEATHER'),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Weather alerts'),
                subtitle: const Text(
                  'Show rain and storm advisories in the app',
                ),
                value: provider.alertsEnabled,
                onChanged: provider.setAlertsEnabled,
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'ABOUT'),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.cloud_outlined),
                    title: Text('Weather data'),
                    subtitle: Text('Open-Meteo forecast and air quality APIs'),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    color: Theme.of(context).dividerColor
                        .withValues(alpha: 0.4),
                  ),
                  const ListTile(
                    leading: Icon(Icons.info_outline_rounded),
                    title: Text('SkyCast'),
                    subtitle: Text('Weather at a glance, wherever you are.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}
