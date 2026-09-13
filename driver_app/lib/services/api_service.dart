import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class ApiService {
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] =
          "Bearer $token";
    }

    return await http.post(
      Uri.parse(
        "${ApiConstants.baseUrl}$endpoint",
      ),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] =
          "Bearer $token";
    }

    return await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}$endpoint",
      ),
      headers: headers,
    );
  }
}