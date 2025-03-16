// lib/services/location_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delivery_driver_app/viewmodels/profile_viewmodel.dart';

class LocationService {
  final ProfileViewModel _profileViewModel;
  
  Timer? _locationUpdateTimer;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  LocationService(this._profileViewModel);
  
  // Start tracking driver location
  Future<bool> startTracking() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return false;
      }
      
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        return false;
      }
      
      // Get current position and update profile
      final Position position = await Geolocator.getCurrentPosition();
      await _profileViewModel.updateLocation(
        position.latitude,
        position.longitude,
      );
      
      // Set up periodic location updates
      _locationUpdateTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _updateLocation(),
      );
      
      // Listen for significant location changes
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // Update when moved 100 meters
        ),
      ).listen((Position position) {
        _profileViewModel.updateLocation(
          position.latitude,
          position.longitude,
        );
      });
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting location tracking: $e');
      }
      return false;
    }
  }
  
  // Stop tracking driver location
  void stopTracking() {
    _locationUpdateTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer = null;
    _positionStreamSubscription = null;
  }
  
  // Update location manually
  Future<void> _updateLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition();
      await _profileViewModel.updateLocation(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating location: $e');
      }
    }
  }
  
  // Dispose resources
  void dispose() {
    stopTracking();
  }
}