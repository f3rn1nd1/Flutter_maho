import 'package:flutter/material.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;

  // Getter para obtener el usuario actual
  User? get user => _user;

  // Getter para obtener el token actual
  String? get token => _token;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => _token != null;

  // Método para iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      final AuthResponse authResponse = await _authService.login(email, password);
      _user = authResponse.user;
      _token = authResponse.token;
      notifyListeners(); // Notificar a los listeners que el estado ha cambiado
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    if (_token != null) {
      try {
        await _authService.logout(_token!);
        _user = null;
        _token = null;
        notifyListeners(); // Notificar a los listeners que el estado ha cambiado
      } catch (e) {
        throw Exception('Failed to logout: $e');
      }
    }
  }

  // Método para registrar un nuevo usuario
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String rol,
    required String telefono,
    required String anexo,
  }) async {
    try {
      final AuthResponse authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        rol: rol,
        telefono: telefono,
        anexo: anexo,
      );
      _user = authResponse.user;
      _token = authResponse.token;
      notifyListeners(); // Notificar a los listeners que el estado ha cambiado
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }
}