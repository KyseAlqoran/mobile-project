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
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] ?? 0).toDouble(),
      apparentTemperature: (json['apparent_temperature'] ?? 0).toDouble(),
      humidity: json['relative_humidity_2m'] ?? 0,
      windSpeed: (json['wind_speed_10m'] ?? 0).toDouble(),
      weatherCode: json['weather_code'] ?? 0,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final double precipitation;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.precipitation,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = CurrentWeather.fromJson(json['current']);

    final dailyJson = json['daily'];
    final List<dynamic> times = dailyJson['time'];
    final List<dynamic> maxTemps = dailyJson['temperature_2m_max'];
    final List<dynamic> minTemps = dailyJson['temperature_2m_min'];
    final List<dynamic> codes = dailyJson['weather_code'];
    final List<dynamic> precipitations = dailyJson['precipitation_sum'];

    List<DailyForecast> daily = [];
    for (int i = 0; i < times.length; i++) {
      daily.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          maxTemp: (maxTemps[i] ?? 0).toDouble(),
          minTemp: (minTemps[i] ?? 0).toDouble(),
          weatherCode: codes[i] ?? 0,
          precipitation: (precipitations[i] ?? 0).toDouble(),
        ),
      );
    }

    return WeatherData(current: current, daily: daily);
  }
}

class WeatherUtils {
  static String getWeatherLabel(int code) {
    if (code == 0) return 'Clear Sky';
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

  static String getWeatherEmoji(int code) {
    if (code == 0) return '☀️';
    if (code == 1) return '🌤';
    if (code == 2) return '⛅';
    if (code == 3) return '🌥';
    if (code >= 45 && code <= 48) return '🌫';
    if (code >= 51 && code <= 55) return '🌦';
    if (code >= 61 && code <= 65) return '🌧';
    if (code >= 71 && code <= 75) return '❄️';
    if (code >= 80 && code <= 82) return '🌧';
    if (code >= 85 && code <= 86) return '🌨';
    if (code == 95 || code == 99) return '⛈';
    return '🌡';
  }
}
