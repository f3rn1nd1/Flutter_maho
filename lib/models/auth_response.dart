import 'user.dart';

class AuthResponse {
  final bool success;
  final String message;
  final User user;
  final String token;

  AuthResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  // Método para convertir JSON en un objeto AuthResponse
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }

  // Método para convertir un objeto AuthResponse en JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user.toJson(),
      'token': token,
    };
  }
}