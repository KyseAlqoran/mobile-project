import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../widgets/weather_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends StatefulWidget {
  final bool isCelsius;
  final void Function(WeatherData) onWeatherLoaded;

  const SearchScreen(
      {super.key, required this.isCelsius, required this.onWeatherLoaded});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();

  List<Location> _savedLocations = [];
  Location? _currentLocation;
  WeatherData? _weatherData;
  bool _isLoading = false;
  bool _isViewingWeather = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locations = await _storageService.getSavedLocations();
    setState(() {
      _savedLocations = locations;
    });
  }

  Future<void> _fetchWeather(String city, {Location? existingLocation}) async {
    if (city.trim().isEmpty && existingLocation == null) return;

    setState(() {
      _isLoading = true;
      _isViewingWeather = true;
    });

    try {
      Location location;
      if (existingLocation != null) {
        location = existingLocation;
      } else {
        final loc = await _weatherService.geocodeCity(city.trim());
        if (loc == null) {
          _showError('City not found. Please try another name.');
          setState(() {
            _isLoading = false;
            _isViewingWeather = false;
          });
          return;
        }
        location = loc;
        await _storageService.saveLocation(location);
        _loadSavedLocations();
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
      widget.onWeatherLoaded(weatherData);
    } catch (e) {
      _showError(
          'Unable to fetch weather data. Please check your connection.');
      setState(() {
        _isLoading = false;
        _isViewingWeather = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isViewingWeather) {
      return Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isViewingWeather = false;
                    _weatherData = null;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.chevron_left,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Weather',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 14,
                      ),
                    )
                  : _weatherData != null
                      ? WeatherView(
                          currentLocation: _currentLocation!,
                          weatherData: _weatherData!,
                          isCelsius: widget.isCelsius,
                          onRefresh: () => _fetchWeather('',
                              existingLocation: _currentLocation),
                        )
                      : const SizedBox(),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        // Title
        Text(
          'Weather',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.3,
          ),
        ).animate().fade(duration: 400.ms),
        const SizedBox(height: 12),
        // Search bar - iOS style
        _buildSearchBar().animate().fade(duration: 400.ms),
        const SizedBox(height: 24),
        // Saved locations list
        Expanded(
          child: _savedLocations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved locations yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Search for a city to get started',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 200.ms, duration: 400.ms)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _savedLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _savedLocations[index];
                    return _buildLocationCard(loc, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search for a city or airport',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Icon(
                  CupertinoIcons.search,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 18,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 20,
              ),
              isDense: true,
            ),
            onSubmitted: (_) {
              if (!_isLoading) {
                _fetchWeather(_searchController.text);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(Location loc, int index) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _fetchWeather('', existingLocation: loc);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (loc.country.isNotEmpty)
                          Text(
                            loc.country,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _storageService.removeLocation(loc);
                      _loadSavedLocations();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        CupertinoIcons.minus_circle,
                        color: Colors.white.withValues(alpha: 0.35),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: (200 + index * 80).ms, duration: 400.ms)
        .slideY(begin: 0.05);
  }
}
