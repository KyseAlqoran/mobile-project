import 'package:flutter/material.dart';

// ----------------------------
// Location model
// ----------------------------
class Location {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// ----------------------------
// Current weather model
// ----------------------------
class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final double surfacePressure;
  final double visibility;
  final int isDay;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.surfacePressure,
    required this.visibility,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] ?? 0).toDouble(),
      apparentTemperature: (json['apparent_temperature'] ?? 0).toDouble(),
      humidity: json['relative_humidity_2m'] ?? 0,
      windSpeed: (json['wind_speed_10m'] ?? 0).toDouble(),
      weatherCode: (json['weather_code'] ?? 0).toInt(),
      surfacePressure: (json['surface_pressure'] ?? 0).toDouble(),
      visibility: (json['visibility'] ?? 0).toDouble(),
      isDay: json['is_day'] ?? 1,
    );
  }
}

// ----------------------------
// One hour forecast model
// ----------------------------
class HourlyForecast {
  final DateTime date;
  final double temperature;
  final int weatherCode;

  HourlyForecast({
    required this.date,
    required this.temperature,
    required this.weatherCode,
  });
}

// ----------------------------
// One day forecast model
// ----------------------------
class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final double precipitation;
  final String sunrise;
  final String sunset;
  final double uvIndexMax;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.precipitation,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
  });
}

// ----------------------------
// Full weather data (current + hourly + 7 days)
// ----------------------------
class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  WeatherData({
    required this.current,
    required this.daily,
    required this.hourly,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = CurrentWeather.fromJson(json['current'] ?? {});

    // Daily
    final dailyJson = json['daily'] ?? {};
    final List<dynamic> dailyTimes = dailyJson['time'] ?? [];
    final List<dynamic> maxTemps = dailyJson['temperature_2m_max'] ?? [];
    final List<dynamic> minTemps = dailyJson['temperature_2m_min'] ?? [];
    final List<dynamic> dailyCodes = dailyJson['weather_code'] ?? [];
    final List<dynamic> precipitations = dailyJson['precipitation_sum'] ?? [];
    final List<dynamic> sunrises = dailyJson['sunrise'] ?? [];
    final List<dynamic> sunsets = dailyJson['sunset'] ?? [];
    final List<dynamic> uvIndexes = dailyJson['uv_index_max'] ?? [];

    List<DailyForecast> daily = [];
    for (int i = 0; i < dailyTimes.length; i++) {
      daily.add(
        DailyForecast(
          date: DateTime.tryParse(dailyTimes[i].toString()) ?? DateTime.now(),
          maxTemp: (maxTemps.length > i ? maxTemps[i] ?? 0 : 0).toDouble(),
          minTemp: (minTemps.length > i ? minTemps[i] ?? 0 : 0).toDouble(),
          weatherCode: dailyCodes.length > i
              ? (dailyCodes[i] ?? 0).toInt()
              : 0,
          precipitation:
              (precipitations.length > i ? precipitations[i] ?? 0 : 0).toDouble(),
          sunrise: sunrises.length > i ? sunrises[i]?.toString() ?? '' : '',
          sunset: sunsets.length > i ? sunsets[i]?.toString() ?? '' : '',
          uvIndexMax: (uvIndexes.length > i ? uvIndexes[i] ?? 0 : 0).toDouble(),
        ),
      );
    }

    // Hourly
    final hourlyJson = json['hourly'] ?? {};
    final List<dynamic> hourlyTimes = hourlyJson['time'] ?? [];
    final List<dynamic> hourlyTemps = hourlyJson['temperature_2m'] ?? [];
    final List<dynamic> hourlyCodes = hourlyJson['weather_code'] ?? [];

    List<HourlyForecast> hourly = [];
    for (int i = 0; i < hourlyTimes.length; i++) {
      hourly.add(
        HourlyForecast(
          date: DateTime.tryParse(hourlyTimes[i].toString()) ?? DateTime.now(),
          temperature: (hourlyTemps.length > i ? hourlyTemps[i] ?? 0 : 0).toDouble(),
          weatherCode: hourlyCodes.length > i
              ? (hourlyCodes[i] ?? 0).toInt()
              : 0,
        ),
      );
    }

    return WeatherData(current: current, daily: daily, hourly: hourly);
  }
}

// ----------------------------
// Helper functions for weather codes
// ----------------------------
class WeatherUtils {
  static String getWeatherLabel(int code) {
    if (code == 0) return 'Clear';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 75) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 85 && code <= 86) return 'Snow Showers';
    if (code == 95) return 'Thunderstorm';
    if (code == 99) return 'Heavy Thunderstorm';
    return 'Unknown';
  }

  // Returns the SVG asset path for each weather type (nice iPhone-style icons)
  static String getWeatherSvg(int code, {bool isDay = true}) {
    if (code == 0 || code == 1) {
      return isDay ? 'assets/weather/sunny.svg' : 'assets/weather/night.svg';
    }
    if (code == 2) return 'assets/weather/partly_cloudy.svg';
    if (code == 3) return 'assets/weather/cloud.svg';
    if (code >= 45 && code <= 48) return 'assets/weather/cloud.svg'; // fog
    if (code >= 51 && code <= 55) return 'assets/weather/drizzle.svg';
    if (code >= 61 && code <= 65) return 'assets/weather/rain.svg';
    if (code >= 71 && code <= 75) return 'assets/weather/snow.svg';
    if (code >= 80 && code <= 82) return 'assets/weather/rain.svg';
    if (code >= 85 && code <= 86) return 'assets/weather/snow.svg';
    if (code == 95 || code == 99) return 'assets/weather/storm.svg';
    return 'assets/weather/cloud.svg';
  }

  // Nice weather icon from Material's filled weather set (iPhone-like, no package)
  static IconData getWeatherIcon(int code, {bool isDay = true}) {
    if (code == 0) {
      return isDay ? Icons.sunny : Icons.nights_stay;
    }
    if (code == 1) {
      return isDay ? Icons.sunny : Icons.nights_stay;
    }
    if (code == 2) return Icons.wb_cloudy; // partly cloudy
    if (code == 3) return Icons.cloud; // overcast
    if (code >= 45 && code <= 48) return Icons.cloud; // fog
    if (code >= 51 && code <= 55) return Icons.water_drop_rounded; // drizzle
    if (code >= 61 && code <= 65) return Icons.water_drop_rounded; // rain
    if (code >= 71 && code <= 75) return Icons.ac_unit; // snow
    if (code >= 80 && code <= 82) return Icons.water_drop_rounded; // rain showers
    if (code >= 85 && code <= 86) return Icons.ac_unit; // snow showers
    if (code == 95 || code == 99) return Icons.thunderstorm; // storm
    return Icons.thermostat;
  }

  // Color for each weather icon (yellow sun, blue rain, white snow, grey clouds)
  static Color getWeatherIconColor(int code, {bool isDay = true}) {
    if (code == 0 || code == 1) {
      // Sun is yellow in the day, moon is soft white at night
      return isDay ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0);
    }
    if (code == 2 || code == 3) return const Color(0xFFE2E8F0); // cloud light
    if (code >= 45 && code <= 48) return const Color(0xFFE2E8F0); // fog light
    if (code >= 51 && code <= 55) return const Color(0xFF93C5FD); // drizzle light blue
    if (code >= 61 && code <= 65) return const Color(0xFF93C5FD); // rain light blue
    if (code >= 71 && code <= 75) return const Color(0xFFE2E8F0); // snow white
    if (code >= 80 && code <= 82) return const Color(0xFF93C5FD); // rain showers light blue
    if (code >= 85 && code <= 86) return const Color(0xFFE2E8F0); // snow showers white
    if (code == 95 || code == 99) return const Color(0xFFFBBF24); // storm yellow
    return const Color(0xFFE2E8F0);
  }

  // Two colors for the gradient background based on weather + day/night
  static List<Color> getBackgroundColors(int code, int isDay) {
    if (isDay == 0) {
      // Night
      return [const Color(0xFF0A1628), const Color(0xFF1E3A6B)];
    }
    if (code == 0 || code == 1) {
      // Clear day - blue
      return [const Color(0xFF1B3A5C), const Color(0xFF4A9AE6)];
    }
    if (code == 2 || code == 3) {
      // Cloudy - grey blue
      return [const Color(0xFF4A5568), const Color(0xFF8D9BB0)];
    }
    if (code >= 45 && code <= 48) {
      // Fog
      return [const Color(0xFF4A5568), const Color(0xFF8B9DB5)];
    }
    if (code >= 51 && code <= 65) {
      // Rain
      return [const Color(0xFF1A2332), const Color(0xFF4E6480)];
    }
    if (code >= 71 && code <= 86) {
      // Snow
      return [const Color(0xFF4A5568), const Color(0xFFA8B8CC)];
    }
    if (code == 95 || code == 99) {
      // Storm
      return [const Color(0xFF0D1117), const Color(0xFF2B3139)];
    }
    return [const Color(0xFF1B3A5C), const Color(0xFF4A7FB5)];
  }

  // Color for a temperature (used in the 7-day bars)
  static Color getTempColor(double tempC) {
    if (tempC <= 5) return const Color(0xFF22D3EE); // cyan (cold)
    if (tempC <= 12) return const Color(0xFF4ADE80); // green
    if (tempC <= 18) return const Color(0xFFA3E635); // lime
    if (tempC <= 23) return const Color(0xFFFBBF24); // yellow
    if (tempC <= 28) return const Color(0xFFF59E0B); // amber
    if (tempC <= 33) return const Color(0xFFF97316); // orange
    return const Color(0xFFEF4444); // red (hot)
  }
}