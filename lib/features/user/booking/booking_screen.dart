import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/booking_provider.dart';
import '../../../../shared/widgets/date_slider.dart';
import '../../../../shared/widgets/time_slot_button.dart';
import 'confirm_booking_sheet.dart';

class BookingScreen extends ConsumerWidget {
  final List<String> availableSlots = [
    '10:00 AM',
    '12:00 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(bookingProvider);
    final applianceType = provider.applianceType ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text('Book a Service for $applianceType')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateSlider(
            selectedDate: provider.selectedDate ?? DateTime.now(),
            onDateSelected: provider.setDate,
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Available Time Slots:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
            spacing: 10,
            children:
                availableSlots.map((slot) {
                  return TimeSlotButton(
                    time: slot,
                    isSelected: provider.selectedTime == slot,
                    onPressed: () {
                      ref.read(bookingProvider).setTime(slot);
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => ConfirmBookingSheet(),
                      );
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
