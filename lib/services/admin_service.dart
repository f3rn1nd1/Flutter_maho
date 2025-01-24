import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user.dart';
import '../models/user_response.dart';

class UserService {
  final String baseUrl = "http://10.10.160.134:8888/api";

  // Método para obtener usuarios paginados
  Future<UserResponse> fetchAllUsers(String token, {String search = '', int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users?search=$search&page=$page'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  // Método para obtener usuarios en la papelera
  Future<UserResponse> fetchTrashUsers(String token, {String search = '', int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trash?search=$search&page=$page'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load trash users: ${response.body}');
    }
  }

  // Método para obtener usuarios con papelera
  Future<UserResponse> fetchWithTrashUsers(String token, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/with-trash?page=$page'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load with-trash users: ${response.body}');
    }
  }

  // Método para obtener un usuario por ID
  Future<User> fetchUserById(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  // Método para crear un nuevo usuario
  Future<User> createUser(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  // Método para actualizar un usuario
  Future<User> updateUser(String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Método para restaurar un usuario
  Future<void> restoreUser(String token, int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/restore/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restore user: ${response.body}');
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUser(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // Método para eliminar un usuario permanentemente
  Future<void> forceDeleteUser(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/force-delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to force delete user: ${response.body}');
    }
  }
}