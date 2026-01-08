import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {


  // Getters
 
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;

  // Méthode de connexion
  


   String? _token;
  UserModel? _user;

  String? get token => _token; // Ajoutez ce getter

  Future<void> login(String token, UserModel user, {String? refreshToken}) async {
    _token = token;
    _user = user;
    
    // Sauvegarder les tokens dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    
    notifyListeners();
  }

  // Méthode de déconnexion
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken != null) {
        await AuthService.logout(refreshToken: refreshToken);
      }

      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      _token = null;
      _user = null;
      notifyListeners();
      
      // Rediriger vers l'écran de login
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //   '/login',
      //   (route) => false,
      // );
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }



  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    
    if (accessToken == null) return null;
    
    // Vérifier si le token est expiré (simplifié)
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(accessToken.split('.')[1]))
    );
    final exp = payload['exp'] as int;
    final isExpired = DateTime.fromMillisecondsSinceEpoch(exp * 1000)
      .isBefore(DateTime.now());
    
    if (isExpired) {
      return await _refreshToken();
    }
    
    return accessToken;
  }

  Future<String?> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    
    if (refreshToken == null) return null;
    
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        await prefs.setString('access_token', newAccessToken);
        _token = newAccessToken;
        return newAccessToken;
      }
    } catch (e) {
      print('Erreur de rafraîchissement: $e');
      await logout();
    }
    return null;
  }

  

  // Méthode pour vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return _token != null && _user != null;
  }
}
