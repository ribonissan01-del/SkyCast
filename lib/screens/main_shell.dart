import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import 'forecast_screen.dart';
import 'home_screen.dart';
import 'locations_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _destinations = [
    (
      label: 'Today',
      shortLabel: 'Today',
      icon: Icons.wb_cloudy_outlined,
      selected: Icons.wb_cloudy_rounded,
    ),
    (
      label: 'Forecast',
      shortLabel: 'Forecast',
      icon: Icons.calendar_month_outlined,
      selected: Icons.calendar_month_rounded,
    ),
    (
      label: 'Weather map',
      shortLabel: 'Map',
      icon: Icons.map_outlined,
      selected: Icons.map_rounded,
    ),
    (
      label: 'Saved places',
      shortLabel: 'Saved',
      icon: Icons.bookmark_border_rounded,
      selected: Icons.bookmark_rounded,
    ),
    (
      label: 'Settings',
      shortLabel: 'Settings',
      icon: Icons.tune_rounded,
      selected: Icons.tune_rounded,
    ),
  ];

  static const _pages = [
    HomeScreen(),
    ForecastScreen(),
    MapScreen(),
    LocationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = context.select<WeatherProvider, int>(
      (provider) => provider.selectedTab,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scaffold(
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: selected,
                  onDestinationSelected: context.read<WeatherProvider>().setTab,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  destinations: [
                    for (final item in _destinations)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selected),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  child: KeyedSubtree(
                    key: ValueKey(selected),
                    child: _pages[selected],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: context.read<WeatherProvider>().setTab,
                  destinations: [
                    for (final item in _destinations)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selected),
                        label: item.shortLabel,
                      ),
                  ],
                ),
        );
      },
    );
  }
}
