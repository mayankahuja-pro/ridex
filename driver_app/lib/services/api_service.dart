import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class ApiService {
  
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    required String token,
  }) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}$endpoint",
    );

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return response;
  }
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