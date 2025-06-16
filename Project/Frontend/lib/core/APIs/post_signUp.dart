import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:defakeit/core/constant/APIs_constants.dart';

Future<String?> signup(String username, String email, String password,
    {bool rememberMe = true}) async {
  final url =
      Uri.parse('${APIsConstants.baseURL}${APIsConstants.signUpEndPoint}');
  final storage = const FlutterSecureStorage();

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String?;
      if (token != null) {
        if (rememberMe) {
          await storage.write(key: 'email', value: email);
          await storage.write(key: 'password', value: password);
          await storage.write(key: 'token', value: token);
          await storage.write(key: 'username', value: username);
        }
        print("Signup Success. Token: $token");
        return token;
      }
    }
    print("Signup Failed: ${response.body}");
    return null;
  } catch (e) {
    print("Signup Error: $e");
    return null;
  }
}
