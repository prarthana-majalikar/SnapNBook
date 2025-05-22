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
  print('[DEBUG] Technician ID: $technicianId');

  final response = await http.get(
    Uri.parse(AppConfig.getJobsUrl(technicianId)),
    headers: {'Content-Type': 'application/json'},
  );

  print('[DEBUG] Jobs response: ${response.body}');
  print('[DEBUG] Jobs status code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['bookings'];

    // 🔎 Optional client-side fallback filtering
    final acceptedJobs = data
        .where((job) =>
            job is Map &&
            job['status'] != null &&
            job['status'].toString().toUpperCase() == 'ACCEPTED')
        .cast<Map<String, dynamic>>()
        .toList();

    print('[DEBUG] Accepted Jobs: $acceptedJobs');
    return acceptedJobs;
  } else {
    throw Exception('Failed to load jobs');
  }
});
