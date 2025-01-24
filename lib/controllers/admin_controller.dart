import 'package:flutter/material.dart';
import '../models/user.dart';import '../models/user_response.dart';

import '../services/admin_service.dart';


class UserController with ChangeNotifier {
  final UserService _userService = UserService();

  List<User> _users = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  bool _isLoading = false;

  // Getter para obtener la lista de usuarios
  List<User> get users => _users;

  // Getter para obtener la página actual
  int get currentPage => _currentPage;

  // Getter para obtener el total de páginas
  int get totalPages => _totalPages;

  // Getter para obtener el total de usuarios
  int get totalUsers => _totalUsers;

  // Getter para verificar si se está cargando
  bool get isLoading => _isLoading;

  // Método para cargar usuarios paginados
  Future<void> loadAllUsers(String token, {String search = '', int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserResponse response = await _userService.fetchAllUsers(token, search: search, page: page);
      _users = response.users;
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _totalUsers = response.totalUsers;
    } catch (e) {
      throw Exception('Failed to load users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cargar usuarios en la papelera
  Future<void> loadTrashUsers(String token, {String search = '', int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserResponse response = await _userService.fetchTrashUsers(token, search: search, page: page);
      _users = response.users;
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _totalUsers = response.totalUsers;
    } catch (e) {
      throw Exception('Failed to load trash users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cargar usuarios con papelera
  Future<void> loadWithTrashUsers(String token, {int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserResponse response = await _userService.fetchWithTrashUsers(token, page: page);
      _users = response.users;
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _totalUsers = response.totalUsers;
    } catch (e) {
      throw Exception('Failed to load with-trash users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cargar un usuario por ID
  Future<User> loadUserById(String token, int id) async {
    try {
      return await _userService.fetchUserById(token, id);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  // Método para crear un nuevo usuario
  Future<User> createUser(String token, Map<String, dynamic> data) async {
    try {
      return await _userService.createUser(token, data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Método para actualizar un usuario
  Future<User> updateUser(String token, int id, Map<String, dynamic> data) async {
    try {
      return await _userService.updateUser(token, id, data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Método para restaurar un usuario
  Future<void> restoreUser(String token, int id) async {
    try {
      await _userService.restoreUser(token, id);
    } catch (e) {
      throw Exception('Failed to restore user: $e');
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUser(String token, int id) async {
    try {
      await _userService.deleteUser(token, id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Método para eliminar un usuario permanentemente
  Future<void> forceDeleteUser(String token, int id) async {
    try {
      await _userService.forceDeleteUser(token, id);
    } catch (e) {
      throw Exception('Failed to force delete user: $e');
    }
  }
}