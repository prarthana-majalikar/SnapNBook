import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:snapnbook/config.dart';

Future<String?> detectFirstObjectFromImage(File imageFile) async {
  final uri = Uri.parse(AppConfig.objectDetectionUrl);

  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final Map<String, dynamic> json = jsonDecode(responseData);

    final List detections = json['detections'] ?? [];
    print('[DEBUG] detections: $detections');

    if (detections.isNotEmpty) {
      return detections[0]['class_name'] as String;
    } else {
      return null;
    }
  } else {
    throw Exception(
      'Object detection failed with status code: ${response.statusCode}',
    );
  }
}
