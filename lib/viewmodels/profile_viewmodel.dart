// lib/viewmodels/profile_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:delivery_driver_app/models/driver.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service_interface.dart';
import 'package:delivery_driver_app/services/service_provider.dart';

class ProfileViewModel with ChangeNotifier {
  final FirebaseServiceInterface _firebaseService = ServiceProvider.getFirebaseService();
  
  Driver? _driver;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  Driver? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Constructor to initialize driver profile
  ProfileViewModel() {
    _loadDriverProfile();
  }
  
  Future<void> _loadDriverProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _driver = await _firebaseService.getDriverProfile();
    } catch (e) {
      _errorMessage = 'Failed to load driver profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh driver profile from the server
  Future<void> refreshProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _driver = await _firebaseService.getDriverProfile();
    } catch (e) {
      _errorMessage = 'Failed to refresh profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update driver location
  Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      final bool success = await _firebaseService.updateDriverLocation(
        latitude,
        longitude,
      );
      
      if (success && _driver != null) {
        _driver = _driver!.copyWith(
          lastLatitude: latitude,
          lastLongitude: longitude,
          lastLocationUpdate: DateTime.now(),
        );
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error updating location: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}