// lib/views/screens/qr_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:delivery_driver_app/viewmodels/delivery_orders_viewmodel.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/services/qr_scanner_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final QrScannerService _scannerService = QrScannerService();
  
  QRViewController? _controller;
  String? _orderId;
  String? _mode;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _showScanner = true;
  bool _isSuccess = false;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1.0).animate(_animationController);
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scannerService.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
    
    // Initialize scanner service with the controller
    _scannerService.initializeScanner(controller, _onCodeScanned);
  }

  void _onCodeScanned(String qrCode) async {
    if (_isProcessing || _orderId == null || _mode == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();
    
    final DeliveryOrdersViewModel ordersViewModel = 
        Provider.of<DeliveryOrdersViewModel>(context, listen: false);
    
    bool success = false;
    try {
      if (_mode == 'pickup') {
        success = await ordersViewModel.confirmPickup(_orderId!, qrCode);
      } else if (_mode == 'delivery') {
        success = await ordersViewModel.confirmDelivery(_orderId!, qrCode);
      }
      
      setState(() {
        _showScanner = false;
        _isSuccess = success;
        _errorMessage = ordersViewModel.errorMessage;
      });
      
      if (success) {
        // If this was a scan without a specific order (from home screen),
        // refresh all orders
        if (_orderId == null) {
          await ordersViewModel.refreshOrders();
        }
      }
    } catch (e) {
      setState(() {
        _showScanner = false;
        _isSuccess = false;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    await _scannerService.toggleFlash();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _resetScanner() {
    setState(() {
      _showScanner = true;
      _isSuccess = false;
      _errorMessage = null;
      _isProcessing = false;
    });
    
    _scannerService.resumeScanning();
  }

  @override
  Widget build(BuildContext context) {
    // Get the route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _orderId = args?['orderId'];
    _mode = args?['mode'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.black,
      ),
      body: _showScanner ? _buildScanner() : _buildResultScreen(),
    );
  }

  String _getTitle() {
    if (_mode == 'pickup') {
      return 'Scan for Pickup';
    } else if (_mode == 'delivery') {
      return 'Scan for Delivery';
    } else {
      return 'QR Scanner';
    }
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        QRView(
          key: _qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.8,
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: _isFlashOn ? Icons.flash_off : Icons.flash_on,
                label: _isFlashOn ? 'Flash Off' : 'Flash On',
                onPressed: _toggleFlash,
              ),
              const SizedBox(width: 24),
              _buildControlButton(
                icon: Icons.close,
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              _getScanInstructions(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 120,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).primaryColor,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                transform: Matrix4.translationValues(
                  0,
                  _animation.value * 240 - 120,
                  0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSuccess ? Icons.check_circle : Icons.error,
                color: _isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                _isSuccess ? _getSuccessMessage() : 'Scan Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? (_isSuccess 
                    ? 'QR code scanned successfully'
                    : 'Please try scanning again'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isSuccess)
                    ElevatedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (!_isSuccess)
                    const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSuccess 
                          ? Theme.of(context).primaryColor
                          : Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getScanInstructions() {
    if (_mode == 'pickup') {
      return 'Scan the QR code at the warehouse to confirm pickup';
    } else if (_mode == 'delivery') {
      return 'Scan the QR code at the delivery location to confirm delivery';
    } else {
      return 'Scan any delivery QR code';
    }
  }

  String _getSuccessMessage() {
    if (_mode == 'pickup') {
      return 'Pickup Confirmed!';
    } else if (_mode == 'delivery') {
      return 'Delivery Completed!';
    } else {
      return 'QR Code Scanned!';
    }
  }
}