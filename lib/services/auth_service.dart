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

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Login failed: $e');
      return null;
    }
  }

  static Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mobile,
    required String address,
    required String pincode,
    String role = 'user',
  }) async {
    final res = await http.post(
      Uri.parse(AppConfig.signupUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstname': firstName,
        'lastname': lastName,
        'email': email,
        'password': password,
        'mobile': mobile,
        'address': address,
        'pincode': pincode,
        'role': role,
      }),
    );

    print('SIGNUP STATUS: ${res.statusCode}');
    print('SIGNUP BODY: ${res.body}');

    return res.statusCode == 201 || res.statusCode == 200;
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
}
