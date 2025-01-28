import 'package:flutter/material.dart';
import 'package:projects/services/auth_service.dart';
import '../services/user_service.dart';

class UserController with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  List<dynamic> _users = [];
  List<dynamic> _trashUsers = [];
  dynamic _currentUser;
  bool _isLoading = false;

  List<dynamic> get users => _users;
  List<dynamic> get trashUsers => _trashUsers;
  dynamic get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // ==================================================
  // Métodos para el usuario común
  // ==================================================

  // Obtener información de todos los usuarios (con búsqueda y paginación)
  Future<void> loadInfoAllUsers(String token, {String search = '', int page = 1}) async {
    if (_isLoading) return; // Evita llamadas múltiples concurrentes

    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getInfoAllUsers(token, search: search, page: page);
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener información de un recurso específico (usuario actual)
  Future<void> loadCurrentUserInfo(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userService.getCurrentUserInfo(token, id);
    } catch (e) {
      throw Exception('Failed to load current user info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar la información de un usuario
  Future<void> updateUser(String token, int id, Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUser(token, id, userData);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================================================
  // Métodos para el administrador
  // ==================================================



  // Obtener todos los usuarios
  Future<void> loadAllUsers(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers(token);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Obtener usuarios en la papelera
  Future<void> loadTrashUsers(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _trashUsers = await _userService.getTrashUsers(token);
    } catch (e) {
      throw Exception('Failed to load trash users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener usuarios con papelera
  Future<void> loadUsersWithTrash(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getUsersWithTrash(token);
    } catch (e) {
      throw Exception('Failed to load users with trash: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener información de un usuario específico
  Future<void> loadUserById(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userService.getUserById(token, id);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un usuario específico de la papelera
  Future<void> loadTrashUserById(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userService.getTrashUserById(token, id);
    } catch (e) {
      throw Exception('Failed to load trash user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear un nuevo usuario
  Future<void> createUser(String token, Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.createUser(token, userData);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restaurar un usuario de la papelera
  Future<void> restoreUser(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.restoreUser(token, id);
    } catch (e) {
      throw Exception('Failed to restore user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar un usuario (lógicamente)
  Future<void> deleteUser(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.deleteUser(token, id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar un usuario permanentemente
  Future<void> forceDeleteUser(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.forceDeleteUser(token, id);
    } catch (e) {
      throw Exception('Failed to force delete user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================================================
  // Métodos de autenticación
  // ==================================================

  // Iniciar sesión
  Future<void> login(Map<String, dynamic> credentials) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(credentials);
      // Aquí puedes guardar el token en SharedPreferences o en el estado
    } catch (e) {
      throw Exception('Failed to login: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cerrar sesión
  Future<void> logout(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout(token);
    } catch (e) {
      throw Exception('Failed to logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrar un nuevo usuario
  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(userData);
    } catch (e) {
      throw Exception('Failed to register: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}