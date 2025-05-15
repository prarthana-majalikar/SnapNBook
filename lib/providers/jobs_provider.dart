import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config.dart';
import '../../../../state/auth_provider.dart';

final jobsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userSession = ref.watch(authProvider);
  if (userSession == null || userSession.userId.isEmpty) {
    throw Exception('User not logged in');
  }
  final technicianId = userSession.userId;
  print(
    '[DEBUG] Technician ID: $technicianId',
  ); // Debugging line to check the technician ID
  final response = await http.get(
    Uri.parse(AppConfig.getJobsUrl(technicianId)),
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization':
      //     'Bearer your_token_here', // ⛔ Replace with real token logic
    },
  );
  print(
    '[DEBUG] Jobs response: ${response.body}',
  ); // Debugging line to check the response
  print(
    '[DEBUG] Jobs status code: ${response.statusCode}',
  ); // Debugging line to check the status code

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['bookings'];
    print('Jobs data: $data'); // Debugging line to check the response
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load jobs');
  }
});
