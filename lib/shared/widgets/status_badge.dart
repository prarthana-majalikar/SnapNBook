import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({required this.status, Key? key}) : super(key: key);

  Color _getColor() {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING_ASSIGNMENT':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'ASSIGNED':
        return Colors.blue;
      case 'ACCEPTED':
        return Colors.lightGreen;
      case 'NO_TECH_AVAILABLE':
        return Colors.black54;
      case 'PAID':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.2),
        border: Border.all(color: _getColor()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getColor(),
        ),
      ),
    );
  }
}
