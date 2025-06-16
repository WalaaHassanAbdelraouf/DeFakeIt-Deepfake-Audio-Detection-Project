import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:defakeit/core/constant/APIs_constants.dart';

Future<bool> sendFeedback(String type, String text) async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  if (token == null) {
    print("No token found");
    return false;
  }

  final url =
      Uri.parse('${APIsConstants.baseURL}${APIsConstants.feedbackEndpoint}');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'feedback_type': type, // "Good" or "Issue"
        'feedback_text': text,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Feedback sent successfully");
      return true;
    } else if (response.statusCode == 401) {
      print("Feedback failed: Invalid or expired token");
      return false;
    } else {
      print("Feedback failed: ${response.statusCode} - ${response.body}");
      return false;
    }
  } on http.ClientException catch (e) {
    print("Network error: $e");
    return false;
  } catch (e) {
    print("Unexpected error: $e");
    return false;
  }
}
