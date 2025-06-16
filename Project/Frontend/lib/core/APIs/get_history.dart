import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constant/APIs_constants.dart';

Future<List<Map<String, dynamic>>> getHistory(String token) async {
  final url =
      Uri.parse('${APIsConstants.baseURL}${APIsConstants.historyEndpoint}');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    print("Failed to fetch history: ${response.body}");
    return [];
  }
}
