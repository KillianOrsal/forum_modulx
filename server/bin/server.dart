import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:dbcrypt/dbcrypt.dart';

// ── Configuration MySQL (BDD distante) ──
final mysqlSettings = ConnectionSettings(
  host: 'pma.myboard.pro',
  port: 3306,
  user: 'modulx',
  password: 'PasswordModulX',
  db: 'modulx_db',
);

Future<MySqlConnection> getConnection() async {
  return await MySqlConnection.connect(mysqlSettings);
}

// ── Middleware CORS ──
Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeadersMap);
      }
      final response = await handler(request);
      return response.change(headers: _corsHeadersMap);
    };
  };
}

const _corsHeadersMap = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// ── Routes ──
Router buildRouter() {
  final router = Router();
  final dbcrypt = DBCrypt();

  // ════════════════════════════════════════
  // AUTH ROUTES
  // ════════════════════════════════════════

  // POST /api/auth/login — Connexion
  router.post('/api/auth/login', (Request request) async {
    MySqlConnection? conn;
    try {
      final body = jsonDecode(await request.readAsString());
      final email = body['email']?.toString() ?? '';
      final password = body['password']?.toString() ?? '';

      if (email.isEmpty || password.isEmpty) {
        return Response(400,
            body: jsonEncode({'error': 'Email et mot de passe requis'}),
            headers: {'Content-Type': 'application/json'});
      }

      conn = await getConnection();
      final results = await conn.query(
        'SELECT * FROM user WHERE email = ?',
        [email],
      );

      if (results.isEmpty) {
        return Response(401,
            body: jsonEncode({'error': 'Email ou mot de passe incorrect'}),
            headers: {'Content-Type': 'application/json'});
      }

      final user = results.first;
      final storedHash = user['password']?.toString() ?? '';

      // Vérifier le mot de passe bcrypt
      // Les hash $2y$ doivent être convertis en $2a$ pour dbcrypt
      final compatibleHash = storedHash.replaceFirst('\$2y\$', '\$2a\$');
      final isValid = dbcrypt.checkpw(password, compatibleHash);

      if (!isValid) {
        return Response(401,
            body: jsonEncode({'error': 'Email ou mot de passe incorrect'}),
            headers: {'Content-Type': 'application/json'});
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'idUser': user['idUser'],
            'firstName': user['firstName']?.toString() ?? '',
            'lastName': user['lastName']?.toString() ?? '',
            'email': user['email']?.toString() ?? '',
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // POST /api/auth/register — Inscription
  router.post('/api/auth/register', (Request request) async {
    MySqlConnection? conn;
    try {
      final body = jsonDecode(await request.readAsString());
      final firstName = body['firstName']?.toString() ?? '';
      final lastName = body['lastName']?.toString() ?? '';
      final email = body['email']?.toString() ?? '';
      final password = body['password']?.toString() ?? '';

      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
        return Response(400,
            body: jsonEncode({'error': 'Tous les champs sont requis'}),
            headers: {'Content-Type': 'application/json'});
      }

      conn = await getConnection();

      // Vérifier si l'email existe déjà
      final existing = await conn.query(
        'SELECT idUser FROM user WHERE email = ?',
        [email],
      );
      if (existing.isNotEmpty) {
        return Response(409,
            body: jsonEncode({'error': 'Cet email est déjà utilisé'}),
            headers: {'Content-Type': 'application/json'});
      }

      // Hacher le mot de passe
      final hashedPassword = dbcrypt.hashpw(password, dbcrypt.gensalt());

      final result = await conn.query(
        'INSERT INTO user (firstName, lastName, email, password, createdAt, idRole) '
        'VALUES (?, ?, ?, ?, NOW(), 1)',
        [firstName, lastName, email, hashedPassword],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'idUser': result.insertId,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
          },
          'message': 'Inscription réussie',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // ════════════════════════════════════════
  // MODELES ROUTES
  // ════════════════════════════════════════

  // GET /api/modeles — Tous les modèles
  router.get('/api/modeles', (Request request) async {
    MySqlConnection? conn;
    try {
      conn = await getConnection();

      final results = await conn.query(
        'SELECT m.*, u.firstName as authorFirstName, u.lastName as authorLastName '
        'FROM modele m '
        'LEFT JOIN user u ON m.auteur = u.idUser '
        'ORDER BY m.id DESC',
      );

      final modeles = <Map<String, dynamic>>[];
      for (final row in results) {
        final modele = _rowToMap(row);

        final cmtCount = await conn.query(
          'SELECT COUNT(*) as cnt FROM comment_modele WHERE idModele = ?',
          [row['id']],
        );
        modele['commentCount'] = cmtCount.first['cnt'];

        modeles.add(modele);
      }

      return Response.ok(
        jsonEncode({'success': true, 'data': modeles}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // GET /api/modeles/<id> — Détail d'un modèle + commentaires
  router.get('/api/modeles/<id>', (Request request, String id) async {
    MySqlConnection? conn;
    try {
      conn = await getConnection();
      final modeleId = int.parse(id);

      final results = await conn.query(
        'SELECT m.*, u.firstName as authorFirstName, u.lastName as authorLastName '
        'FROM modele m '
        'LEFT JOIN user u ON m.auteur = u.idUser '
        'WHERE m.id = ?',
        [modeleId],
      );

      if (results.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Modèle non trouvé'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final modele = _rowToMap(results.first);

      // Commentaires avec infos utilisateur
      final cmts = await conn.query(
        'SELECT c.id, c.idModele, c.description, c.idUser, '
        'u.firstName, u.lastName '
        'FROM comment_modele c '
        'LEFT JOIN user u ON c.idUser = u.idUser '
        'WHERE c.idModele = ? ORDER BY c.id DESC',
        [modeleId],
      );
      modele['comments'] = cmts
          .map((r) => {
                'id': r['id'],
                'idModele': r['idModele'],
                'description': r['description']?.toString() ?? '',
                'idUser': r['idUser'],
                'firstName': r['firstName']?.toString() ?? '',
                'lastName': r['lastName']?.toString() ?? '',
              })
          .toList();

      modele['commentCount'] = cmts.length;

      return Response.ok(
        jsonEncode({'success': true, 'data': modele}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // POST /api/modeles — Ajouter un modèle
  router.post('/api/modeles', (Request request) async {
    MySqlConnection? conn;
    try {
      final body = jsonDecode(await request.readAsString());
      conn = await getConnection();

      final result = await conn.query(
        'INSERT INTO modele (name, description, prix, auteur, url, categorie, nb_polygone, animation, ringing) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          body['name'],
          body['description'] ?? '',
          body['prix'] ?? 0.0,
          body['auteur'] ?? 0,
          body['url'] ?? '',
          body['categorie'] ?? '',
          body['nb_polygone'] ?? 0,
          body['animation'] == true ? 1 : 0,
          body['ringing'] == true ? 1 : 0,
        ],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {'id': result.insertId},
          'message': 'Modèle ajouté avec succès',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // POST /api/modeles/<id>/comments — Ajouter un commentaire (avec idUser)
  router.post('/api/modeles/<id>/comments',
      (Request request, String id) async {
    MySqlConnection? conn;
    try {
      final body = jsonDecode(await request.readAsString());
      final modeleId = int.parse(id);
      final idUser = body['idUser'];
      conn = await getConnection();

      await conn.query(
        'INSERT INTO comment_modele (idModele, description, idUser) VALUES (?, ?, ?)',
        [modeleId, body['description'] ?? '', idUser],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Commentaire ajouté avec succès',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // GET /api/users/<id>/modeles — Modèles d'un utilisateur
  router.get('/api/users/<id>/modeles', (Request request, String id) async {
    MySqlConnection? conn;
    try {
      conn = await getConnection();
      final userId = int.parse(id);

      final results = await conn.query(
        'SELECT m.*, u.firstName as authorFirstName, u.lastName as authorLastName '
        'FROM modele m '
        'LEFT JOIN user u ON m.auteur = u.idUser '
        'WHERE m.auteur = ? ORDER BY m.id DESC',
        [userId],
      );

      final modeles = <Map<String, dynamic>>[];
      for (final row in results) {
        final modele = _rowToMap(row);

        final cmtCount = await conn.query(
          'SELECT COUNT(*) as cnt FROM comment_modele WHERE idModele = ?',
          [row['id']],
        );
        modele['commentCount'] = cmtCount.first['cnt'];

        modeles.add(modele);
      }

      return Response.ok(
        jsonEncode({'success': true, 'data': modeles}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // PUT /api/modeles/<id> — Modifier un modèle
  router.put('/api/modeles/<id>', (Request request, String id) async {
    MySqlConnection? conn;
    try {
      final body = jsonDecode(await request.readAsString());
      final modeleId = int.parse(id);
      conn = await getConnection();

      await conn.query(
        'UPDATE modele SET name = ?, description = ?, prix = ?, url = ?, '
        'categorie = ?, nb_polygone = ?, animation = ?, ringing = ? '
        'WHERE id = ?',
        [
          body['name'],
          body['description'] ?? '',
          body['prix'] ?? 0.0,
          body['url'] ?? '',
          body['categorie'] ?? '',
          body['nb_polygone'] ?? 0,
          body['animation'] == true ? 1 : 0,
          body['ringing'] == true ? 1 : 0,
          modeleId,
        ],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Modèle modifié avec succès',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  // DELETE /api/modeles/<id> — Supprimer un modèle
  router.delete('/api/modeles/<id>', (Request request, String id) async {
    MySqlConnection? conn;
    try {
      final modeleId = int.parse(id);
      conn = await getConnection();

      // Supprimer les commentaires liés
      await conn.query(
        'DELETE FROM comment_modele WHERE idModele = ?',
        [modeleId],
      );

      // Supprimer le modèle
      await conn.query(
        'DELETE FROM modele WHERE id = ?',
        [modeleId],
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Modèle supprimé avec succès',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erreur serveur: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn?.close();
    }
  });

  return router;
}

// ── Helpers ──
Map<String, dynamic> _rowToMap(ResultRow row) {
  final map = <String, dynamic>{};
  for (final field in row.fields.keys) {
    var value = row[field];
    if (value is Blob) {
      value = value.toString();
    } else if (value is DateTime) {
      value = value.toIso8601String();
    }
    map[field] = value;
  }
  return map;
}

// ── Main ──
void main() async {
  final app = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(buildRouter().call);

  final server = await io.serve(app, 'localhost', 8081);
  print(
      '✅ Serveur ModulX API démarré sur http://${server.address.host}:${server.port}');
  print('📦 Endpoints :');
  print('   POST /api/auth/login            — Connexion');
  print('   POST /api/auth/register         — Inscription');
  print('   GET  /api/modeles               — Liste des modèles');
  print('   GET  /api/modeles/<id>          — Détail d\'un modèle');
  print('   POST /api/modeles               — Ajouter un modèle');
  print('   POST /api/modeles/<id>/comments — Ajouter un commentaire');
  print('');
  print('Appuyez sur Ctrl+C pour arrêter le serveur.');

  ProcessSignal.sigint.watch().listen((_) {
    print('\n🛑 Arrêt du serveur...');
    server.close();
    exit(0);
  });
}
