import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../widgets/weather_view.dart';

class SearchScreen extends StatefulWidget {
  final bool isCelsius;
  final void Function(WeatherData) onWeatherLoaded;

  const SearchScreen({
    super.key,
    required this.isCelsius,
    required this.onWeatherLoaded,
  });

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
      _showError('Unable to fetch weather data. Please check your connection.');
      setState(() {
        _isLoading = false;
        _isViewingWeather = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left, color: Colors.white),
                    Text('Back',
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _weatherData != null
                    ? WeatherView(
                        currentLocation: _currentLocation!,
                        weatherData: _weatherData!,
                        isCelsius: widget.isCelsius,
                        onRefresh: () => _fetchWeather(
                          '',
                          existingLocation: _currentLocation,
                        ),
                      )
                    : const SizedBox(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Weather',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for a city',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) {
            if (!_isLoading) {
              _fetchWeather(_searchController.text);
            }
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _savedLocations.isEmpty
              ? const Center(
                  child: Text(
                    'No saved locations yet.\nSearch for a city to start.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _savedLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _savedLocations[index];
                    return _buildLocationCard(loc);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Location loc) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _fetchWeather('', existingLocation: loc);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                if (loc.country.isNotEmpty)
                  Text(
                    loc.country,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await _storageService.removeLocation(loc);
                _loadSavedLocations();
              },
              child: const Icon(Icons.remove_circle_outline,
                  color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}