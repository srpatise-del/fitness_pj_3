class AppUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? token;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.token,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'token': token,
    };
  }
}

