import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_info_tile.dart';
import '../widgets/forecast_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  Location? _currentLocation;
  WeatherData? _weatherData;
  bool _isLoading = false;
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadLastSearchedCity();
  }

  Future<void> _loadLastSearchedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('last_city');
    if (lastCity != null && lastCity.isNotEmpty) {
      _searchController.text = lastCity;
      _fetchWeather(lastCity);
    }
  }

  Future<void> _saveLastSearchedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);
  }

  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final location = await _weatherService.geocodeCity(city.trim());
      if (location == null) {
        _showError('City not found. Please try another name.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final weatherData = await _weatherService.getWeather(
        location.latitude,
        location.longitude,
      );

      setState(() {
        _currentLocation = location;
        _weatherData = weatherData;
        _isLoading = false;
      });

      _saveLastSearchedCity(city.trim());
    } catch (e) {
      _showError('Unable to fetch weather data. Please check your connection.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  String _formatTemp(double temp) {
    if (!_isCelsius) {
      temp = (temp * 9 / 5) + 32;
    }
    return '${temp.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF064E3B)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                _buildTopSection()
                    .animate()
                    .fade(duration: 600.ms)
                    .slideY(begin: -0.2),
                const SizedBox(height: 24),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF38BDF8),
                            ),
                          )
                        : _weatherData == null
                        ? Center(
                            child: Text(
                              'Search for a city to see the weather.',
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ).animate().fade(delay: 300.ms)
                        : _buildWeatherContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white70),
                      onPressed: _isLoading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              _fetchWeather(_searchController.text);
                            },
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _fetchWeather(_searchController.text);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildUnitToggle(),
      ],
    );
  }

  Widget _buildUnitToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCelsius = !_isCelsius;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 70,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isCelsius ? 0 : 32,
                  right: _isCelsius ? 32 : 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Text(
                        '°C',
                        style: GoogleFonts.outfit(
                          color: _isCelsius ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '°F',
                        style: GoogleFonts.outfit(
                          color: !_isCelsius ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final current = _weatherData!.current;
    final emoji = WeatherUtils.getWeatherEmoji(current.weatherCode);
    final label = WeatherUtils.getWeatherLabel(current.weatherCode);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_currentLocation!.name}, ${_currentLocation!.country}',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF38BDF8,
                                    ).withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _formatTemp(current.temperature),
                              style: GoogleFonts.outfit(
                                fontSize: 84,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: const Color(
                                      0xFF38BDF8,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF38BDF8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                WeatherInfoTile(
                                  icon: Icons.thermostat,
                                  label: 'Feels Like',
                                  value: _formatTemp(
                                    current.apparentTemperature,
                                  ),
                                ),
                                WeatherInfoTile(
                                  icon: Icons.water_drop_outlined,
                                  label: 'Humidity',
                                  value: '${current.humidity}%',
                                ),
                                WeatherInfoTile(
                                  icon: Icons.air,
                                  label: 'Wind',
                                  value: '${current.windSpeed} km/h',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(duration: 600.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutQuad),
              const SizedBox(height: 40),
              Text(
                '7-DAY FORECAST',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 2.0,
                ),
              ).animate().fade(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 20),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _weatherData!.daily.length,
                  itemBuilder: (context, index) {
                    return ForecastCard(
                          forecast: _weatherData!.daily[index],
                          isCelsius: _isCelsius,
                        )
                        .animate()
                        .fade(delay: (300 + index * 100).ms, duration: 500.ms)
                        .slideX(begin: 0.2, curve: Curves.easeOutQuad);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
