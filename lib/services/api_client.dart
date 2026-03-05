import "dart:convert";

import "package:http/http.dart" as http;

import "../config/app_config.dart";

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await _httpClient.get(
      _buildUri(path),
      headers: _buildHeaders(token),
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _httpClient.post(
      _buildUri(path),
      headers: _buildHeaders(token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    return _parseResponse(response);
  }

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith("/") ? path : "/$path";
    return Uri.parse("${AppConfig.apiBaseUrl}$normalizedPath");
  }

  Map<String, String> _buildHeaders(String? token) {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final responseBody = response.body.trim();
    dynamic decoded;

    if (responseBody.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(responseBody);
      } catch (_) {
        throw ApiException(
          statusCode: response.statusCode,
          message: "Server returned invalid JSON response",
        );
      }
    }

    final payload = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{"data": decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    final message = (payload["message"] ?? payload["error"] ?? "Request failed")
        .toString();

    throw ApiException(statusCode: response.statusCode, message: message);
  }
}
