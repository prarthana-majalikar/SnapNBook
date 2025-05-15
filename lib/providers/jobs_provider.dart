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
  final response = await http.get(
    Uri.parse(AppConfig.getJobsUrl(technicianId)),
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization':
      //     'Bearer your_token_here', // ⛔ Replace with real token logic
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load jobs');
  }
});
