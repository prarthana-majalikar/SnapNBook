import 'package:flutter_riverpod/flutter_riverpod.dart';

class Booking {
  final String service;
  final String status;
  final String subtitle;

  Booking(this.service, this.status, this.subtitle);
}

// Simulated backend data
final bookingProvider = StateProvider<List<Booking>>((ref) => []);
