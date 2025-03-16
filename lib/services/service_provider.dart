// lib/services/service_provider.dart

import 'package:delivery_driver_app/config/MyKeysConfig.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service_interface.dart';
import 'package:delivery_driver_app/services/firebase/mock_firebase_service.dart';

/// A service provider for dependency injection of services
class ServiceProvider {
  static FirebaseServiceInterface? _firebaseService;
  
  /// Get the Firebase service instance (real or mock based on configuration)
  static FirebaseServiceInterface getFirebaseService() {
    if (_firebaseService == null) {
      if (MyKeysConfig.useMockServices) {
        _firebaseService = MockFirebaseService();
      } else {
        _firebaseService = FirebaseService();
      }
    }
    
    return _firebaseService!;
  }
  
  /// Reset all services (useful for testing or when signing out)
  static void reset() {
    if (_firebaseService is MockFirebaseService) {
      (_firebaseService as MockFirebaseService).dispose();
    }
    _firebaseService = null;
  }
}