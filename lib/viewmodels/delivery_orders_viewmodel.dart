// lib/viewmodels/delivery_orders_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/services/firebase/firebase_service_interface.dart';
import 'package:delivery_driver_app/services/service_provider.dart';

class DeliveryOrdersViewModel with ChangeNotifier {
  final FirebaseServiceInterface _firebaseService = ServiceProvider.getFirebaseService();
  
  List<DeliveryOrder> _orders = [];
  DeliveryOrder? _selectedOrder;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<DeliveryOrder>>? _ordersSubscription;
  
  // Getters
  List<DeliveryOrder> get orders => _orders;
  List<DeliveryOrder> get pendingOrders => _orders.where((order) => order.status == OrderStatus.pending).toList();
  List<DeliveryOrder> get inProgressOrders => _orders.where((order) => order.status == OrderStatus.pickedUp).toList();
  List<DeliveryOrder> get completedOrders => _orders.where((order) => order.status == OrderStatus.delivered).toList();
  DeliveryOrder? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Constructor to initialize orders
  DeliveryOrdersViewModel() {
    _initializeOrders();
  }
  
  Future<void> _initializeOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Load initial orders
      _orders = await _firebaseService.getAssignedOrders();
      
      // Subscribe to order updates
      _ordersSubscription = _firebaseService.ordersStream().listen(
        (updatedOrders) {
          _orders = updatedOrders;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Error in orders stream: ${error.toString()}';
          notifyListeners();
        }
      );
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Select an order for viewing details
  void selectOrder(String orderId) {
    _selectedOrder = _orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => null as DeliveryOrder,
    );
    notifyListeners();
  }
  
  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }
  
  // Refresh orders from the server
  Future<void> refreshOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _orders = await _firebaseService.getAssignedOrders();
    } catch (e) {
      _errorMessage = 'Failed to refresh orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final bool success = await _firebaseService.updateOrderStatus(
        orderId,
        newStatus,
      );
      
      if (success) {
        // Update selected order if it was the one modified
        if (_selectedOrder != null && _selectedOrder!.id == orderId) {
          _selectedOrder = _selectedOrder!.copyWith(status: newStatus);
        }
      } else {
        _errorMessage = 'Failed to update order status';
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error updating order status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Confirm pickup with QR code
  Future<bool> confirmPickup(String orderId, String qrCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final bool success = await _firebaseService.confirmPickup(
        orderId,
        qrCode,
      );
      
      if (!success) {
        _errorMessage = 'Failed to confirm pickup. Please check the QR code.';
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error confirming pickup: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Confirm delivery with QR code
  Future<bool> confirmDelivery(String orderId, String qrCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final bool success = await _firebaseService.confirmDelivery(
        orderId,
        qrCode,
      );
      
      if (!success) {
        _errorMessage = 'Failed to confirm delivery. Please check the QR code.';
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error confirming delivery: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Clean up when ViewModel is no longer needed
  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}