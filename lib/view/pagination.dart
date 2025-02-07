import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:projects/models/paginate.dart'; // Asegúrate de importar tu modelo Paginate
import 'package:projects/models/user.dart'; // Asegúrate de importar tu modelo User
import 'package:projects/services/user_service.dart'; // Importa tu UserService
import 'package:projects/services/auth_service.dart'; // Importa tu AuthService

class Pagination extends StatefulWidget {
  final Function(int, String?) onPageChanged; // Callback para cambios de página
  final int initialPage; // Página inicial

  const Pagination({
    Key? key,
    required this.onPageChanged,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  Paginate? _pagination;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _getUsers();
  }

  Future<void> _getUsers({int? page, String? search}) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final token = await AuthService.getUserToken();
      if (token == null) throw Exception('No authentication token found');

      // Llamar al servicio con parámetros opcionales
      _pagination =
          await _userService.getAllUsers(token, page: page, search: search);
      _users = _pagination!.users;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          title: Text(user.name.toString()),
                          subtitle: Text(user.email.toString()),
                        );
                      },
                    ),
        ),
        if (_pagination != null && _pagination!.totalPages > 1)
          NumberPaginator(
            numberPages: _pagination!.totalPages,
            onPageChange: (int index) {
              setState(() {
                _currentPage = index;
              });
              widget.onPageChanged(index + 1, null); // Notificar a SearchTable
            },
          ),
      ],
    );
  }
}
