import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/booking_provider.dart';
import '../../../../shared/widgets/date_slider.dart';
import '../../../../shared/widgets/time_slot_button.dart';
import 'confirm_booking_sheet.dart';

class BookingScreen extends ConsumerWidget {
  final List<String> availableSlots = _generateTimeSlots(
    startHour: 9,
    endHour: 17,
    intervalMinutes: 30,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(bookingProvider);
    final applianceType = provider.applianceType ?? 'Unknown';
    final selectedDate = provider.selectedDate ?? DateTime.now();

    // Auto-set today's date if not selected
    if (provider.selectedDate == null) {
      ref.read(bookingProvider).setDate(DateTime.now());
    }

    final now = DateTime.now();
    final bufferTime = now.add(const Duration(minutes: 20));

    // Filter available time slots
    List<String> filteredSlots =
        availableSlots.where((slot) {
          if (!isSameDate(selectedDate, now)) return true;

          final slotTime = _parseTime(slot, selectedDate);
          return slotTime.isAfter(bufferTime);
        }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Book a Service for $applianceType')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateSlider(
            selectedDate: selectedDate,
            onDateSelected: provider.setDate,
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Available Time Slots:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (filteredSlots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No available time slots. Try another date.'),
            )
          else
            Wrap(
              spacing: 10,
              children:
                  filteredSlots.map((slot) {
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

// Helper function
List<String> _generateTimeSlots({
  required int startHour,
  required int endHour,
  int intervalMinutes = 30,
}) {
  final slots = <String>[];
  final now = DateTime.now();

  DateTime time = DateTime(now.year, now.month, now.day, startHour, 0);
  final end = DateTime(now.year, now.month, now.day, endHour, 0);

  while (time.isBefore(end)) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    slots.add('$hour:$minute $period');
    time = time.add(Duration(minutes: intervalMinutes));
  }

  return slots;
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime _parseTime(String timeStr, DateTime date) {
  final parts = timeStr.split(' ');
  final timeParts = parts[0].split(':');
  int hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);
  final isPM = parts[1].toUpperCase() == 'PM';

  if (isPM && hour != 12) hour += 12;
  if (!isPM && hour == 12) hour = 0;

  return DateTime(date.year, date.month, date.day, hour, minute);
}
