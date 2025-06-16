import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:defakeit/core/constant/APIs_constants.dart';

Future<String?> updateUser(String username, String email,
    {bool rememberMe = true}) async {
  final url =
      Uri.parse('${APIsConstants.baseURL}${APIsConstants.updateUserEndpoint}');
  final storage = const FlutterSecureStorage();

  try {
    final token = await storage.read(key: 'token');
    if (token == null) {
      print("Update Failed: No token found");
      return null;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['token'] as String?;
      final message = data['message'] as String?;

      if (newToken != null) {
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'email', value: email);
        await storage.write(key: 'token', value: newToken);

        print("Update Success. New Token: $newToken, Message: $message");
        return newToken;
      }
    }
    print("Update Failed: ${response.body}");
    return null;
  } catch (e) {
    print("Update Error: $e");
    return null;
  }
}
