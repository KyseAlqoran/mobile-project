import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  WeatherService() {
    // Dio interceptor: runs before every request and after every response.
    // This is one of the main Dio features for our topic.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ignore: avoid_print
          print('Request sent to: ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // ignore: avoid_print
          print('Response code: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          // ignore: avoid_print
          print('Dio error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Turn a city name into a Location (latitude + longitude)
  Future<Location?> geocodeCity(String cityName) async {
    try {
      final response = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': cityName,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
      );

      final data = response.data;
      if (data['results'] != null && data['results'].isNotEmpty) {
        return Location.fromJson(data['results'][0]);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Get the weather for a latitude / longitude
  Future<WeatherData> getWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current':
              'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,apparent_temperature,pressure_msl,visibility,is_day',
          'hourly': 'temperature_2m,weather_code',
          'daily':
              'temperature_2m_max,temperature_2m_min,weather_code,precipitation_sum,sunrise,sunset,uv_index_max',
          'timezone': 'auto',
          'forecast_days': 7,
        },
      );

      return WeatherData.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // Turn a Dio error into a simple message for the user
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out.';
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}.';
      default:
        return 'Unable to fetch weather data.';
    }
  }
}
