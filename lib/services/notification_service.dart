// lib/services/notification_service.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:delivery_driver_app/viewmodels/delivery_orders_viewmodel.dart';

class NotificationService {
  final DeliveryOrdersViewModel _ordersViewModel;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Constructor
  NotificationService(this._ordersViewModel) {
    _initializeNotifications();
  }
  
  // Initialize notification channels and handlers
  Future<void> _initializeNotifications() async {
    // Configure local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS notification when app is in foreground
      },
    );
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleNotificationTap(details.payload);
      },
    );
    
    // Create Android notification channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'delivery_channel',
        'Delivery Notifications',
        description: 'Notifications related to delivery orders',
        importance: Importance.high,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle when user taps on notification and opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;
    
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'delivery_channel',
            'Delivery Notifications',
            channelDescription: 'Notifications related to delivery orders',
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['orderId'],
      );
    }
    
    // Refresh orders when we receive a notification about new or updated orders
    if (message.data.containsKey('type') && message.data['type'] == 'order_update') {
      _ordersViewModel.refreshOrders();
    }
  }
  
  // Handle when user taps on a notification
  void _handleNotificationOpen(RemoteMessage message) {
    if (message.data.containsKey('orderId')) {
      final String orderId = message.data['orderId'];
      _handleNotificationTap(orderId);
    }
  }
  
  // Handle notification tap
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      // Select the order related to the notification
      _ordersViewModel.selectOrder(payload);
    }
  }
  
  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
      return false;
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to ensure Firebase is initialized here if using other Firebase services
  
  // Handle background message
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}