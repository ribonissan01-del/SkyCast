import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _radarPath;
  bool _radarEnabled = true;
  bool _radarUnavailable = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _radarUnavailable = true;
    } else {
      _loadRadar();
    }
  }

  Future<void> _loadRadar() async {
    try {
      final response = await http
          .get(Uri.https('api.rainviewer.com', '/public/weather-maps.json'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw const FormatException();
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final radar = json['radar'] as Map<String, dynamic>?;
      final past = radar?['past'] as List?;
      if (past == null || past.isEmpty) throw const FormatException();
      final frame = past.last as Map<String, dynamic>;
      if (mounted) setState(() => _radarPath = frame['path'] as String?);
    } catch (_) {
      if (mounted) setState(() => _radarUnavailable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final city = provider.selectedCity;
    final weather = provider.weather;
    final center = LatLng(city.latitude, city.longitude);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weather map',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${city.name} · Live radar',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
              FilterChip(
                label: Text(kIsWeb ? 'Radar on mobile' : 'Rain radar'),
                selected: _radarEnabled,
                avatar: const Icon(Icons.water_drop_outlined, size: 17),
                onSelected: kIsWeb
                    ? null
                    : (value) => setState(() => _radarEnabled = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 8,
                  minZoom: 2,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.skycast',
                    maxZoom: 19,
                  ),
                  if (!kIsWeb && _radarEnabled && _radarPath != null)
                    Opacity(
                      opacity: 0.55,
                      child: TileLayer(
                        urlTemplate:
                            'https://tilecache.rainviewer.com$_radarPath/256/{z}/{x}/{y}/2/1_1.png',
                        userAgentPackageName: 'com.example.skycast',
                        maxNativeZoom: 6,
                        maxZoom: 18,
                      ),
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 180,
                        height: 92,
                        alignment: Alignment.topCenter,
                        child: _weatherMarker(context, city, weather),
                      ),
                      for (final favorite in provider.favorites)
                        if (favorite.latitude != city.latitude ||
                            favorite.longitude != city.longitude)
                          Marker(
                            point: LatLng(
                              favorite.latitude,
                              favorite.longitude,
                            ),
                            width: 38,
                            height: 38,
                            child: Tooltip(
                              message: favorite.name,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFEB7959),
                                size: 34,
                              ),
                            ),
                          ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                      if (!kIsWeb)
                        TextSourceAttribution('Radar data © RainViewer'),
                    ],
                  ),
                ],
              ),
              if (weather != null && isWide)
                Positioned(
                  right: 18,
                  top: 18,
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface
                          .withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          provider.temperature(weather.temperature),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(weather.condition),
                        const SizedBox(height: 12),
                        Text(
                          'Rain chance  ${weather.precipitationProbability}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Wind  ${provider.windSpeed(weather.windSpeed)} ${weather.windCardinal}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              if (_radarUnavailable && _radarEnabled)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface
                        .withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        kIsWeb
                            ? 'Live radar tiles are unavailable in web browsers. The base map remains active.'
                            : 'Radar overlay is temporarily unavailable. The base map is still active.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weatherMarker(
    BuildContext context,
    CityLocation city,
    dynamic weather,
  ) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (weather != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Text(
            '${context.read<WeatherProvider>().temperature(weather.temperature)} · ${weather.condition}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      const Icon(Icons.location_on_rounded, color: Color(0xFFEB7959), size: 34),
    ],
  );
}
