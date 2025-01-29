import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = dotenv.get('BASE_URL');

  // Método genérico para hacer solicitudes HTTP
  Future<dynamic> _makeRequest(
      String method,
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Método HTTP no soportado: $method');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // ===========================
  // Segmento: Tokenizacion
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
    final response = await _makeRequest(
      'POST',
      '/login',
      headers: {'Content-Type': 'application/json'},
      body: credentials,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error desconocido');
    }

    return response;
  }

  // Cerrar sesión
  Future<dynamic> logout(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    return await _makeRequest('POST', '/logout', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Registrar un nuevo usuario
  Future<dynamic> register(Map<String, dynamic> userData) async {
    return await _makeRequest('POST', '/register', body: userData);
  }
}