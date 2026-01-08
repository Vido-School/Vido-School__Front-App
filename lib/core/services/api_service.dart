import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/api_config.dart';

class ApiService {
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Future<dynamic> get({
    required String url,
    String? token,
    bool retry = true,
  }) async {
    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 401 && retry) {
        // Tentative de rafraîchissement du token
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Réessayer avec le nouveau token
          return get(url: url, token: newToken, retry: false);
        }
      }

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print('Erreur dans ApiService.get: $e');
      throw Exception("Erreur de connexion: ${e.toString()}");
    }
  }


  static Future<String?> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        await prefs.setString('access_token', newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      print('Erreur lors du rafraîchissement du token: $e');
    }
    return null;
  }



  static Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
    String? token,
    Map<String, String>? customHeaders,
    bool forcePlainContentType = false,
  }) async {
    try {
      final headers = {...defaultHeaders, ...?customHeaders};

      // Override Content-Type si demandé
      if (forcePlainContentType) {
        headers["Content-Type"] = "text/plain";
      } else {
        headers["Content-Type"] = "application/json";
      }

      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final uri = Uri.parse(url);
      final request = http.Request("POST", uri)
        ..headers.addAll(headers)
        ..bodyBytes = utf8.encode(jsonEncode(body));

      final streamedResponse = await request.send().timeout(
        Duration(seconds: ApiConfig.requestTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(message: "Erreur de connexion: ${e.message}");
    } on TimeoutException {
      throw ApiException(message: "La requête a expiré (timeout)");
    } on FormatException {
      throw ApiException(message: "Format de réponse invalide");
    } catch (e) {
      throw ApiException(message: "Erreur inattendue: ${e.toString()}");
    }
  }

  static dynamic _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        final errorMsg = _extractErrorMessage(response, decoded);
        throw ApiException(
          message: errorMsg,
          statusCode: response.statusCode,
          responseData: decoded,
        );
      }
    } catch (e) {
      // En cas de réponse non JSON
      return _handleFallbackError(response);
    }
  }

  static dynamic _handleFallbackError(http.Response response) {
    throw ApiException(
      message: "Erreur serveur (${response.statusCode}): ${response.body}",
      statusCode: response.statusCode,
      responseData: response.body,
    );
  }

  static String _extractErrorMessage(http.Response response, dynamic decoded) {
    if (response.headers['content-type']?.contains('json') ?? false) {
      return decoded['message'] ??
          decoded['error'] ??
          decoded['detail'] ??
          decoded['title'] ??
          "Erreur serveur (${response.statusCode})";
    }
    return "Erreur serveur (${response.statusCode}): ${response.body}";
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException({required this.message, this.statusCode, this.responseData});

  @override
  String toString() => message;
}
