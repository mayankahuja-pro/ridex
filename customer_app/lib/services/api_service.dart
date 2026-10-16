import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class ApiService {

// post request with optional token
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return await http.post(
      Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );
  }
// get request with optional token
  Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return await http.get(
      Uri.parse("${ApiConstants.baseUrl}$endpoint"),
      headers: headers,
    );
  }

// get list of data from endpoint with optional token
  Future<List<dynamic>> getList(
  String endpoint, {
  String? token,
}) async {
  final response = await get(
    endpoint,
    token: token,
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to load data",
    );
  }

  return jsonDecode(response.body)
      as List<dynamic>;
}
}