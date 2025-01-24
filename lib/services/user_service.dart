import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_response.dart';

class UserService {
  final String baseUrl = dotenv.get('BASE_URL');

  // Método para obtener usuarios paginados con búsqueda
  Future<UserResponse> fetchAllUsers(String token, {String search = '', int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/infoall?search=$search&page=$page'),
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
}