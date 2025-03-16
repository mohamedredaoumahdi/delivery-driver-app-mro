// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service_interface.dart';
import 'package:delivery_driver_app/services/service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseServiceInterface _firebaseService = ServiceProvider.getFirebaseService();
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userId;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get errorMessage => _errorMessage;
  
  // Constructor to check if user is already logged in
  AuthViewModel() {
    _checkCurrentUser();
  }
  
  Future<void> _checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check if user is signed in with Firebase
      final bool isSignedIn = await _firebaseService.isSignedIn();
      
      if (isSignedIn) {
        _userId = _firebaseService.getCurrentUserId();
        _isLoggedIn = true;
        
        // Set up notifications
        await _firebaseService.setupNotifications();
      } else {
        // Check if user credentials are stored locally
        final bool hasStoredCredentials = await _checkStoredCredentials();
        
        if (hasStoredCredentials) {
          // Auto-login with stored credentials
          final prefs = await SharedPreferences.getInstance();
          final String? email = prefs.getString('user_email');
          final String? password = prefs.getString('user_password');
          
          if (email != null && password != null) {
            await signIn(email, password, true);
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to check user status: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> _checkStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('user_email') && prefs.containsKey('user_password');
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> signIn(String email, String password, [bool rememberMe = false]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final String? result = await _firebaseService.signIn(email, password);
      
      if (result != null) {
        _userId = result;
        _isLoggedIn = true;
        
        // Store credentials if remember me is checked
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
          await prefs.setString('user_password', password);
        }
        
        // Set up notifications
        await _firebaseService.setupNotifications();
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Sign in failed: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firebaseService.signOut();
      
      // Clear stored credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_password');
      
      _isLoggedIn = false;
      _userId = null;
      
      // Reset services
      ServiceProvider.reset();
    } catch (e) {
      _errorMessage = 'Sign out failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}