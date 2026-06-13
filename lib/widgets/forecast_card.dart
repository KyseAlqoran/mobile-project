import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final bool isCelsius;
  final double weeklyMin;
  final double weeklyMax;
  final bool isToday;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.isCelsius,
    required this.weeklyMin,
    required this.weeklyMax,
    this.isToday = false,
  });

  String _formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°';
  }

  String _getDayName(DateTime date) {
    if (isToday) return 'Today';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dayName = _getDayName(forecast.date);
    final icon = WeatherUtils.getWeatherIcon(forecast.weatherCode);
    final iconColor = WeatherUtils.getWeatherIconColor(forecast.weatherCode);

    // Calculate positions for the temperature range bar
    final totalRange = weeklyMax - weeklyMin;
    final double startFraction =
        totalRange > 0 ? (forecast.minTemp - weeklyMin) / totalRange : 0.0;
    final double endFraction =
        totalRange > 0 ? (forecast.maxTemp - weeklyMin) / totalRange : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // Day name
            SizedBox(
              width: 46,
              child: Text(
                dayName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 18,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            // Weather icon
            SizedBox(
              width: 40,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
            // Low temp
            SizedBox(
              width: 38,
              child: Text(
                _formatTemp(forecast.minTemp),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Temperature range bar
            Expanded(
              child: _buildTempRangeBar(startFraction, endFraction),
            ),
            const SizedBox(width: 10),
            // High temp
            SizedBox(
              width: 38,
              child: Text(
                _formatTemp(forecast.maxTemp),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempRangeBar(double startFraction, double endFraction) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final barStart = startFraction * totalWidth;
        final barEnd = endFraction * totalWidth;
        final barWidth = (barEnd - barStart).clamp(6.0, totalWidth);

        // Gradient colors based on temperature range
        final Color startColor = _getTempColor(forecast.minTemp);
        final Color endColor = _getTempColor(forecast.maxTemp);

        return Stack(
          children: [
            // Track background
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Active range
            Positioned(
              left: barStart,
              top: 0,
              child: Container(
                width: barWidth,
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getTempColor(double temp) {
    // iOS-style temperature colors
    if (!isCelsius) {
      temp = (temp - 32) * 5 / 9; // Convert to Celsius for color logic
    }
    if (temp <= -10) return const Color(0xFF6366F1); // Deep indigo
    if (temp <= 0) return const Color(0xFF38BDF8);   // Cyan-blue
    if (temp <= 5) return const Color(0xFF22D3EE);   // Teal
    if (temp <= 10) return const Color(0xFF2DD4BF);  // Teal-green
    if (temp <= 15) return const Color(0xFF4ADE80);  // Green
    if (temp <= 20) return const Color(0xFFA3E635);  // Lime
    if (temp <= 25) return const Color(0xFFFBBF24);  // Yellow
    if (temp <= 30) return const Color(0xFFF97316);  // Orange
    if (temp <= 35) return const Color(0xFFEF4444);  // Red
    return const Color(0xFFDC2626);                   // Deep red
  }
}
