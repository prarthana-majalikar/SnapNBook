import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class BookingTrackingScreen extends StatefulWidget {
  final String technicianId;

  const BookingTrackingScreen({Key? key, required this.technicianId}) : super(key: key);

  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Marker? _techMarker;
  Marker? _userMarker;
  Timer? _pollingTimer;
  static const Duration _pollInterval = Duration(seconds: 5);

  Set<Polyline> _polylines = {};
  String? _durationText;
  String? _distanceText;

  @override
  void initState() {
    super.initState();
    _initUserLocation();
    _startPollingTechnician();
  }

  void _startPollingTechnician() {
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _fetchTechnicianLocation());
  }

  Future<void> _initUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permission permanently denied.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _userMarker = Marker(
        markerId: const MarkerId('user'),
        position: userLatLng,
        infoWindow: const InfoWindow(title: "You"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    });

    if (_controller.isCompleted) {
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(userLatLng));
    }
  }

  Future<void> _fetchTechnicianLocation() async {
    final url = Uri.parse('https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/technician/getTechnicianLocation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'technicianId': widget.technicianId}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final lat = double.tryParse(body['lat'].toString());
        final lng = double.tryParse(body['lon'].toString());

        if (lat != null && lng != null) {
          final newLatLng = LatLng(lat, lng);
          _animateMarker(newLatLng);
          await _updateRouteAndDistance(newLatLng);
        }
      } else {
        print('❌ Failed to fetch technician location: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during technician location fetch: $e');
    }
  }

  void _animateMarker(LatLng newLatLng) async {
    setState(() {
      _techMarker = Marker(
        markerId: const MarkerId('technician'),
        position: newLatLng,
        infoWindow: const InfoWindow(title: "Technician"),
      );
    });

    if (_controller.isCompleted) {
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(newLatLng));
    }
  }

  Future<void> _updateRouteAndDistance(LatLng techLocation) async {
    if (_userMarker == null) return;

    final origin = "${techLocation.latitude},${techLocation.longitude}";
    final destination = "${_userMarker!.position.latitude},${_userMarker!.position.longitude}";
    final apiKey = 'AIzaSyC3nV1fRLF9zt3C6SgnNxmCv_lvyRB5XW0';

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 4,
          points: points,
        );

        final leg = data['routes'][0]['legs'][0];
        setState(() {
          _polylines = {polyline};
          _durationText = leg['duration']['text'];
          _distanceText = leg['distance']['text'];
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Technician")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.6436, -117.8419),
              zoom: 14,
            ),
            markers: {
              if (_techMarker != null) _techMarker!,
              if (_userMarker != null) _userMarker!,
            },
            polylines: _polylines,
            onMapCreated: (controller) => _controller.complete(controller),
          ),
          if (_durationText != null && _distanceText != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'ETA: $_durationText, Distance: $_distanceText',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
