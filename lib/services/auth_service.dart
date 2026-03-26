import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  static const String baseUrl = 'http://localhost:8081/api';

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Connexion
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _currentUser = AppUser.fromJson(Map<String, dynamic>.from(data['data']));
        notifyListeners();
        return null; // pas d'erreur
      }
      return data['error']?.toString() ?? 'Erreur de connexion';
    } catch (e) {
      debugPrint('Erreur login: $e');
      return 'Impossible de se connecter au serveur';
    }
  }

  /// Inscription
  Future<String?> register(String firstName, String lastName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _currentUser = AppUser.fromJson(Map<String, dynamic>.from(data['data']));
        notifyListeners();
        return null; // pas d'erreur
      }
      return data['error']?.toString() ?? 'Erreur d\'inscription';
    } catch (e) {
      debugPrint('Erreur register: $e');
      return 'Impossible de se connecter au serveur';
    }
  }

  /// Déconnexion
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
