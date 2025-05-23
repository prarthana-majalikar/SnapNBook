import 'dart:convert';
import 'package:http/http.dart' as http;

class JobService {
  static Future<List<Map<String, dynamic>>> fetchJobsForTechnician(
    String technicianId,
  ) async {
    final url =
        'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/getBookingsofUserOrTechnician/$technicianId';
    print('[JobService] Fetching jobs from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print('[JobService] Status code: ${response.statusCode}');
    print('[JobService] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }

      if (decoded is Map<String, dynamic> && decoded.containsKey('bookings')) {
        return List<Map<String, dynamic>>.from(decoded['bookings']);
      }

      throw Exception('Unexpected response structure: $decoded');
    } else {
      throw Exception('Failed to load jobs: ${response.statusCode}');
    }
  }

  static Future<bool> acceptBooking(
    String bookingId,
    String technicianId,
  ) async {
    final response = await http.post(
      Uri.parse(
        'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/bookings/acceptBooking',
      ),
      body: jsonEncode({'bookingId': bookingId, 'technicianId': technicianId}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  static Future<bool> cancelBooking(String bookingId) async {
    final response = await http.post(
      Uri.parse(
        'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/bookings/cancelBooking',
      ),
      body: jsonEncode({'bookingId': bookingId}),
      //TODO: should cancel with just the bookingId TEST when API is ready
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  static Future<bool> declineBooking(
    String bookingId,
    String technicianId,
  ) async {
    final response = await http.post(
      Uri.parse(
        'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/bookings/cancelBooking', //TODO update correct api
      ),
      body: jsonEncode({'bookingId': bookingId, 'technicianId': technicianId}),
      //TODO:  TEST when API is ready
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  static Future<bool> markBookingCompleted(
    String bookingId,
    String technicianId,
  ) async {
    final response = await http.post(
      Uri.parse(
        'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production/bookings/markCompleted',
      ),
      body: jsonEncode({'bookingId': bookingId, 'technicianId': technicianId}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}
