import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skycast/models/weather.dart';
import 'package:skycast/providers/weather_provider.dart';
import 'package:skycast/screens/main_shell.dart';

void main() {
  test('weather conditions and wind directions are human readable', () {
    expect(weatherDescription(61), 'Rain');
    expect(weatherDescription(95), 'Thunderstorms');
    expect(windDirectionLabel(225), 'SW');
  });

  test('hourly forecast begins at the current local hour', () {
    final snapshot = WeatherSnapshot.fromJson(_apiPayload());

    expect(snapshot.hourly, hasLength(24));
    expect(snapshot.hourly.first.time, DateTime(2026, 11, 24, 15));
    expect(snapshot.precipitationProbability, 15);
  });

  testWidgets('dashboard renders live conditions and forecast navigation', (
    tester,
  ) async {
    final provider = WeatherProvider()
      ..weather = _sampleWeather()
      ..isLoading = false;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: MainShell()),
      ),
    );

    expect(find.text('SkyCast'), findsOneWidget);
    expect(find.text('San Francisco'), findsOneWidget);
    expect(find.text('Clear sky'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('7-day forecast'), findsOneWidget);
  });
}

Map<String, dynamic> _apiPayload() {
  final times = List.generate(
    48,
    (index) =>
        DateTime(2026, 11, 24).add(Duration(hours: index)).toIso8601String(),
  );
  return {
    'current': {
      'time': '2026-11-24T15:30',
      'temperature_2m': 18,
      'apparent_temperature': 17,
      'weather_code': 0,
      'is_day': 1,
      'relative_humidity_2m': 54,
      'wind_speed_10m': 12,
      'wind_direction_10m': 225,
      'uv_index': 2,
      'visibility': 10000,
      'surface_pressure': 1014,
      'cloud_cover': 4,
      'dew_point_2m': 8,
    },
    'hourly': {
      'time': times,
      'temperature_2m': List<double>.filled(48, 18),
      'weather_code': List<int>.filled(48, 0),
      'precipitation_probability': List<int>.generate(48, (index) => index),
    },
    'daily': {
      'time': ['2026-11-24'],
      'weather_code': [0],
      'temperature_2m_min': [12],
      'temperature_2m_max': [21],
      'precipitation_probability_max': [20],
      'sunrise': ['2026-11-24T06:42'],
      'sunset': ['2026-11-24T17:03'],
    },
  };
}

WeatherSnapshot _sampleWeather() {
  final today = DateTime(2026, 11, 24);
  return WeatherSnapshot(
    time: DateTime(2026, 11, 24, 10),
    temperature: 18,
    apparentTemperature: 17,
    weatherCode: 0,
    isDay: true,
    high: 21,
    low: 12,
    sunrise: DateTime(2026, 11, 24, 6, 42),
    sunset: DateTime(2026, 11, 24, 17, 3),
    humidity: 54,
    windSpeed: 12,
    windDirection: 225,
    uvIndex: 2,
    visibility: 10,
    pressure: 1014,
    cloudCover: 4,
    dewPoint: 8,
    precipitationProbability: 0,
    airQualityIndex: 32,
    hourly: List.generate(
      24,
      (index) => HourlyForecast(
        time: DateTime(2026, 11, 24, index),
        temperature: 18,
        weatherCode: 0,
        precipitationProbability: 0,
      ),
    ),
    daily: List.generate(
      7,
      (index) => DailyForecast(
        date: today.add(Duration(days: index)),
        weatherCode: 0,
        minimum: 12,
        maximum: 21,
        precipitationProbability: 0,
        sunrise: DateTime(2026, 11, 24, 6, 42),
        sunset: DateTime(2026, 11, 24, 17, 3),
      ),
    ),
  );
}
