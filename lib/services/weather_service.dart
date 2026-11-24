import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherSnapshot> fetchWeather(CityLocation city) async {
    final forecastUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${city.latitude}',
      'longitude': '${city.longitude}',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m,uv_index,visibility,dew_point_2m',
      'hourly': 'temperature_2m,precipitation_probability,weather_code',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset',
      'forecast_days': '7',
      'timezone': 'auto',
    });
    final airQualityUri = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      {
        'latitude': '${city.latitude}',
        'longitude': '${city.longitude}',
        'current': 'us_aqi',
        'timezone': 'auto',
      },
    );
    final responses = await Future.wait([
      _get(forecastUri),
      _get(airQualityUri).catchError((_) => <String, dynamic>{}),
    ]);
    final aqi = (responses[1]['current'] as Map<String, dynamic>?)?['us_aqi'];
    return WeatherSnapshot.fromJson(
      responses[0],
      airQualityIndex: aqi is num ? aqi.round() : null,
    );
  }

  Future<List<CityLocation>> searchCities(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw const WeatherException('City search is unavailable right now.');
    }
    final results =
        (jsonDecode(response.body) as Map<String, dynamic>)['results'];
    if (results is! List) return const [];
    return results.map((item) {
      final result = item as Map<String, dynamic>;
      return CityLocation(
        name: result['name'] as String? ?? 'Unknown city',
        country: result['country'] as String? ?? '',
        admin1: result['admin1'] as String? ?? '',
        latitude: (result['latitude'] as num).toDouble(),
        longitude: (result['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  Future<CityLocation> reverseGeocode(double latitude, double longitude) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '$latitude',
      'lon': '$longitude',
      'format': 'jsonv2',
      'zoom': '10',
      'addressdetails': '1',
      'accept-language': 'en',
    });
    final response = await _client
        .get(uri, headers: const {'User-Agent': 'SkyCast/1.0 (weather app)'})
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw const WeatherException('Location name is unavailable.');
    }
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    final address = result['address'] as Map<String, dynamic>? ?? {};
    final name =
        address['city'] ??
        address['town'] ??
        address['village'] ??
        address['municipality'] ??
        address['county'];
    if (name is! String || name.isEmpty) {
      throw const WeatherException('Location name is unavailable.');
    }
    return CityLocation(
      name: name,
      country: address['country'] as String? ?? '',
      admin1: address['state'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 14));
    if (response.statusCode != 200) {
      throw const WeatherException(
        'Weather data could not be loaded. Please try again.',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}
