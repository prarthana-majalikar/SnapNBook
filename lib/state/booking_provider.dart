import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingProvider extends ChangeNotifier {
  DateTime? selectedDate;
  String? selectedTime;
  String? applianceType;

  void setApplianceType(String appliance) {
    applianceType = appliance;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  void clearSelection() {
    selectedDate = null;
    selectedTime = null;
    notifyListeners();
  }
}

final bookingProvider = ChangeNotifierProvider((ref) => BookingProvider());
