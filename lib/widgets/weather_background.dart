import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherBackground extends StatelessWidget {
  final WeatherData? weatherData;

  const WeatherBackground({super.key, this.weatherData});

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      // Default iOS Weather-style deep blue gradient
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B3A5C),
              Color(0xFF2D5F8A),
              Color(0xFF4A7FB5),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      );
    }

    final code = weatherData!.current.weatherCode;
    final isDay = weatherData!.current.isDay == 1;

    List<Color> colors;
    List<double> stops;

    if (code == 0 || code == 1) {
      // Clear sky
      if (isDay) {
        colors = [
          const Color(0xFF1B3A5C),
          const Color(0xFF2E6BBF),
          const Color(0xFF4A9AE6),
          const Color(0xFF6BB3F0),
        ];
        stops = [0.0, 0.3, 0.6, 1.0];
      } else {
        colors = [
          const Color(0xFF0A1628),
          const Color(0xFF0F1F3D),
          const Color(0xFF172B52),
          const Color(0xFF1E3A6B),
        ];
        stops = [0.0, 0.3, 0.6, 1.0];
      }
    } else if (code == 2 || code == 3) {
      // Cloudy / Overcast
      if (isDay) {
        colors = [
          const Color(0xFF4A5568),
          const Color(0xFF667085),
          const Color(0xFF7C8BA0),
          const Color(0xFF8D9BB0),
        ];
        stops = [0.0, 0.3, 0.6, 1.0];
      } else {
        colors = [
          const Color(0xFF1A202C),
          const Color(0xFF2D3748),
          const Color(0xFF3D4A5C),
        ];
        stops = [0.0, 0.5, 1.0];
      }
    } else if (code >= 45 && code <= 48) {
      // Fog
      colors = [
        const Color(0xFF4A5568),
        const Color(0xFF718096),
        const Color(0xFF8B9DB5),
      ];
      stops = [0.0, 0.5, 1.0];
    } else if ((code >= 51 && code <= 55) || (code >= 61 && code <= 65) || (code >= 80 && code <= 82)) {
      // Rain / Drizzle
      colors = [
        const Color(0xFF1A2332),
        const Color(0xFF2B3C52),
        const Color(0xFF3D5068),
        const Color(0xFF4E6480),
      ];
      stops = [0.0, 0.3, 0.6, 1.0];
    } else if ((code >= 71 && code <= 75) || (code >= 85 && code <= 86)) {
      // Snow
      colors = [
        const Color(0xFF4A5568),
        const Color(0xFF6B7D95),
        const Color(0xFF8B9DB5),
        const Color(0xFFA8B8CC),
      ];
      stops = [0.0, 0.3, 0.6, 1.0];
    } else if (code == 95 || code == 99) {
      // Thunderstorm
      colors = [
        const Color(0xFF0D1117),
        const Color(0xFF161B22),
        const Color(0xFF21262D),
        const Color(0xFF2B3139),
      ];
      stops = [0.0, 0.3, 0.6, 1.0];
    } else {
      // Default
      colors = [
        const Color(0xFF1B3A5C),
        const Color(0xFF2D5F8A),
        const Color(0xFF4A7FB5),
      ];
      stops = [0.0, 0.5, 1.0];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }
}
