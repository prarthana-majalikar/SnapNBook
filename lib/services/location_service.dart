import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class TechnicianLocationService {
  final String technicianId;
  final String bookingId;
  Timer? _timer;
  final Location _location = Location();

  TechnicianLocationService(this.technicianId, this.bookingId);

  void startLocationUpdates() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _sendLocation());
  }

  void stopLocationUpdates() {
    _timer?.cancel();
  }

  Future<void> _sendLocation() async {
    final currentLocation = await _location.getLocation();

    final response = await http.post(
      Uri.parse('https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/technician/updateTechnicianLocation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingId': bookingId,
        'lat': currentLocation.latitude,
        'lon': currentLocation.longitude,
      }),
    );

    print('[📡 Location Sent] ${response.statusCode}: ${response.body}');
  }
}
