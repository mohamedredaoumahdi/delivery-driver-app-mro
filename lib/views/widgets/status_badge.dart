// lib/views/widgets/status_badge.dart

import 'package:flutter/material.dart';
import 'package:delivery_driver_app/models/delivery_order.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool large;
  
  const StatusBadge({
    Key? key,
    required this.status,
    this.large = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;
    
    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.amber;
        textColor = Colors.black87;
        statusText = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case OrderStatus.pickedUp:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        statusText = 'In Progress';
        icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        statusText = 'Delivered';
        icon = Icons.check_circle;
        break;
    }
    
    final double fontSize = large ? 14.0 : 12.0;
    final double iconSize = large ? 18.0 : 14.0;
    final EdgeInsets padding = large
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(large ? 20 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}