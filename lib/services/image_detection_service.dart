import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:snapnbook/config.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, String>?> detectFirstObjectFromImage(File imageFile) async {
  final uri = Uri.parse('http://54.80.90.249:8000/analyze');

  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseData);

    final appliance = json['appliance'] as String?;
    final issue = json['issue'] as String?;

    if (appliance != null && issue != null) {
      return {
        'appliance': appliance,
        'issue': issue,
      };
    } else {
      return null;
    }
  } else {
    throw Exception(
      'Object detection failed with status code: ${response.statusCode}',
    );
  }
}