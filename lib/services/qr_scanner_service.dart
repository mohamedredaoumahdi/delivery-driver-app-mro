import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerService {
  QRViewController? _controller;
  bool _isScanning = false;
  void Function(String)? _onQrCodeScanned;
  
  // Getter for controller
  QRViewController? get controller => _controller;
  
  // Getter to check if scanning is active
  bool get isScanning => _isScanning;
  
  // Initialize the QR code scanner
  void initializeScanner(QRViewController controller, void Function(String) onQrCodeScanned) {
    _controller = controller;
    _onQrCodeScanned = onQrCodeScanned;
    _isScanning = true;
    
    // Set up the scanner
    _controller?.scannedDataStream.listen((scanData) {
      if (_isScanning && scanData.code != null) {
        _handleScannedCode(scanData.code!);
      }
    });
  }
  
  // Handle the scanned QR code
  void _handleScannedCode(String code) {
    // Temporarily pause scanning to prevent multiple scans
    _isScanning = false;
    
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    
    // Call the callback with the scanned code
    if (_onQrCodeScanned != null) {
      _onQrCodeScanned!(code);
    }
  }
  
  // Resume scanning
  void resumeScanning() {
    _isScanning = true;
  }
  
  // Pause scanning
  void pauseScanning() {
    _isScanning = false;
  }
  
  // Toggle flash
  Future<void> toggleFlash() async {
    try {
      await _controller?.toggleFlash();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling flash: $e');
      }
    }
  }
  
  // Flip camera between front and back
  Future<void> flipCamera() async {
    try {
      await _controller?.flipCamera();
    } catch (e) {
      if (kDebugMode) {
        print('Error flipping camera: $e');
      }
    }
  }
  
  // Dispose of resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}