import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  // Replace this with your actual backend URL or an AI API endpoint
  static const String _baseUrl = "https://api.aurafit-ai.com/v1"; 

  // Generic GET request
  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse("$_baseUrl/$endpoint"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data from API");
    }
  }

  // POST request (Useful for sending food images or user goals)
  Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to post data to API");
    }
  }
}