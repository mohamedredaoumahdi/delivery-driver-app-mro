// lib/views/screens/order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:delivery_driver_app/viewmodels/delivery_orders_viewmodel.dart';
import 'package:delivery_driver_app/views/widgets/custom_app_bar.dart';
import 'package:delivery_driver_app/views/widgets/loading_indicator.dart';
import 'package:delivery_driver_app/views/widgets/status_badge.dart';
import 'package:delivery_driver_app/views/widgets/action_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryOrdersViewModel>(
      builder: (context, ordersViewModel, _) {
        final DeliveryOrder? order = ordersViewModel.selectedOrder;

        if (order == null) {
          // Create a more graceful fallback if there's no selected order
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Order Details',
            ),
            body: const Center(
              child: Text('No order selected. Please select an order from the home screen.'),
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Order Details',
            onBackPressed: () {
              // Just navigate back without clearing the selected order here
              Navigator.of(context).pop();
            },
          ),
          body: ordersViewModel.isLoading
              ? const LoadingIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderHeader(context, order),
                      const SizedBox(height: 24),
                      _buildCustomerInfo(context, order),
                      const SizedBox(height: 24),
                      _buildOrderItems(context, order),
                      const SizedBox(height: 24),
                      _buildOrderTimeline(context, order),
                      const SizedBox(height: 32),
                      _buildActionButtons(context, ordersViewModel, order),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Clear the selected order when the screen is disposed
    // This ensures navigation completes before state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ordersViewModel = Provider.of<DeliveryOrdersViewModel>(context, listen: false);
        ordersViewModel.clearSelectedOrder();
      }
    });
    super.dispose();
  }

  Widget _buildOrderHeader(BuildContext context, DeliveryOrder order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length - 5).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(order.assignedTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                StatusBadge(status: order.status, large: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, DeliveryOrder order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.person,
              title: 'Name',
              value: order.customerName,
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.phone,
              title: 'Phone',
              value: order.phoneNumber,
              isPhone: true,
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.location_on,
              title: 'Address',
              value: order.address,
              isAddress: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, DeliveryOrder order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.inventory_2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Text(
                              item.notes!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context, DeliveryOrder order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              title: 'Order Assigned',
              time: order.assignedTime,
              isCompleted: true,
              isFirst: true,
            ),
            _buildTimelineItem(
              title: 'Picked Up',
              time: order.pickupTime,
              isCompleted: order.status == OrderStatus.pickedUp || 
                          order.status == OrderStatus.delivered,
              isFirst: false,
            ),
            _buildTimelineItem(
              title: 'Delivered',
              time: order.deliveryTime,
              isCompleted: order.status == OrderStatus.delivered,
              isFirst: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, 
    DeliveryOrdersViewModel viewModel, 
    DeliveryOrder order
  ) {
    switch (order.status) {
      case OrderStatus.pending:
        return ActionButton(
          label: 'Scan QR for Pickup',
          icon: Icons.qr_code_scanner,
          onPressed: () {
            // Navigate to QR scanner page for pickup confirmation
            Navigator.of(context).pushNamed(
              '/qr-scanner',
              arguments: {
                'orderId': order.id,
                'mode': 'pickup',
              },
            );
          },
          isFullWidth: true,
          color: Theme.of(context).primaryColor,
        );
        
      case OrderStatus.pickedUp:
        return Column(
          children: [
            ActionButton(
              label: 'Navigate to Customer',
              icon: Icons.navigation,
              onPressed: () {
                _openMapsNavigation(order.latitude, order.longitude);
              },
              isFullWidth: true,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: 'Scan QR for Delivery',
              icon: Icons.qr_code_scanner,
              onPressed: () {
                // Navigate to QR scanner page for delivery confirmation
                Navigator.of(context).pushNamed(
                  '/qr-scanner',
                  arguments: {
                    'orderId': order.id,
                    'mode': 'delivery',
                  },
                );
              },
              isFullWidth: true,
              color: Theme.of(context).primaryColor,
            ),
          ],
        );
        
      case OrderStatus.delivered:
        return Column(
          children: [
            const Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Order Delivered Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isPhone = false,
    bool isAddress = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (isPhone)
          _buildActionIcon(
            icon: Icons.phone,
            color: Colors.green,
            onTap: () => _launchPhone(value),
          ),
        if (isAddress)
          _buildActionIcon(
            icon: Icons.navigation,
            color: Colors.blue,
            onTap: () => _openMapsNavigation(null, null, address: value),
          ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required DateTime? time,
    required bool isCompleted,
    required bool isFirst,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey[300],
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time != null
                    ? _formatDateTime(time)
                    : 'Pending',
                style: TextStyle(
                  color: isCompleted ? Colors.black87 : Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy \'at\' h:mm a');
    return formatter.format(dateTime);
  }

  void _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMapsNavigation(double? lat, double? lng, {String? address}) async {
    Uri uri;
    
    if (lat != null && lng != null) {
      // Use coordinates for navigation
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'
      );
    } else if (address != null) {
      // Use address for navigation
      final encodedAddress = Uri.encodeComponent(address);
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress&travelmode=driving'
      );
    } else {
      return;
    }
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}