import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final jobsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await http.get(
    Uri.parse(
      'https://yourapi.com/api/technician/jobs',
    ), // 🔁 Replace with actual URL
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
