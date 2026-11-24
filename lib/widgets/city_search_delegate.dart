import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';

class CitySearchDelegate extends SearchDelegate<CityLocation?> {
  CitySearchDelegate(this.provider);

  final WeatherProvider provider;
  Future<List<CityLocation>>? _search;
  String _lastQuery = '';

  @override
  String get searchFieldLabel => 'Search cities worldwide';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Clear search',
        onPressed: () {
          query = '';
          _search = null;
          showSuggestions(context);
        },
        icon: const Icon(Icons.close),
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Back',
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final value = query.trim();
    if (value.length < 2) {
      return const Center(
        child: Text('Enter at least two characters to search.'),
      );
    }
    if (value != _lastQuery) {
      _lastQuery = value;
      _search = provider.searchCities(value);
    }
    return FutureBuilder<List<CityLocation>>(
      future: _search,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Could not search right now. Check your connection and try again.',
            ),
          );
        }
        final cities = snapshot.data ?? const [];
        if (cities.isEmpty) {
          return const Center(
            child: Text('No cities found. Try another spelling.'),
          );
        }
        return ListView.separated(
          itemCount: cities.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final city = cities[index];
            return ListTile(
              leading: const Icon(Icons.location_city_rounded),
              title: Text(city.name),
              subtitle: Text(
                [
                  city.admin1,
                  city.country,
                ].where((part) => part.isNotEmpty).join(', '),
              ),
              onTap: () async {
                await provider.selectCity(city);
                if (context.mounted) close(context, city);
              },
            );
          },
        );
      },
    );
  }
}
