import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/weather_background.dart';
import 'current_location_screen.dart';
import 'search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isCelsius = true;
  WeatherData? _currentWeatherData;

  void _onWeatherLoaded(WeatherData data) {
    setState(() {
      _currentWeatherData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full-bleed background
          WeatherBackground(weatherData: _currentWeatherData),
          // Content
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CurrentLocationScreen(
                    isCelsius: _isCelsius,
                    onWeatherLoaded: _onWeatherLoaded,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SearchScreen(
                    isCelsius: _isCelsius,
                    onWeatherLoaded: _onWeatherLoaded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _buildIOSBottomBar(),
    );
  }

  Widget _buildIOSBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Map icon (placeholder)
                    _buildBarIcon(
                      CupertinoIcons.map_fill,
                      onTap: () {},
                    ),

                    // Center: page indicator dots + unit toggle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Unit toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCelsius = !_isCelsius;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isCelsius ? '°C' : '°F',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Page dots
                        _buildPageDots(),
                      ],
                    ),

                    // List icon (navigate to search/cities)
                    _buildBarIcon(
                      CupertinoIcons.list_bullet,
                      isActive: _currentIndex == 1,
                      onTap: () {
                        setState(() {
                          _currentIndex = _currentIndex == 0 ? 1 : 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarIcon(IconData icon,
      {bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: isActive ? 0.95 : 0.65),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Location dot (current location)
        Icon(
          CupertinoIcons.location_solid,
          size: 8,
          color: Colors.white.withValues(alpha: _currentIndex == 0 ? 0.95 : 0.4),
        ),
        const SizedBox(width: 6),
        // Search/cities dot
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white
                .withValues(alpha: _currentIndex == 1 ? 0.95 : 0.35),
          ),
        ),
      ],
    );
  }
}
