// lib/models/driver.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final List<String> assignedRoutes;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastLocationUpdate;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.assignedRoutes,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationUpdate,
  });

  // Create a Driver from a map (e.g., from Firestore)
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      assignedRoutes: List<String>.from(map['assignedRoutes'] ?? []),
      lastLatitude: map['lastLatitude'],
      lastLongitude: map['lastLongitude'],
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? (map['lastLocationUpdate'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert a Driver to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'assignedRoutes': assignedRoutes,
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
      'lastLocationUpdate': lastLocationUpdate,
    };
  }

  // Create a copy of this Driver with updated fields
  Driver copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? assignedRoutes,
    double? lastLatitude,
    double? lastLongitude,
    DateTime? lastLocationUpdate,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      assignedRoutes: assignedRoutes ?? this.assignedRoutes,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
}