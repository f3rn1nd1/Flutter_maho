import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:projects/models/user.dart';
import 'package:projects/models/paginate.dart';

class UserService {
  final String baseUrl = dotenv.get('BASE_URL');

  // ==================================================
  // Métodos de usuario Administrador
  // ==================================================

  // Obtener información de un usuario específico
  Future<User> getUserById(String token, int id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  // Crear un nuevo usuario
  Future<User> createUser(String token, Map<String, User> userData) async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }

  // Actualizar la información de un usuario
  Future<User> updateUser(String token, int id, Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  // Obtener todos los usuarios con paginación
  Future<Paginate> getAllUsers(String token, {int? page, String? search}) async {
    // Construir la URL manualmente según los parámetros
    String url = '$baseUrl/users';

    // Agregar parámetros solo si existen
    if (search != null && search.isNotEmpty) {
      url += '?search=$search';
    }
    if (page != null) {
      url += search != null && search.isNotEmpty ? '&page=$page' : '?page=$page';
    }

    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return Paginate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }



  // Obtener usuarios en la papelera con paginación
  Future<Paginate> getTrashUsers(String token, {int page = 1, String search= ""}) async {
    final url = Uri.parse('$baseUrl/trash?search=$search&page=$page');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return Paginate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load trash users: ${response.statusCode}');
    }
  }


  // Obtener usuarios con papelera
  Future<List<User>> getUsersWithTrash(String token) async {
    final url = Uri.parse('$baseUrl/with-trash');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users with trash: ${response.statusCode}');
    }
  }

  // Obtener un usuario específico de la papelera
  Future<User> getTrashUserById(String token, int id) async {
    final url = Uri.parse('$baseUrl/trash/$id');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load trash user: ${response.statusCode}');
    }
  }

  // Restaurar un usuario de la papelera
  Future<User> restoreUser(String token, int id) async {
    final url = Uri.parse('$baseUrl/users/restore/$id');
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to restore user: ${response.statusCode}');
    }
  }

  // Eliminar un usuario (lógicamente)
  Future<void> deleteUser(String token, int id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  // Eliminar un usuario permanentemente
  Future<void> forceDeleteUser(String token, int id) async {
    final url = Uri.parse('$baseUrl/users/force-delete/$id');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to force delete user: ${response.statusCode}');
    }
  }

  // ==================================================
  // Métodos de usuario Comun
  // ==================================================

  // Obtener información del usuario actual
  Future<User> getCurrentUserInfo(String token, int id) async {
    final url = Uri.parse('$baseUrl/info/$id');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load current user info: ${response.statusCode}');
    }
  }

  // Obtener información de todos los usuarios (con búsqueda y paginación)
  Future<Paginate> getInfoAllUsers(String token, {String search = '', int page = 1}) async {
    final url = Uri.parse('$baseUrl/infoall?search=$search&page=$page');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return Paginate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load all users: ${response.statusCode}');
    }
  }

  // Actualizar la información de un usuario
  Future<User> updateInfo(String token, int id, Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/info/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }
}
