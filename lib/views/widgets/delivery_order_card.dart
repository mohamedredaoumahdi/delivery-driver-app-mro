// lib/views/widgets/delivery_order_card.dart

import 'package:flutter/material.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';
import 'package:intl/intl.dart';

class DeliveryOrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback onTap;
  
  const DeliveryOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(order.id.length - 5).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person, order.customerName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, order.address),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                _formatDateTime(order.assignedTime),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    String statusText;
    
    switch (order.status) {
      case OrderStatus.pending:
        backgroundColor = Colors.amber;
        statusText = 'Pending';
        break;
      case OrderStatus.pickedUp:
        backgroundColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green;
        statusText = 'Delivered';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: backgroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy \'at\' h:mm a');
    return formatter.format(dateTime);
  }
}