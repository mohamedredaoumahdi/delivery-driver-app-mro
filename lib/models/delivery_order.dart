// lib/models/delivery_order.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, pickedUp, delivered }

class DeliveryOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final String qrCodePickup;
  final String qrCodeDelivery;
  final DateTime assignedTime;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final OrderStatus status;
  final List<OrderItem> items;

  DeliveryOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.qrCodePickup,
    required this.qrCodeDelivery,
    required this.assignedTime,
    this.pickupTime,
    this.deliveryTime,
    required this.status,
    required this.items,
  });

  // Create a DeliveryOrder from a map (e.g., from Firestore)
  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      qrCodePickup: map['qrCodePickup'] ?? '',
      qrCodeDelivery: map['qrCodeDelivery'] ?? '',
      assignedTime: (map['assignedTime'] as Timestamp).toDate(),
      pickupTime: map['pickupTime'] != null ? (map['pickupTime'] as Timestamp).toDate() : null,
      deliveryTime: map['deliveryTime'] != null ? (map['deliveryTime'] as Timestamp).toDate() : null,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
    );
  }

  // Convert a DeliveryOrder to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'qrCodePickup': qrCodePickup,
      'qrCodeDelivery': qrCodeDelivery,
      'assignedTime': assignedTime,
      'pickupTime': pickupTime,
      'deliveryTime': deliveryTime,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  // Create a copy of this DeliveryOrder with updated fields
  DeliveryOrder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? qrCodePickup,
    String? qrCodeDelivery,
    DateTime? assignedTime,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    OrderStatus? status,
    List<OrderItem>? items,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrCodePickup: qrCodePickup ?? this.qrCodePickup,
      qrCodeDelivery: qrCodeDelivery ?? this.qrCodeDelivery,
      assignedTime: assignedTime ?? this.assignedTime,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final String? notes;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.notes,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'notes': notes,
    };
  }
}