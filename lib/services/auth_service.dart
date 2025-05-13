import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String loginUrl =
      'https://za5l26ep8e.execute-api.us-east-1.amazonaws.com/devlopment/v1/login';
  static const String signupUrl =
      'https://za5l26ep8e.execute-api.us-east-1.amazonaws.com/devlopment/v1/signup';

  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
    String role,
  ) async {
    final res = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    print('LOGIN STATUS: ${res.statusCode}');
    print('LOGIN BODY: ${res.body}');

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
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
      Uri.parse(signupUrl),
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
    const String confirmUrl =
        'https://za5l26ep8e.execute-api.us-east-1.amazonaws.com/devlopment/v1/confirm-signup';

    final res = await http.post(
      Uri.parse(confirmUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'role': role}),
    );

    print('CONFIRM STATUS: ${res.statusCode}');
    print('CONFIRM BODY: ${res.body}');

    return res.statusCode == 200;
  }
}
