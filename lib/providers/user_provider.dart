import 'package:flutter/material.dart';
import 'package:projects/models/user.dart';
import 'package:projects/models/paginate.dart';
import 'package:projects/services/auth_service.dart';
import 'package:projects/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _users = [];
  Paginate? _pagination;
  String _errorMessage = '';
  bool _isLoading = false;

  List<User> get users => _users;
  Paginate? get pagination => _pagination;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // AUTHINICIO
  String? _token;
  Map<String, dynamic>? _currentUser;

  String? get token => _token;
  Map<String, dynamic>? get userData => _currentUser;

  // Inicializa el controlador y obtiene el token guardado
  Future<void> initialize() async {
    _token = await AuthService.getUserToken();
    _currentUser = await AuthService.getUserData();
    notifyListeners();
  }

  // PATRON SINGLETON
  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  // ===========================
  // Segmento: Administrador
  // ===========================

// Obtener todos los usuarios
  Future<void> getUsers({int? page, String? search}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      // Llamar al servicio con parámetros opcionales
      _pagination =
          await _userService.getAllUsers(token, page: page, search: search);
      _users = pagination!.users;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un usuario por su ID
  Future<void> getUserById(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      User user = await _userService.getUserById(token, id);
      _users = [user];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear un nuevo usuario
  Future<void> createUser(Map<String, User> userData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      User newUser = await _userService.createUser(token, userData);
      _pagination?.users.add(newUser);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar un usuario
  Future<void> updateUser(int id, User userData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      User updatedUser = await _userService.updateUser(
          token, id, userData.toJson() as Map<String, dynamic>);
      int index = _pagination!.users.indexWhere((user) => user.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar un usuario
  Future<void> deleteUser(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      await _userService.deleteUser(token, id);
      _pagination!.users.removeWhere((user) => user.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restaurar un usuario desde la papelera
  Future<void> restoreUser(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      await _userService.restoreUser(token, id);
      _users.add(_userService.getUserById(token, id) as User);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener usuarios de la papelera
  Future<void> getTrashUsers({int page = 1, String search = ""}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      Paginate trashPagination =
          await _userService.getTrashUsers(token, page: page, search: search);
      _pagination = trashPagination;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener usuarios con papelera
  Future<void> getUsersWithTrash() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      _users = await _userService.getUsersWithTrash(token);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un usuario específico de la papelera
  Future<void> getTrashUserById(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      User user = await _userService.getTrashUserById(token, id);
      _users = [user];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar un usuario permanentemente
  Future<void> forceDeleteUser(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      await _userService.forceDeleteUser(token, id);
      _pagination?.users.removeWhere((user) => user.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================
  // Segmento: Usuario Comun
  // ===========================

  // Obtener todos los usuarios
  Future<void> infoUsers({int? page, String? search}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      // Llamar al servicio con parámetros opcionales
      _pagination =
      await _userService.getInfoAllUsers(token, page: page, search: search);
      _users = pagination!.users;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un usuario por su ID
  Future<void> getCurrentUser(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      User user = await _userService.getCurrentUserInfo(token, id);
      _users = [user];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================
  // Segmento: Autenticación
  // ===========================

  // Iniciar sesión
  Future<dynamic> login(Map<String, dynamic> credentials) async {
    try {
      final response = await AuthService().login(credentials);
      _token = response['token'];
      _currentUser = response['user'];

      // Guardar el token y los datos del usuario
      await AuthService.saveToken(_token!);
      await AuthService.saveUserData(_token!, _currentUser!);

      notifyListeners();
      return response; // Retorna la respuesta completa del servicio
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<dynamic> logout() async {
    try {
      if (_token != null) {
        final response = await AuthService().logout(_token!);
        _token = null;
        _currentUser = null;

        // Limpiar el almacenamiento local
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_data');

        notifyListeners();
        return response; // Retorna la respuesta completa del servicio
      }
      return null; // Si no hay token, retornamos null
    } catch (e) {
      rethrow;
    }
  }

  // Registrar un nuevo usuario
  Future<dynamic> register(Map<String, dynamic> userData) async {
    try {
      final response = await AuthService().register(userData);
      _token = response['token'];
      _currentUser = response['user'];

      // Guardar el token y los datos del usuario
      await AuthService.saveToken(_token!);
      await AuthService.saveUserData(_token!, _currentUser!);

      notifyListeners();
      return response; // Retorna la respuesta completa del servicio
    } catch (e) {
      rethrow;
    }
  }
}
