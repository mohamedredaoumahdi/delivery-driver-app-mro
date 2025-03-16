// lib/services/firebase/firebase_service_interface.dart

import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/models/driver.dart';

/// Interface defining the contract for Firebase services
abstract class FirebaseServiceInterface {
  /// Authentication methods
  Future<String?> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> isSignedIn();
  String? getCurrentUserId();
  
  /// Orders methods
  Future<List<DeliveryOrder>> getAssignedOrders();
  Future<DeliveryOrder?> getOrderById(String orderId);
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<bool> confirmPickup(String orderId, String qrCode);
  Future<bool> confirmDelivery(String orderId, String qrCode);
  Stream<List<DeliveryOrder>> ordersStream();
  
  /// Driver profile methods
  Future<Driver?> getDriverProfile();
  Future<bool> updateDriverLocation(double latitude, double longitude);
  
  /// Notifications
  Future<void> setupNotifications();
  Future<String?> getDeviceToken();
}