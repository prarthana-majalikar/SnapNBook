// booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({Key? key, required this.booking}) : super(key: key);

  String _formatDateTime(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return 'N/A';
    return DateFormat.yMMMMd().add_jm().format(dt);
  }

  Future<Map<String, dynamic>?> _fetchTechnician(String technicianId) async {
    try {
      final response = await http.get(
        Uri.parse('https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/AccountDetails/$technicianId'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile(Icons.confirmation_number, 'Booking ID', booking['bookingId']),
                _infoTile(Icons.calendar_today, 'Date & Time', _formatDateTime(booking['preferredTime'])),
                _infoTile(Icons.tv, 'Appliance', booking['appliance']),
                _infoTile(Icons.home, 'Address', booking['address']),
                _infoTile(Icons.info_outline, 'Status', status),

                if (status != 'PENDING_ASSIGNMENT' && technicianId != null)
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
                          child: Text('Could not load technician details.', style: TextStyle(color: Colors.red)),
                        );
                      }

                      final tech = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text('Assigned Technician',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _infoTile(Icons.person, 'Name',
                              '${tech['firstname'] ?? ''} ${tech['lastname'] ?? ''}'),
                          _infoTile(Icons.phone, 'Phone', tech['mobile'] ?? 'N/A'),
                          _infoTile(Icons.email, 'Email', tech['email'] ?? 'N/A'),

                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/track/$technicianId');
                            },
                            icon: const Icon(Icons.location_on),
                            label: const Text("Track Technician"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade100,
                              foregroundColor: Colors.black,
                            ),
                          ),

                          if (status == 'COMPLETED')
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.payment),
                                label: const Text("Pay Now"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // TODO: Trigger payment intent logic and show Stripe payment sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Payment flow coming next 🚀')),
                                  );
                                },
                              ),
                            )
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
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
