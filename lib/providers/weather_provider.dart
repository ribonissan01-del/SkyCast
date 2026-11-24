import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherService? service})
    : _service = service ?? WeatherService();

  final WeatherService _service;
  static const _defaultCity = CityLocation(
    name: 'San Francisco',
    country: 'United States',
    admin1: 'California',
    latitude: 37.7749,
    longitude: -122.4194,
  );

  WeatherSnapshot? weather;
  CityLocation selectedCity = _defaultCity;
  List<CityLocation> favorites = [];
  bool isLoading = true;
  bool isRefreshing = false;
  bool isCelsius = true;
  bool isDarkMode = false;
  bool alertsEnabled = true;
  String? error;
  int selectedTab = 0;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    isCelsius = preferences.getBool('isCelsius') ?? true;
    isDarkMode = preferences.getBool('isDarkMode') ?? false;
    alertsEnabled = preferences.getBool('alertsEnabled') ?? true;
    final savedCity = preferences.getString('selectedCity');
    if (savedCity != null) {
      try {
        selectedCity = CityLocation.fromJson(
          jsonDecode(savedCity) as Map<String, dynamic>,
        );
      } on FormatException {
        selectedCity = _defaultCity;
      }
    }
    final savedFavorites = preferences.getStringList('favorites') ?? [];
    favorites = savedFavorites
        .map((item) {
          try {
            return CityLocation.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } on FormatException {
            return null;
          }
        })
        .whereType<CityLocation>()
        .toList();
    if (savedCity == null) {
      final location = await _tryCurrentLocation();
      if (location != null) selectedCity = location;
    }
    await loadWeather();
  }

  Future<CityLocation?> _tryCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      final fallback = CityLocation(
        name: 'My location',
        country: 'Current position',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      try {
        return await _service.reverseGeocode(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        return fallback;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> loadWeather({bool refresh = false}) async {
    isLoading = weather == null;
    isRefreshing = refresh;
    error = null;
    notifyListeners();
    try {
      weather = await _service.fetchWeather(selectedCity);
      await _saveSelectedCity();
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<List<CityLocation>> searchCities(String query) async {
    if (query.trim().length < 2) return const [];
    return _service.searchCities(query.trim());
  }

  Future<void> selectCity(CityLocation city) async {
    selectedCity = city;
    selectedTab = 0;
    weather = null;
    await loadWeather();
  }

  Future<void> useCurrentLocation() async {
    isRefreshing = true;
    notifyListeners();
    final location = await _tryCurrentLocation();
    if (location == null) {
      error = 'Location is unavailable. Check your permission and try again.';
      isRefreshing = false;
      notifyListeners();
      return;
    }
    selectedCity = location;
    await loadWeather(refresh: true);
  }

  Future<void> toggleFavorite(CityLocation city) async {
    final exists = favorites.any((item) => _sameCity(item, city));
    favorites = exists
        ? favorites.where((item) => !_sameCity(item, city)).toList()
        : [...favorites, city];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'favorites',
      favorites.map((item) => jsonEncode(item.toJson())).toList(),
    );
    notifyListeners();
  }

  bool isFavorite(CityLocation city) =>
      favorites.any((item) => _sameCity(item, city));

  Future<void> setCelsius(bool value) async {
    isCelsius = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isCelsius', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setAlertsEnabled(bool value) async {
    alertsEnabled = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('alertsEnabled', value);
    notifyListeners();
  }

  void setTab(int value) {
    selectedTab = value;
    notifyListeners();
  }

  double displayTemperature(double celsius) =>
      isCelsius ? celsius : celsius * 9 / 5 + 32;

  String temperature(double celsius) =>
      '${displayTemperature(celsius).round()}°${isCelsius ? 'C' : 'F'}';

  String windSpeed(double kilometresPerHour) =>
      '${(isCelsius ? kilometresPerHour : kilometresPerHour * 0.621371).round()} ${isCelsius ? 'km/h' : 'mph'}';

  static bool _sameCity(CityLocation first, CityLocation second) =>
      (first.latitude - second.latitude).abs() < 0.01 &&
      (first.longitude - second.longitude).abs() < 0.01;

  Future<void> _saveSelectedCity() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'selectedCity',
      jsonEncode(selectedCity.toJson()),
    );
  }
}
