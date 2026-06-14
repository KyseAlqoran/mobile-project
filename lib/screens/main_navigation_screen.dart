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
    // The two pages
    final pages = [
      CurrentLocationScreen(
        isCelsius: _isCelsius,
        onWeatherLoaded: _onWeatherLoaded,
      ),
      SearchScreen(
        isCelsius: _isCelsius,
        onWeatherLoaded: _onWeatherLoaded,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      // No AppBar (like iPhone). Gradient fills the screen, content on top.
      body: Stack(
        children: [
          WeatherBackground(weatherData: _currentWeatherData),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Top row: just the °C / °F toggle on the right
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isCelsius = !_isCelsius;
                        });
                      },
                      child: Text(
                        _isCelsius ? '°C' : '°F',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // The current page fills the rest
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: pages,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Our own see-through bottom bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // A simple see-through bottom bar built with Container + Row (example style)
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
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
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTab(Icons.my_location, 'My Location', 0),
              _buildTab(Icons.list, 'Cities', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.55),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}