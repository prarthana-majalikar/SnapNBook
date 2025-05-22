import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
    String role,
  ) async {
    try {
      final fcmToken = 1;

      final res = await http.post(
        Uri.parse(AppConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
          'fcmToken': fcmToken,
        }),
      );

      print('LOGIN STATUS: ${res.statusCode}');
      print('LOGIN BODY: ${res.body}');

      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        final message = decoded is Map && decoded.containsKey('message')
            ? decoded['message']
            : decoded.toString(); // fallback for plain strings
        return {'error': message};
      }
    } catch (e) {
      print('❌ Login failed: $e');
      return {'error': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mobile,
    required String address,
    required String pincode,
    String role = 'user',
    List<String>? skills,
  }) async {
    final body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
      'mobile': mobile,
      'address': address,
      'pincode': pincode,
      'role': role,
    };

    if (role == 'technician' && skills != null && skills.isNotEmpty) {
      body['skills'] = jsonEncode(skills);
    }

    final res = await http.post(
      Uri.parse(AppConfig.signupUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('SIGNUP STATUS: ${res.statusCode}');
    print('SIGNUP BODY: ${res.body}');

    try {
      final decoded = jsonDecode(res.body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        return {'success': true};
      } else {
        final message = decoded is Map && decoded.containsKey('message')
            ? decoded['message']
            : decoded.toString();
        return {'success': false, 'error': message};
      }
    } catch (e) {
      return {'success': false, 'error': 'Unexpected server response'};
    }
  }

  static Future<bool> confirmSignup(
    String email,
    String code, {
    String role = 'user',
  }) async {
    final res = await http.post(
      Uri.parse(AppConfig.confirmUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'role': role}),
    );

    print('CONFIRM STATUS: ${res.statusCode}');
    print('CONFIRM BODY: ${res.body}');

    return res.statusCode == 200;
  }

  static Future<bool> updateAccount({
    required String id,
    required String role,
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final baseUrl = 'https://nl9w2g6wra.execute-api.us-east-1.amazonaws.com/production';
    final url = Uri.parse('$baseUrl/AccountDetails/$id');

    final res = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    print('STATUS: ${res.statusCode}');
    print('BODY: ${res.body}');

    return res.statusCode == 200;
  }
}
