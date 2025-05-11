import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/booking_provider.dart';
import '../../shared/widgets/primary_button.dart';
import 'confirmation_page.dart';

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
            onPressed: () {
              final formattedDate =
                  selectedDate?.toLocal().toString().split(' ')[0] ??
                  "Not selected";
              final time = selectedTime ?? "Not selected";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ConfirmationPage(
                        appliance: appliance,
                        selectedDate: formattedDate,
                        selectedTime: time,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
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
