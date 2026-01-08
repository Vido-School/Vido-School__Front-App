import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/api_endpoints.dart';
import '../models/advisor_profile.dart';
import 'api_service.dart';
import '../models/user_model.dart';


class AuthService {
  // Connexion avec récupération du token et des infos utilisateur
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = {"email": email, "password": password};

      // 1. Authentification pour obtenir le token
      final authResponse = await ApiService.post(
        url: ApiEndpoints.login,
        body: body,
      );

      final token = authResponse['access'];
      final refreshToken = authResponse['refresh'];
      
      if (token == null) {
        throw Exception("Aucun token reçu dans la réponse");
      }

      // 2. Récupération des données utilisateur
      final userResponse = await ApiService.get(
        url: ApiEndpoints.userProfile,
        token: token,
      );

      final user = UserModel.fromJson(userResponse);

      return {
        'token': token, 
        'refreshToken': refreshToken,
        'user': user
      };
    } catch (e) {
      throw Exception("Erreur de connexion: ${e.toString()}");
    }
  }


  static Future<bool> logout({required String refreshToken}) async {
  try {
    final response = await ApiService.post(
      url: ApiEndpoints.logout,
      body: {'refresh_token': refreshToken},
    );

    // Supprimer les tokens du stockage local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    return response['success'] ?? false;
  } catch (e) {
    debugPrint('Logout error: $e');
    return false;
  }
}

  // Récupérer l'utilisateur actuellement connecté
  static Future<UserModel> getCurrentUser({required String token}) async {
    try {
      final response = await ApiService.get(
        url: ApiEndpoints.userProfile,
        token: token,
      );

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception("Impossible de récupérer le profil: ${e.toString()}");
    }
  }

  // Inscription enseignant avec fichiers
  static Future<Map<String, dynamic>> registerTeacher({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> teacherData,
    required Map<String, String> files,
  }) async {
    try {
      // 1. Create multipart request
      final uri = Uri.parse(ApiEndpoints.registerTeacher);
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json';

      // 2. Add all fields
      request.fields.addAll({
        ..._convertMapToStringFields(userData),
        ..._convertMapToStringFields(teacherData),
      });

      // 3. Add files
      await _addFilesToRequest(request, files);

      // 4. Send request with timeout
      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      // 5. Process response
      final responseBody = await response.stream.bytesToString();
      debugPrint('Server response: $responseBody');

      if (response.statusCode == 201) {
        return _handleSuccessResponse(responseBody);
      } else {
        return _handleErrorResponse(response.statusCode, responseBody);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Server timeout');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Helper methods
  static Map<String, String> _convertMapToStringFields(
    Map<String, dynamic> data,
  ) {
    final Map<String, String> fields = {};

    data.forEach((key, value) {
      if (value != null) {
        fields[key] = value is Map || value is List
            ? jsonEncode(value)
            : value.toString();
      }
    });

    return fields;
  }

  static Future<void> _addFilesToRequest(
    http.MultipartRequest request,
    Map<String, String> files,
  ) async {
    for (final entry in files.entries) {
      if (entry.value.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          entry.key,
          entry.value,
          filename: entry.value.split('/').last,
        );
        request.files.add(file);
      }
    }
  }

  static Map<String, dynamic> _handleSuccessResponse(String responseBody) {
    final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

    return {
      'success': true,
      'user': responseData['user'] ?? {},
      'tokens': responseData['tokens'] ?? {},
      'message': 'Registration successful',
    };
  }

  static Map<String, dynamic> _handleErrorResponse(
    int statusCode,
    String responseBody,
  ) {
    final error = jsonDecode(responseBody);
    final errorMessage =
        error['detail'] ??
        error['message'] ??
        error['error'] ??
        'Server error ($statusCode)';

    return {
      'success': false,
      'message': errorMessage,
      'errors': error['errors'] ?? {},
    };
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
    } catch (e) {
      debugPrint('Error saving tokens: $e');
    }
  }

  // Inscription conseiller
  static Future<Map<String, dynamic>> registerAdvisor({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> advisorData,
    required PlatformFile? identityDocument,
    required PlatformFile? portfolioFile,
    required List<PlatformFile> certificationDocuments,
  }) async {
    final uri = Uri.parse(ApiEndpoints.registerAdvisor);
    final request = http.MultipartRequest('POST', uri);

    try {
      // Fusionner les données utilisateur et conseiller
      final allData = {...userData, ...advisorData};

      // Ajouter les champs texte
      allData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = (value is List || value is Map)
              ? jsonEncode(value)
              : value.toString();
        }
      });

      // Ajouter les fichiers
      if (identityDocument != null && identityDocument.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'identity_document',
            identityDocument.path!,
            filename: identityDocument.name,
          ),
        );
      }

      if (portfolioFile != null && portfolioFile.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'portfolio',
            portfolioFile.path!,
            filename: portfolioFile.name,
          ),
        );
      }

      // Documents de certification
      for (var doc in certificationDocuments) {
        if (doc.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'certification_documents',
              doc.path!,
              filename: doc.name,
            ),
          );
        }
      }

      // En-têtes
      request.headers.addAll({"Accept": "application/json"});

      // Envoi
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': decoded,
          'user': UserModel.fromJson(decoded['user'] ?? {}),
          'advisor': AdvisorProfile.fromJson(decoded['advisor'] ?? {}),
        };
      } else {
        throw Exception(
          decoded['message'] ??
              decoded['errors']?.toString() ??
              "Erreur lors de l'inscription (${response.statusCode})",
        );
      }
    } catch (e) {
      print(e);
      throw Exception("Erreur lors de l'inscription: ${e.toString()}");
    }
  }

  // Inscription étudiant
  static Future<Map<String, dynamic>> registerStudent({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await ApiService.post(
        url: ApiEndpoints.registerStudent,
        body: body,
      );

      // Nouvelle structure de réponse
      final userData = response['user'];
      final tokenData = response['token'];

      return {
        'success': true,
        'user': UserModel.fromJson(userData),
        'token': tokenData['access'], // Utilisez le token d'accès
        'refreshToken': tokenData['refresh'], // Token de rafraîchissement
      };
    } catch (e) {
      throw Exception("Erreur lors de l'inscription: ${e.toString()}");
    }
  }

  // Inscription élève
  static Future<Map<String, dynamic>> registerPupil({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.registerPupil),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'user': UserModel.fromJson(decoded)};
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error.toString());
      }
    } on TimeoutException {
      throw Exception("Le serveur a mis trop de temps à répondre");
    } on http.ClientException catch (e) {
      throw Exception("Erreur de connexion: ${e.message}");
    } catch (e) {
      throw Exception("Erreur lors de l'inscription: ${e.toString()}");
    }
  }

  // Inscription utilisateur de base
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String type,
  }) async {
    try {
      final body = {
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "type": type,
      };

      final response = await ApiService.post(
        url: ApiEndpoints.register,
        body: body,
      );

      return {
        'success': true,
        'data': response,
        'user': UserModel.fromJson(response['user'] ?? {}),
      };
    } catch (e) {
      throw Exception("Erreur lors de l'inscription: ${e.toString()}");
    }
  }

  // Récupération des notifications
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await ApiService.get(url: ApiEndpoints.notifications);
      return response['results'] ?? [];
    } catch (e) {
      throw Exception(
        'Erreur lors du chargement des notifications: ${e.toString()}',
      );
    }
  }

  // Demande de réinitialisation de mot de passe
  static Future<bool> requestPasswordReset({required String email}) async {
    try {
      final response = await ApiService.post(
        url: ApiEndpoints.passwordResetRequest,
        body: {'email': email},
      );
      return response['success'] ?? false;
    } catch (e) {
      throw Exception(
        'Erreur lors de la demande de réinitialisation: ${e.toString()}',
      );
    }
  }
}
