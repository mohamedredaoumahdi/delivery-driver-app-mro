// lib/services/firebase/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/models/driver.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service_interface.dart';

/// Implementation of FirebaseServiceInterface that connects to the real Firebase backend
class FirebaseService implements FirebaseServiceInterface {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Firestore collection references
  CollectionReference get _driversCollection => 
      _firestore.collection('drivers');
  CollectionReference get _ordersCollection => 
      _firestore.collection('orders');
  
  @override
  Future<String?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      return null;
    }
  }
  
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  @override
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }
  
  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
  
  @override
  Future<List<DeliveryOrder>> getAssignedOrders() async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      final QuerySnapshot snapshot = await _ordersCollection
          .where('driverId', isEqualTo: userId)
          .get();
      
      return snapshot.docs
          .map((doc) => DeliveryOrder.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting assigned orders: $e');
      return [];
    }
  }
  
  @override
  Future<DeliveryOrder?> getOrderById(String orderId) async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      final DocumentSnapshot doc = await _ordersCollection.doc(orderId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Verify that this order belongs to the current driver
      if (data['driverId'] != userId) {
        throw Exception('Order does not belong to the current driver');
      }
      
      return DeliveryOrder.fromMap(data);
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }
  
  @override
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      // First, get the current order to verify ownership
      final DocumentSnapshot doc = await _ordersCollection.doc(orderId).get();
      
      if (!doc.exists) {
        return false;
      }
      
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Verify that this order belongs to the current driver
      if (data['driverId'] != userId) {
        throw Exception('Order does not belong to the current driver');
      }
      
      // Update status and relevant timestamps
      final Map<String, dynamic> updates = {
        'status': newStatus.toString().split('.').last,
      };
      
      if (newStatus == OrderStatus.pickedUp) {
        updates['pickupTime'] = FieldValue.serverTimestamp();
      } else if (newStatus == OrderStatus.delivered) {
        updates['deliveryTime'] = FieldValue.serverTimestamp();
      }
      
      await _ordersCollection.doc(orderId).update(updates);
      
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
  
  @override
  Future<bool> confirmPickup(String orderId, String qrCode) async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      // First, get the current order
      final DocumentSnapshot doc = await _ordersCollection.doc(orderId).get();
      
      if (!doc.exists) {
        return false;
      }
      
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Verify that this order belongs to the current driver
      if (data['driverId'] != userId) {
        throw Exception('Order does not belong to the current driver');
      }
      
      // Verify QR code
      if (data['qrCodePickup'] != qrCode) {
        return false;
      }
      
      // Update status to pickedUp and set pickup time
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.pickedUp.toString().split('.').last,
        'pickupTime': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error confirming pickup: $e');
      return false;
    }
  }
  
  @override
  Future<bool> confirmDelivery(String orderId, String qrCode) async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      // First, get the current order
      final DocumentSnapshot doc = await _ordersCollection.doc(orderId).get();
      
      if (!doc.exists) {
        return false;
      }
      
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Verify that this order belongs to the current driver
      if (data['driverId'] != userId) {
        throw Exception('Order does not belong to the current driver');
      }
      
      // Verify QR code
      if (data['qrCodeDelivery'] != qrCode) {
        return false;
      }
      
      // Check if order has been picked up
      if (data['status'] != OrderStatus.pickedUp.toString().split('.').last) {
        return false;
      }
      
      // Update status to delivered and set delivery time
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.delivered.toString().split('.').last,
        'deliveryTime': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error confirming delivery: $e');
      return false;
    }
  }
  
  @override
  Stream<List<DeliveryOrder>> ordersStream() {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    return _ordersCollection
        .where('driverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DeliveryOrder.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }
  
  @override
  Future<Driver?> getDriverProfile() async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      final DocumentSnapshot doc = await _driversCollection.doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return Driver.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting driver profile: $e');
      return null;
    }
  }
  
  @override
  Future<bool> updateDriverLocation(double latitude, double longitude) async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not signed in');
    }
    
    try {
      await _driversCollection.doc(userId).update({
        'lastLatitude': latitude,
        'lastLongitude': longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error updating driver location: $e');
      return false;
    }
  }
  
  @override
  Future<void> setupNotifications() async {
    // Request permission for notifications
    final NotificationSettings settings = await _messaging.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted');
      
      // Subscribe to driver-specific topic
      final String? userId = getCurrentUserId();
      if (userId != null) {
        await _messaging.subscribeToTopic('driver_$userId');
      }
      
      // Subscribe to general drivers topic
      await _messaging.subscribeToTopic('all_drivers');
    } else {
      print('Notification permission denied');
    }
  }
  
  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

}