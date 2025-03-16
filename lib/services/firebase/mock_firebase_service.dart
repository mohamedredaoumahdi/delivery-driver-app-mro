// lib/services/firebase/mock_firebase_service.dart

import 'dart:async';
import 'dart:math';

import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/models/driver.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service_interface.dart';

/// A mock implementation of the Firebase service for development purposes
class MockFirebaseService implements FirebaseServiceInterface {
  // Mock user data
  String? _currentUserId;
  bool _isSignedIn = false;
  
  // Mock data storage
  final List<DeliveryOrder> _orders = [];
  Driver? _driverProfile;
  final StreamController<List<DeliveryOrder>> _ordersStreamController = 
      StreamController<List<DeliveryOrder>>.broadcast();
  
  // Constructor to initialize mock data
  MockFirebaseService() {
    _initializeMockData();
  }
  
  void _initializeMockData() {
    // Create mock driver
    _driverProfile = Driver(
      id: 'driver_001',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      profileImageUrl: 'https://avatarfiles.alphacoders.com/370/370978.jpeg',
      assignedRoutes: ['Route A', 'Route B', 'Downtown'],
      lastLatitude: 37.7749,
      lastLongitude: -122.4194,
      lastLocationUpdate: DateTime.now(),
    );
    
    // Create mock orders
    final List<DeliveryOrder> mockOrders = [
      DeliveryOrder(
        id: 'order_001',
        customerId: 'customer_001',
        customerName: 'Alice Johnson',
        phoneNumber: '+1987654321',
        address: '123 Main St, Anytown, CA',
        latitude: 37.7858,
        longitude: -122.4064,
        qrCodePickup: 'pickup_001',
        qrCodeDelivery: 'delivery_001',
        assignedTime: DateTime.now().subtract(const Duration(hours: 2)),
        status: OrderStatus.pending,
        items: [
          OrderItem(
            id: 'item_001',
            name: 'Large Package',
            quantity: 1,
            notes: 'Handle with care',
          ),
        ],
      ),
      DeliveryOrder(
        id: 'order_002',
        customerId: 'customer_002',
        customerName: 'Bob Smith',
        phoneNumber: '+1122334455',
        address: '456 Oak St, Sometown, CA',
        latitude: 37.7694,
        longitude: -122.4862,
        qrCodePickup: 'pickup_002',
        qrCodeDelivery: 'delivery_002',
        assignedTime: DateTime.now().subtract(const Duration(hours: 1)),
        status: OrderStatus.pending,
        items: [
          OrderItem(
            id: 'item_002',
            name: 'Small Package',
            quantity: 2,
            notes: null,
          ),
          OrderItem(
            id: 'item_003',
            name: 'Document Envelope',
            quantity: 1,
            notes: 'Signature required',
          ),
        ],
      ),
      DeliveryOrder(
        id: 'order_003',
        customerId: 'customer_003',
        customerName: 'Carol Williams',
        phoneNumber: '+1567891234',
        address: '789 Pine St, Othertown, CA',
        latitude: 37.7948,
        longitude: -122.3936,
        qrCodePickup: 'pickup_003',
        qrCodeDelivery: 'delivery_003',
        assignedTime: DateTime.now().subtract(const Duration(minutes: 30)),
        pickupTime: DateTime.now().subtract(const Duration(minutes: 15)),
        status: OrderStatus.pickedUp,
        items: [
          OrderItem(
            id: 'item_004',
            name: 'Medium Package',
            quantity: 1,
            notes: 'Leave at door if no answer',
          ),
        ],
      ),
    ];
    
    _orders.addAll(mockOrders);
    _ordersStreamController.add(_orders);
  }
  
  @override
  Future<String?> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock auth logic
    if (email == 'driver@example.com' && password == 'password123') {
      _currentUserId = 'driver_001';
      _isSignedIn = true;
      return _currentUserId;
    }
    
    // Return null for failed login
    return null;
  }
  
  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUserId = null;
    _isSignedIn = false;
  }
  
  @override
  Future<bool> isSignedIn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _isSignedIn;
  }
  
  @override
  String? getCurrentUserId() {
    return _currentUserId;
  }
  
  @override
  Future<List<DeliveryOrder>> getAssignedOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    return _orders;
  }
  
  @override
  Future<DeliveryOrder?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null; // Order not found
    }
  }
  
  @override
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    try {
      final int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) {
        return false; // Order not found
      }
      
      // Update order with new status
      final DeliveryOrder updatedOrder = _orders[index].copyWith(
        status: newStatus,
        pickupTime: newStatus == OrderStatus.pickedUp ? DateTime.now() : _orders[index].pickupTime,
        deliveryTime: newStatus == OrderStatus.delivered ? DateTime.now() : _orders[index].deliveryTime,
      );
      
      _orders[index] = updatedOrder;
      
      // Notify listeners
      _ordersStreamController.add(_orders);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> confirmPickup(String orderId, String qrCode) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    try {
      final int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) {
        return false; // Order not found
      }
      
      // Check if QR code matches
      if (_orders[index].qrCodePickup != qrCode) {
        return false; // Invalid QR code
      }
      
      // Update order status to pickedUp
      final DeliveryOrder updatedOrder = _orders[index].copyWith(
        status: OrderStatus.pickedUp,
        pickupTime: DateTime.now(),
      );
      
      _orders[index] = updatedOrder;
      
      // Notify listeners
      _ordersStreamController.add(_orders);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> confirmDelivery(String orderId, String qrCode) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    try {
      final int index = _orders.indexWhere((order) => order.id == orderId);
      if (index == -1) {
        return false; // Order not found
      }
      
      // Check if QR code matches
      if (_orders[index].qrCodeDelivery != qrCode) {
        return false; // Invalid QR code
      }
      
      // Check if order has been picked up
      if (_orders[index].status != OrderStatus.pickedUp) {
        return false; // Order must be picked up first
      }
      
      // Update order status to delivered
      final DeliveryOrder updatedOrder = _orders[index].copyWith(
        status: OrderStatus.delivered,
        deliveryTime: DateTime.now(),
      );
      
      _orders[index] = updatedOrder;
      
      // Notify listeners
      _ordersStreamController.add(_orders);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Stream<List<DeliveryOrder>> ordersStream() {
    return _ordersStreamController.stream;
  }
  
  @override
  Future<Driver?> getDriverProfile() async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    return _driverProfile;
  }
  
  @override
  Future<bool> updateDriverLocation(double latitude, double longitude) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_isSignedIn) {
      throw Exception('User not signed in');
    }
    
    try {
      _driverProfile = _driverProfile?.copyWith(
        lastLatitude: latitude,
        lastLongitude: longitude,
        lastLocationUpdate: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> setupNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock implementation - in a real app, this would register the device token
    print('Mock notification setup complete');
  }
  
  @override
  Future<String?> getDeviceToken() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return a fake device token
    return 'mock_fcm_device_token_${Random().nextInt(10000)}';
  }
  
  // Clean up resources
  void dispose() {
    _ordersStreamController.close();
  }
}