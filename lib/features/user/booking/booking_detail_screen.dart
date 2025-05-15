import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON decoding

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

  Future<Map<String, dynamic>?> _fetchTechnician(String technicianId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/AccountDetails/$technicianId',
        ),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch technician: ${response.body}');
      }
    } catch (e) {
      print('Error fetching technician: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'];
    final technicianId = booking['assignedTechId'];
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

                if (status != 'Pending Assignment' && technicianId != null)
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchTechnician(technicianId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Could not load technician details.',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final tech = snapshot.data!;
                      print(
                        "Technician Data: $tech",
                      ); // Debugging line to check the technician data
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Assigned Technician',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _infoTile(
                            Icons.person,
                            'Name',
                            tech['firstname'] + " " + tech['lastname'] ?? 'N/A',
                          ),
                          _infoTile(
                            Icons.phone,
                            'Phone',
                            tech['mobile'] ?? 'N/A',
                          ),
                          _infoTile(
                            Icons.email,
                            'Email',
                            tech['email'] ?? 'N/A',
                          ),
                        ],
                      );
                    },
                  ),
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
