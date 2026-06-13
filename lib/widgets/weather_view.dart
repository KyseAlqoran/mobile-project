import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/weather_model.dart';
import 'forecast_card.dart';
import 'hourly_forecast_card.dart';

class WeatherView extends StatelessWidget {
  final Location currentLocation;
  final WeatherData weatherData;
  final bool isCelsius;
  final Future<void> Function() onRefresh;

  const WeatherView({
    super.key,
    required this.currentLocation,
    required this.weatherData,
    required this.isCelsius,
    required this.onRefresh,
  });

  String _formatTemp(double temp) {
    if (!isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final daily = weatherData.daily.isNotEmpty ? weatherData.daily.first : null;
    final label = WeatherUtils.getWeatherLabel(current.weatherCode);

    // Get hourly forecasts from current time onwards (next 24 hours)
    final now = DateTime.now();
    final upcomingHourly = weatherData.hourly
        .where((h) => h.date.isAfter(now.subtract(const Duration(hours: 1))))
        .take(24)
        .toList();

    // Weekly temperature range for the daily forecast bars
    double weeklyMin = double.infinity;
    double weeklyMax = double.negativeInfinity;
    for (final d in weatherData.daily) {
      if (d.minTemp < weeklyMin) weeklyMin = d.minTemp;
      if (d.maxTemp > weeklyMax) weeklyMax = d.maxTemp;
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // ── Hero Section ──
            _buildHeroSection(current, daily, label),

            const SizedBox(height: 44),

            // ── Hourly Forecast ──
            if (upcomingHourly.isNotEmpty)
              _buildHourlySection(upcomingHourly, current)
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: 0.05),

            const SizedBox(height: 16),

            // ── 7-Day Forecast ──
            _buildDailySection(weeklyMin, weeklyMax)
                .animate()
                .fade(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 16),

            // ── Detail Grid ──
            _buildDetailGrid(current, daily)
                .animate()
                .fade(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ─── Hero Section ───────────────────────────────────────
  Widget _buildHeroSection(
      CurrentWeather current, DailyForecast? daily, String label) {
    return Column(
      children: [
        // City name
        Text(
          currentLocation.name,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ).animate().fade(duration: 600.ms),
        const SizedBox(height: 4),

        // Large temperature
        Text(
          _formatTemp(current.temperature),
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w200,
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.05,
            letterSpacing: -2,
          ),
        ).animate().fade(duration: 600.ms),

        // Condition label
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.3,
          ),
        ).animate().fade(delay: 100.ms, duration: 500.ms),

        // H / L temps
        if (daily != null) ...[
          const SizedBox(height: 4),
          Text(
            'H:${_formatTemp(daily.maxTemp)}  L:${_formatTemp(daily.minTemp)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ).animate().fade(delay: 150.ms, duration: 500.ms),
        ],
      ],
    );
  }

  // ─── Frosted Glass Container ────────────────────────────
  Widget _buildFrostedContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ─── Hourly Forecast Section ────────────────────────────
  Widget _buildHourlySection(
      List<HourlyForecast> upcomingHourly, CurrentWeather current) {
    final description = WeatherUtils.getWeatherDescription(
      current.weatherCode,
      WeatherUtils.getWeatherLabel(current.weatherCode),
    );

    return _buildFrostedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
            thickness: 0.5,
          ),
          // Hourly items
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: upcomingHourly.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return HourlyForecastCard(
                  forecast: upcomingHourly[index],
                  isCelsius: isCelsius,
                  isNow: index == 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── 7-Day Forecast Section ─────────────────────────────
  Widget _buildDailySection(double weeklyMin, double weeklyMax) {
    return _buildFrostedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '7-DAY FORECAST',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Daily rows
          ...weatherData.daily.asMap().entries.map((entry) {
            final index = entry.key;
            final forecast = entry.value;
            return Column(
              children: [
                Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ForecastCard(
                    forecast: forecast,
                    isCelsius: isCelsius,
                    weeklyMin: weeklyMin,
                    weeklyMax: weeklyMax,
                    isToday: index == 0,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Detail Grid ────────────────────────────────────────
  Widget _buildDetailGrid(CurrentWeather current, DailyForecast? daily) {
    final tiles = <Widget>[
      _buildDetailTile(
        CupertinoIcons.sun_max_fill,
        'UV INDEX',
        daily != null ? daily.uvIndexMax.round().toString() : '--',
        _getUVDescription(daily?.uvIndexMax ?? 0),
      ),
      _buildDetailTile(
        CupertinoIcons.sunrise_fill,
        'SUNRISE',
        daily != null ? _formatTime(daily.sunrise) : '--',
        daily != null ? 'Sunset: ${_formatTime(daily.sunset)}' : '',
      ),
      _buildDetailTile(
        CupertinoIcons.wind,
        'WIND',
        '${current.windSpeed.round()} km/h',
        '',
      ),
      _buildDetailTile(
        CupertinoIcons.drop_fill,
        'RAINFALL',
        daily != null
            ? '${daily.precipitation.toStringAsFixed(1)} mm'
            : '--',
        'in last 24h',
      ),
      _buildDetailTile(
        CupertinoIcons.thermometer,
        'FEELS LIKE',
        _formatTemp(current.apparentTemperature),
        _getFeelsLikeDescription(
            current.temperature, current.apparentTemperature),
      ),
      _buildDetailTile(
        CupertinoIcons.drop,
        'HUMIDITY',
        '${current.humidity}%',
        'The dew point is ${_formatTemp(current.apparentTemperature - 2)}.',
      ),
      _buildDetailTile(
        CupertinoIcons.eye_fill,
        'VISIBILITY',
        '${(current.visibility / 1000).toStringAsFixed(0)} km',
        _getVisibilityDescription(current.visibility),
      ),
      _buildDetailTile(
        CupertinoIcons.gauge,
        'PRESSURE',
        '${current.surfacePressure.round()} hPa',
        '',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) => tiles[index],
    );
  }

  Widget _buildDetailTile(
      IconData icon, String label, String value, String description) {
    return _buildFrostedContainer(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Value
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            if (description.isNotEmpty) ...[
              const Spacer(),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────
  String _formatTime(String isoTime) {
    if (isoTime.isEmpty || !isoTime.contains('T')) return '--';
    final parts = isoTime.split('T');
    if (parts.length < 2) return '--';
    final timeParts = parts[1].split(':');
    if (timeParts.length < 2) return parts[1];
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$minute $period';
  }

  String _getUVDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  String _getFeelsLikeDescription(double actual, double feelsLike) {
    final diff = feelsLike - actual;
    if (diff.abs() < 1) return 'Similar to the actual temperature.';
    if (diff > 0) return 'Humidity is making it feel warmer.';
    return 'Wind is making it feel cooler.';
  }

  String _getVisibilityDescription(double visibility) {
    final km = visibility / 1000;
    if (km >= 10) return 'It\'s perfectly clear right now.';
    if (km >= 5) return 'Good visibility conditions.';
    if (km >= 1) return 'Moderate visibility.';
    return 'Low visibility conditions.';
  }
}
