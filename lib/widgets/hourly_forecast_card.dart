import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/weather_model.dart';

class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isCelsius;
  final bool isNow;
  final bool currentIsDay;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.isCelsius,
    this.isNow = false,
    this.currentIsDay = true,
  });

  String _formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°';
  }

  // Make a simple "3 PM" style time without the intl package
  String _formatHour(DateTime date) {
    if (isNow) return 'Now';
    int hour = date.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    int h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12 $period';
  }

  @override
  Widget build(BuildContext context) {
    // For the "Now" card, use the real day/night value from the API.
    // For future hours, guess from the hour (6 AM to 7 PM = day).
    final hour = forecast.date.hour;
    final bool isDay = isNow ? currentIsDay : (hour >= 6 && hour < 19);
    final iconSvg =
        WeatherUtils.getWeatherSvg(forecast.weatherCode, isDay: isDay);

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatHour(forecast.date),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SvgPicture.asset(iconSvg, width: 30, height: 30),
          const SizedBox(height: 8),
          Text(
            _formatTemp(forecast.temperature),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}