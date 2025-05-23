import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:snapnbook/config.dart';

final bookingConfirmationProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, bookingId) async {
      final response = await http.get(
        Uri.parse(AppConfig.getBookingUrl(bookingId)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load booking details');
      }
    });

class ConfirmationPage extends ConsumerWidget {
  final String bookingId;

  const ConfirmationPage({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingConfirmationProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmation")),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (booking) {
          final appliance = booking['appliance'] ?? 'N/A';
          final status = booking['status'] ?? 'N/A';
          final address = booking['address'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  "Booking Confirmed!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRow("Booking ID", booking['bookingId']),
                        _buildRow("Appliance", appliance),
                        _buildRow(
                          "Date & Time",
                          _formatDateTime(booking['preferredTime']),
                        ),
                        _buildRow(
                          "Status",
                          _capitalize(status.replaceAll('_', ' ')),
                        ),
                        _buildRow("Address", address),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}

String _formatDateTime(String isoDate) {
  final dt = DateTime.tryParse(isoDate);
  if (dt == null) return 'N/A';
  return DateFormat.yMMMMd().add_jm().format(dt); // e.g. May 12, 2025 2:00 PM
}
