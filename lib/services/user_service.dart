import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserService {
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
  // Segmento: Usuarios Comunes
  // ===========================

  // Obtener información de un usuario específico
  Future<dynamic> getUserById(String token, int id) async {
    return await _makeRequest('GET', '/users/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Obtener información de un recurso específico (usuario actual)
  Future<dynamic> getCurrentUserInfo(String token, int id) async {
    return await _makeRequest('GET', '/info/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Crear un nuevo usuario
  Future<dynamic> createUser(String token, Map<String, dynamic> userData) async {
    return await _makeRequest('POST', '/users', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }, body: userData);
  }

  // Actualizar la información de un usuario
  Future<dynamic> updateUser(String token, int id, Map<String, dynamic> userData) async {
    return await _makeRequest('PUT', '/users/$id', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }, body: userData);
  }

  // ===========================
  // Segmento: Administración
  // ===========================

  // Obtener todos los usuarios
  Future<List<dynamic>> getAllUsers(String token) async {
    return await _makeRequest('GET', '/users', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Obtener información de todos los usuarios (con búsqueda y paginación)
  Future<List<dynamic>> getInfoAllUsers(String token, {String search = '', int page = 1}) async {
    return await _makeRequest('GET', '/infoall?search=$search&page=$page', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Obtener usuarios en la papelera
  Future<List<dynamic>> getTrashUsers(String token) async {
    return await _makeRequest('GET', '/trash', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Obtener usuarios con papelera
  Future<List<dynamic>> getUsersWithTrash(String token) async {
    return await _makeRequest('GET', '/with-trash', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Obtener un usuario específico de la papelera
  Future<dynamic> getTrashUserById(String token, int id) async {
    return await _makeRequest('GET', '/trash/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Restaurar un usuario de la papelera
  Future<dynamic> restoreUser(String token, int id) async {
    return await _makeRequest('POST', '/users/restore/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Eliminar un usuario (lógicamente)
  Future<dynamic> deleteUser(String token, int id) async {
    return await _makeRequest('DELETE', '/users/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Eliminar un usuario permanentemente
  Future<dynamic> forceDeleteUser(String token, int id) async {
    return await _makeRequest('DELETE', '/users/force-delete/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }


}
