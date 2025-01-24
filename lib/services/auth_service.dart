import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/auth_response.dart';

class AuthService {
  final String baseUrl = "http://10.10.160.134:8888/api";

  // Método para iniciar sesión
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return AuthResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Método para cerrar sesión
  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.body}');
    }
  }

  // Método para registrar un nuevo usuario
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String rol,
    required String telefono,
    required String anexo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'rol': rol,
        'telefono': telefono,
        'anexo': anexo,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return AuthResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
}