import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSlider extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  DateSlider({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            dates.map((date) {
              final isSelected =
                  date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.E()
                            .format(date)
                            .toUpperCase(), // SUN, MON, etc
                      ),
                      Text(date.day.toString()),
                    ],
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (_) => onDateSelected(date),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
