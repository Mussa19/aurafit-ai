import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class APIService {
  // Твой базовый URL. 
  // ВНИМАНИЕ: Если ты тестируешь локально на Windows, 
  // используй "http://127.0.0.1:5000", если на Android-эмуляторе - "http://10.0.2.2:5000"
  static const String _baseUrl = "https://api.aurafit-ai.com/v1";

  // --- Стандартный GET ---
  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse("$_baseUrl/$endpoint"));
    return _handleResponse(response);
  }

  // --- Стандартный POST ---
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // --- Отправка фото для AI анализа ---
  static Future<Map<String, dynamic>> uploadImage(String endpoint, File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/$endpoint"));
    
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  // Вспомогательный метод для обработки ошибок
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // Полезно для дебага в консоли
      debugPrint("API Error: ${response.statusCode} - ${response.body}");
      throw Exception("API Error: ${response.statusCode}");
    }
  }
}

import 'package:flutter/foundation.dart';