import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../state/auth_provider.dart';

final assignedJobsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userSession = ref.watch(authProvider);
  if (userSession == null || userSession.userId.isEmpty) {
    throw Exception('User not logged in');
  }
  final technicianId = userSession.userId;
  final response = await http.get(
    Uri.parse(AppConfig.getJobsUrl(technicianId)),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    final List<dynamic> jobs = jsonDecode(response.body)['bookings'];
    return jobs
        .where((job) => job['status']?.toString().toUpperCase() == 'ASSIGNED')
        .cast<Map<String, dynamic>>()
        .toList();
  } else {
    throw Exception('Failed to load assigned jobs');
  }
});
