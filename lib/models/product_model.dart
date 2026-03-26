class Comment {
  final int id;
  final int idModele;
  final String description;
  final int? idUser;
  final String firstName;
  final String lastName;

  Comment({
    required this.id,
    required this.idModele,
    required this.description,
    this.idUser,
    this.firstName = '',
    this.lastName = '',
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: _parseInt(json['id']),
      idModele: _parseInt(json['idModele']),
      description: json['description']?.toString() ?? '',
      idUser: json['idUser'] != null ? _parseInt(json['idUser']) : null,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }

  String get authorName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Anonyme' : name;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class Product3D {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final int auteur;
  final String authorFirstName;
  final String authorLastName;
  final String categorie;
  final int nbPolygone;
  final bool animation;
  final bool ringing;
  final int commentCount;
  final List<Comment> comments;

  Product3D({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.auteur = 0,
    this.authorFirstName = '',
    this.authorLastName = '',
    this.categorie = '',
    this.nbPolygone = 0,
    this.animation = false,
    this.ringing = false,
    this.commentCount = 0,
    this.comments = const [],
  });

  factory Product3D.fromJson(Map<String, dynamic> json) {
    return Product3D(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Sans nom',
      description: json['description']?.toString(),
      price: _parseDouble(json['prix']),
      imageUrl: json['url']?.toString(),
      auteur: _parseInt(json['auteur']),
      authorFirstName: json['authorFirstName']?.toString() ?? '',
      authorLastName: json['authorLastName']?.toString() ?? '',
      categorie: json['categorie']?.toString() ?? '',
      nbPolygone: _parseInt(json['nb_polygone']),
      animation: _parseBool(json['animation']),
      ringing: _parseBool(json['ringing']),
      commentCount: _parseInt(json['commentCount']),
      comments: _parseComments(json['comments']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString() == '1' || value.toString() == 'true';
  }

  static List<Comment> _parseComments(dynamic list) {
    if (list == null || list is! List) return [];
    return list.map((item) => Comment.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  String get priceFormatted {
    if (price == null || price == 0) return 'Gratuit';
    return '${price!.toStringAsFixed(2)} €';
  }

  String get polygoneFormatted {
    if (nbPolygone >= 1000000) return '${(nbPolygone / 1000000).toStringAsFixed(1)}M';
    if (nbPolygone >= 1000) return '${(nbPolygone / 1000).toStringAsFixed(1)}K';
    return nbPolygone.toString();
  }

  String get authorName {
    final name = '$authorFirstName $authorLastName'.trim();
    return name.isEmpty ? 'Auteur #$auteur' : name;
  }
}
