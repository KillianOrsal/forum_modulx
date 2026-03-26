class AppUser {
  final int idUser;
  final String firstName;
  final String lastName;
  final String email;

  AppUser({
    required this.idUser,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      idUser: json['idUser'] is int
          ? json['idUser']
          : int.tryParse(json['idUser'].toString()) ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
