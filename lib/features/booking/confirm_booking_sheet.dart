import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/booking_provider.dart';
import '../../shared/widgets/primary_button.dart';
import 'confirmation_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
          _InfoRow(label: "Appliance", value: appliance),
          _InfoRow(label: "Address", value: "123 Main St, City, Country"),
          _InfoRow(label: "Price", value: "\$50"),
          // const SizedBox(height: 15),
          // TextField(
          //   controller: addressController,
          //   decoration: const InputDecoration(
          //     labelText: "Address",
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Confirm Booking',
            // onPressed: () {
            //   final address = addressController.text.trim();
            //   if (address.isEmpty) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Please enter your address')),
            //     );
            //     return;
            //   }

            //   Navigator.of(context).pop();
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(
            //         'Booking Confirmed for $appliance on ${selectedDate?.toLocal().toString().split(' ')[0]} at $selectedTime',
            //       ),
            //     ),
            //   );
            // },
            onPressed: () async {
              print('[DEBUG] Confirm Booking button pressed');
              try {
                final appliance = provider.applianceType ?? 'Unknown';
                final date = provider.selectedDate;
                final time = provider.selectedTime;
                final address =
                    addressController.text.trim().isEmpty
                        ? "Test address"
                        : addressController.text.trim();

                print('appliance: $appliance');
                print('date: $date');
                print('time: $time');
                print('address: $address');

                if (date == null || time == null || address.isEmpty) {
                  print('empty fields');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please complete all booking details'),
                    ),
                  );
                  print('returning...');
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

                final isoTime = dateTime.toUtc().toIso8601String();

                // 2. Construct request body
                final bookingBody = {
                  "userId": "u555", // Dummy user
                  "appliance": appliance,
                  "issue": "Scratches", // Dummy issue for now
                  "address": address,
                  "preferredTime": isoTime,
                  "location": {"lat": 37.7749, "lon": -122.4194},
                };

                // 3. Make API call
                final url = Uri.parse(
                  "https://yzs6j2oypb.execute-api.us-east-1.amazonaws.com/development/v1/bookings",
                );

                print('[DEBUG] Sending booking request to $url');
                print('[DEBUG] Request body: ${jsonEncode(bookingBody)}');
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(bookingBody),
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ConfirmationPage(
                            appliance: appliance,
                            selectedDate:
                                date.toLocal().toString().split(' ')[0],
                            selectedTime: time,
                          ),
                    ),
                  );
                  print(
                    '[DEBUG] Booking API responded with status: ${response.statusCode}',
                  );
                  print('[DEBUG] Response body: ${response.body}');
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
