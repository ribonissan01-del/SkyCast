import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../widgets/city_search_delegate.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                          'Saved places',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your weather, wherever you go.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Search cities',
                    onPressed: () => showSearch<CityLocation?>(
                      context: context,
                      delegate: CitySearchDelegate(provider),
                    ),
                    icon: const Icon(Icons.add_location_alt_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'CURRENT LOCATION',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 9),
              _locationTile(
                context,
                provider,
                provider.selectedCity,
                isCurrent: true,
              ),
              const SizedBox(height: 22),
              Text(
                'FAVORITES',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 9),
              Expanded(
                child: provider.favorites.isEmpty
                    ? _emptyState(context, provider)
                    : ListView.separated(
                        itemCount: provider.favorites.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _locationTile(
                          context,
                          provider,
                          provider.favorites[index],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationTile(
    BuildContext context,
    WeatherProvider provider,
    CityLocation city, {
    bool isCurrent = false,
  }) {
    final isSelected =
        city.latitude == provider.selectedCity.latitude &&
        city.longitude == provider.selectedCity.longitude;
    final isCurrentCity = isCurrent && city.name == 'My location';
    return Card(
      child: ListTile(
        onTap: () => provider.selectCity(city),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: 0.1),
          child: Icon(
            isCurrentCity
                ? Icons.my_location_rounded
                : Icons.location_on_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          city.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          isCurrentCity
              ? 'Live GPS location'
              : city.label == city.name
              ? city.country
              : '${city.label}, ${city.country}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4E9A83)),
            if (!isCurrent)
              IconButton(
                tooltip: 'Remove saved location',
                onPressed: () => provider.toggleFavorite(city),
                icon: const Icon(Icons.close_rounded),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, WeatherProvider provider) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bookmark_border_rounded,
          size: 38,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(height: 10),
        const Text(
          'No saved places yet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          'Search for a city and tap the bookmark to keep it here.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showSearch<CityLocation?>(
            context: context,
            delegate: CitySearchDelegate(provider),
          ),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Find a city'),
        ),
      ],
    ),
  );
}
