import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isCelsius;
  final bool isNow;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.isCelsius,
    this.isNow = false,
  });

  String _formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    final icon = WeatherUtils.getWeatherIcon(forecast.weatherCode);
    final iconColor = WeatherUtils.getWeatherIconColor(forecast.weatherCode);
    final timeStr = isNow ? 'Now' : DateFormat.j().format(forecast.date);

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              fontWeight: isNow ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
          const SizedBox(height: 14),
          Text(
            _formatTemp(forecast.temperature),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
