import 'package:projects/models/user.dart';

class Paginate {
  final List<User> users;
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final int perPage;

  Paginate({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.perPage,
  });

  factory Paginate.fromJson(Map<String, dynamic> json) {
    return Paginate(
      users: (json['users'] as List).map((item) => User.fromJson(item)).toList(),
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalUsers: json['total_users'],
      perPage: json['per_page'],
    );
  }
}