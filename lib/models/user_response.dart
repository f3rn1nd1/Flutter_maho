import 'package:projects/models/user.dart';

class UserResponse {
  final List<User> users;
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final int perPage;

  UserResponse({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.perPage,
  });

  // Método para convertir JSON en un objeto UserResponse
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      users: (json['users'] as List).map((item) => User.fromJson(item)).toList(),
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalUsers: json['total_users'],
      perPage: json['per_page'],
    );
  }
}