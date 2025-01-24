import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_response.dart';
import '../services/user_service.dart';

class UserController with ChangeNotifier {
  final UserService _userService = UserService();

  List<User> _users = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  int _perPage = 10;
  bool _isLoading = false;
  String _searchQuery = '';

  // Getter para obtener la lista de usuarios
  List<User> get users => _users;

  // Getter para obtener la página actual
  int get currentPage => _currentPage;

  // Getter para obtener el total de páginas
  int get totalPages => _totalPages;

  // Getter para obtener el total de usuarios
  int get totalUsers => _totalUsers;

  // Getter para obtener el número de usuarios por página
  int get perPage => _perPage;

  // Getter para verificar si se está cargando
  bool get isLoading => _isLoading;

  // Getter para obtener la consulta de búsqueda actual
  String get searchQuery => _searchQuery;

  // Método para cargar usuarios paginados con búsqueda
  Future<void> loadAllUsers(String token, {String search = '', int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserResponse response = await _userService.fetchAllUsers(token, search: search, page: page);
      _users = response.users;
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _totalUsers = response.totalUsers;
      _perPage = response.perPage;
      _searchQuery = search; // Actualizar la consulta de búsqueda
    } catch (e) {
      throw Exception('Failed to load users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cambiar de página
  Future<void> goToPage(String token, int page) async {
    await loadAllUsers(token, search: _searchQuery, page: page);
  }

  // Método para realizar una búsqueda
  Future<void> searchUsers(String token, String query) async {
    await loadAllUsers(token, search: query, page: 1);
  }
}