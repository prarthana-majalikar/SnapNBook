import 'package:flutter/material.dart';

class TimeSlotButton extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onPressed;

  const TimeSlotButton({
    required this.time,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        foregroundColor:
            isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(time),
    );
  }
}
