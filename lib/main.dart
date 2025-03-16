// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:delivery_driver_app/config/MyKeysConfig.dart';
import 'package:delivery_driver_app/viewmodels/auth_viewmodel.dart';
import 'package:delivery_driver_app/viewmodels/delivery_orders_viewmodel.dart';
import 'package:delivery_driver_app/viewmodels/profile_viewmodel.dart';
import 'package:delivery_driver_app/views/screens/login_screen.dart';
import 'package:delivery_driver_app/views/screens/home_screen.dart';
import 'package:delivery_driver_app/views/screens/order_details_screen.dart';
import 'package:delivery_driver_app/views/screens/qr_scanner_screen.dart';
import 'package:delivery_driver_app/views/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase if not using mock services
  if (!MyKeysConfig.useMockServices) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: MyKeysConfig.firebaseApiKey,
        appId: MyKeysConfig.firebaseAppId,
        messagingSenderId: MyKeysConfig.firebaseMessagingSenderId,
        projectId: MyKeysConfig.firebaseProjectId,
        storageBucket: MyKeysConfig.firebaseStorageBucket,
        authDomain: MyKeysConfig.firebaseAuthDomain,
      ),
    );
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => DeliveryOrdersViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Delivery Driver App',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          home: authViewModel.isLoggedIn ? const HomeScreen() : const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/order-details': (context) => const OrderDetailsScreen(),
            '/qr-scanner': (context) => const QrScannerScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
          // Improved route guard that doesn't interfere with normal navigation
          onGenerateRoute: (settings) {
            // Don't interfere with normal navigation to known routes
            if (settings.name == '/login' || 
                settings.name == '/home' || 
                settings.name == '/order-details' || 
                settings.name == '/qr-scanner' || 
                settings.name == '/profile') {
              return null; // Let the named routes handle it
            }
            
            // For unknown routes, check authentication
            if (!authViewModel.isLoggedIn) {
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            }
            
            // Default unknown route to home
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          },
        );
      },
    );
  }
}