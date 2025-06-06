import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapnbook/shared/constants/categories.dart';
import '../../../../state/booking_provider.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../../../config.dart';
import '../../../../state/auth_provider.dart';

class ConfirmBookingSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConfirmBookingSheet> createState() =>
      _ConfirmBookingSheetState();
}

class _ConfirmBookingSheetState extends ConsumerState<ConfirmBookingSheet> {
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(bookingProvider);
    final user = ref.read(authProvider);
    final selectedDate = provider.selectedDate;
    final selectedTime = provider.selectedTime;
    final appliance = provider.applianceType ?? "Not selected";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Confirm Booking",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _InfoRow(
            label: "Date",
            value:
                selectedDate?.toLocal().toString().split(' ')[0] ??
                "Not selected",
          ),
          _InfoRow(label: "Time", value: selectedTime ?? "Not selected"),
          _InfoRow(
            label: "Appliance",
            value: getDisplayName(appliance) ?? appliance,
          ),

          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Confirm Booking',
            onPressed: () async {
              print('[DEBUG] Confirm Booking button pressed');
              try {
                final appliance = provider.applianceType ?? 'Unknown';
                final date = provider.selectedDate;
                final time = provider.selectedTime;

                if (date == null || time == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please complete all booking details'),
                    ),
                  );
                  return;
                }

                print('[DEBUG] Preparing booking request...');
                // 1. Convert date + time to ISO timestamp
                final DateTime dateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  _parseHour(time),
                  _parseMinute(time),
                );

                final isoTime = dateTime.toIso8601String();

                // 2. Construct request body
                final bookingBody = {
                  "userId": user!.userId,
                  "appliance": getDisplayName(appliance),
                  "preferredTime": isoTime,
                  "issue": "",
                  "bookingAmount": getPrice(appliance),
                };

                // 3. Make API call
                final url = Uri.parse(AppConfig.createBookingUrl);

                print('[DEBUG] Sending booking request to $url');
                print('[DEBUG] Request body: ${jsonEncode(bookingBody)}');
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(bookingBody),
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  if (!mounted) return;
                  final bookingResponse = jsonDecode(response.body);
                  final bookingId = bookingResponse['bookingId'] ?? 'N/A';
                  print(
                    '[DEBUG] Booking API responded with status: ${response.statusCode}',
                  );
                  print('[DEBUG] Response body: ${response.body}');
                  context.push('/confirmation/$bookingId');
                } else {
                  print('Error response: ${response.body}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking failed. Try again.')),
                  );
                }
              } catch (e) {
                print('API error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Something went wrong')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

int _parseHour(String timeStr) {
  final parts = timeStr.split(' ');
  final time = parts[0].split(':');
  int hour = int.parse(time[0]);
  final isPM = parts[1].toUpperCase() == 'PM';
  if (isPM && hour != 12) hour += 12;
  if (!isPM && hour == 12) hour = 0;
  return hour;
}

int _parseMinute(String timeStr) {
  return int.parse(timeStr.split(' ')[0].split(':')[1]);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
