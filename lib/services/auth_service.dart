import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = dotenv.get('BASE_URL');

  // ===========================
  // Segmento: Tokenización
  // ===========================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveUserData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user)); // Guardar datos del usuario
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    return userJson != null ? jsonDecode(userJson) : null;
  }

  // ===========================
  // Segmento: Autenticación
  // ===========================

  // Iniciar sesión
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] != true) {
        throw Exception(responseBody['message'] ?? 'Error desconocido');
      }
      return responseBody;
    } else {
      throw Exception('Error al iniciar sesión: ${response.statusCode}');
    }
  }

  // Cerrar sesión
  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } else {
      throw Exception('Error al cerrar sesión: ${response.statusCode}');
    }
  }

  // Registrar un nuevo usuario
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar usuario: ${response.statusCode}');
    }
  }
}
