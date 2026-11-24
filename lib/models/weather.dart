class CityLocation {
  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1 = '',
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String admin1;

  String get label => admin1.isEmpty ? name : '$name, $admin1';

  Map<String, Object> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'admin1': admin1,
  };

  factory CityLocation.fromJson(Map<String, dynamic> json) => CityLocation(
    name: json['name'] as String,
    country: json['country'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    admin1: json['admin1'] as String? ?? '',
  );
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.minimum,
    required this.maximum,
    required this.precipitationProbability,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime date;
  final int weatherCode;
  final double minimum;
  final double maximum;
  final int precipitationProbability;
  final DateTime sunrise;
  final DateTime sunset;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.isDay,
    required this.high,
    required this.low,
    required this.sunrise,
    required this.sunset,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
    required this.cloudCover,
    required this.dewPoint,
    required this.precipitationProbability,
    required this.airQualityIndex,
    required this.hourly,
    required this.daily,
  });

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final bool isDay;
  final double high;
  final double low;
  final DateTime sunrise;
  final DateTime sunset;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double uvIndex;
  final double visibility;
  final double pressure;
  final int cloudCover;
  final double dewPoint;
  final int precipitationProbability;
  final int? airQualityIndex;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  String get condition => weatherDescription(weatherCode);
  String get windCardinal => windDirectionLabel(windDirection);

  factory WeatherSnapshot.fromJson(
    Map<String, dynamic> json, {
    int? airQualityIndex,
  }) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyData = json['hourly'] as Map<String, dynamic>;
    final dailyData = json['daily'] as Map<String, dynamic>;
    final hourlyTimes = (hourlyData['time'] as List).cast<String>();
    final currentTime = DateTime.parse(current['time'] as String);
    final currentHour = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
    );
    final hourlyAll = List.generate(
      hourlyTimes.length,
      (index) => HourlyForecast(
        time: DateTime.parse(hourlyTimes[index]),
        temperature: _number(hourlyData['temperature_2m'], index),
        weatherCode: _number(hourlyData['weather_code'], index).round(),
        precipitationProbability: _number(
          hourlyData['precipitation_probability'],
          index,
        ).round(),
      ),
    );
    final startIndex = hourlyAll.indexWhere(
      (item) => !item.time.isBefore(currentHour),
    );
    final hourly = hourlyAll
        .skip(startIndex < 0 ? 0 : startIndex)
        .take(24)
        .toList();
    final dailyTimes = (dailyData['time'] as List).cast<String>();
    final daily = <DailyForecast>[];
    for (var index = 0; index < dailyTimes.length; index++) {
      daily.add(
        DailyForecast(
          date: DateTime.parse(dailyTimes[index]),
          weatherCode: _number(dailyData['weather_code'], index).round(),
          minimum: _number(dailyData['temperature_2m_min'], index),
          maximum: _number(dailyData['temperature_2m_max'], index),
          precipitationProbability: _number(
            dailyData['precipitation_probability_max'],
            index,
          ).round(),
          sunrise: DateTime.parse(
            (dailyData['sunrise'] as List)[index] as String,
          ),
          sunset: DateTime.parse(
            (dailyData['sunset'] as List)[index] as String,
          ),
        ),
      );
    }
    final firstDay = daily.first;
    final visibilityMetres = (current['visibility'] as num?)?.toDouble() ?? 0;

    return WeatherSnapshot(
      time: currentTime,
      temperature: _number([current['temperature_2m']], 0),
      apparentTemperature: _number([current['apparent_temperature']], 0),
      weatherCode: (current['weather_code'] as num).round(),
      isDay: (current['is_day'] as num) == 1,
      high: firstDay.maximum,
      low: firstDay.minimum,
      sunrise: firstDay.sunrise,
      sunset: firstDay.sunset,
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: _number([current['wind_speed_10m']], 0),
      windDirection: (current['wind_direction_10m'] as num).round(),
      uvIndex: _number([current['uv_index']], 0),
      visibility: visibilityMetres / 1000,
      pressure: _number([current['surface_pressure']], 0),
      cloudCover: (current['cloud_cover'] as num).round(),
      dewPoint: _number([current['dew_point_2m']], 0),
      precipitationProbability: hourly.isEmpty
          ? 0
          : hourly.first.precipitationProbability,
      airQualityIndex: airQualityIndex,
      hourly: hourly,
      daily: daily,
    );
  }

  static double _number(List<dynamic> values, int index) =>
      (values[index] as num?)?.toDouble() ?? 0;
}

String weatherDescription(int code) => switch (code) {
  0 => 'Clear sky',
  1 => 'Mainly clear',
  2 => 'Partly cloudy',
  3 => 'Overcast',
  45 || 48 => 'Foggy',
  51 || 53 || 55 => 'Drizzle',
  56 || 57 => 'Freezing drizzle',
  61 || 63 || 65 => 'Rain',
  66 || 67 => 'Freezing rain',
  71 || 73 || 75 || 77 => 'Snow',
  80 || 81 || 82 => 'Rain showers',
  85 || 86 => 'Snow showers',
  95 || 96 || 99 => 'Thunderstorms',
  _ => 'Conditions changing',
};

String windDirectionLabel(int degrees) {
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return directions[((degrees + 22) % 360) ~/ 45];
}
