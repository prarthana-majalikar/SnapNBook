import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({Key? key, required this.booking})
    : super(key: key);

  String _formatDateTime(String isoDate) {
    print("ISO Date: $isoDate"); // Debugging line to check the input
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return 'N/A';
    return DateFormat.yMMMMd().add_jm().format(dt); // e.g. May 12, 2025 2:00 PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile(
                  Icons.confirmation_number,
                  'Booking ID',
                  booking['bookingId'],
                ),
                _infoTile(
                  Icons.calendar_today,
                  'Date & Time',
                  _formatDateTime(booking['preferredTime']),
                ),
                _infoTile(Icons.tv, 'Appliance', booking['appliance']),
                _infoTile(Icons.home, 'Address', booking['address']),
                _infoTile(Icons.info_outline, 'Status', booking['status']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
