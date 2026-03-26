import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8081/api';

  /// Récupère tous les modèles depuis la BDD
  static Future<List<Product3D>> fetchModeles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/modeles'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => Product3D.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Erreur lors du chargement des modèles: $e');
      return [];
    }
  }

  /// Récupère le détail d'un modèle (avec commentaires)
  static Future<Product3D?> fetchModeleDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/modeles/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Product3D.fromJson(Map<String, dynamic>.from(data['data']));
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors du chargement du détail modèle: $e');
      return null;
    }
  }

  /// Ajoute un modèle en BDD
  static Future<bool> addModele({
    required String name,
    String? description,
    double? prix,
    int? auteur,
    String? url,
    String? categorie,
    int? nbPolygone,
    bool animation = false,
    bool ringing = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modeles'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description ?? '',
          'prix': prix ?? 0.0,
          'auteur': auteur ?? 0,
          'url': url ?? '',
          'categorie': categorie ?? '',
          'nb_polygone': nbPolygone ?? 0,
          'animation': animation,
          'ringing': ringing,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout du modèle: $e');
      return false;
    }
  }

  /// Ajoute un commentaire sous un modèle (avec idUser)
  static Future<bool> addComment(int modeleId, String description, int idUser) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modeles/$modeleId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': description,
          'idUser': idUser,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout du commentaire: $e');
      return false;
    }
  }

  /// Récupère les modèles postés par un utilisateur
  static Future<List<Product3D>> fetchUserModeles(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId/modeles'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => Product3D.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Erreur lors du chargement des modèles utilisateur: $e');
      return [];
    }
  }

  /// Modifie un modèle existant
  static Future<bool> updateModele({
    required int id,
    required String name,
    String? description,
    double? prix,
    String? url,
    String? categorie,
    int? nbPolygone,
    bool animation = false,
    bool ringing = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/modeles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description ?? '',
          'prix': prix ?? 0.0,
          'url': url ?? '',
          'categorie': categorie ?? '',
          'nb_polygone': nbPolygone ?? 0,
          'animation': animation,
          'ringing': ringing,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la modification du modèle: $e');
      return false;
    }
  }

  /// Supprime un modèle
  static Future<bool> deleteModele(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/modeles/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la suppression du modèle: $e');
      return false;
    }
  }
}
