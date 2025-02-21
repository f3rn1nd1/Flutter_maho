import 'package:flutter/material.dart';
import 'package:projects/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projects/providers/user_provider.dart';
import '../models/user.dart';

class SearchTable extends StatefulWidget {
  final dynamic currentUser; // O el tipo que corresponda

  const SearchTable({super.key, required this.currentUser});

  @override
  SearchTableState createState() => SearchTableState();
}

class SearchTableState extends State<SearchTable> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  int _currentPage = 1;
  String _selectedView = 'active';
  bool _isLoading = false;

  void _onSearchPressed() {
    String query = _searchController.text.trim();
    _filterUsers(query);
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final userProvider = context.read<UserProvider>();
    final currentUserId = await AuthService.getCurrentUserId();
    final userData = await AuthService.getUserData();
    final isAdmin = userData != null && userData['admin']?.toString() == "1";

    try {
      setState(() {
        _isLoading = true;
      });

      if (_selectedView == 'active') {
        if (isAdmin) {
          print('Loading with getUsers (admin)'); // Debug log
          await userProvider.getUsers(
            page: _currentPage,
            search: _searchController.text.trim(),
          );
        } else {
          print('Loading with infoUsers (common user)'); // Debug log
          await userProvider.infoUsers(
            page: _currentPage,
            search: _searchController.text.trim(),
          );
        }
      } else if (isAdmin) {
        print('Loading trash users (admin only)'); // Debug log
        await userProvider.getTrashUsers(
          page: _currentPage,
          search: _searchController.text.trim(),
        );
      }

      setState(() {
        _filteredUsers = userProvider.users
            .where((user) => user.id?.toString() != currentUserId)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading users: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleViewChange(String? newView) async {
    final userData = await AuthService.getUserData();
    final isAdmin = userData != null && userData['admin']?.toString() == "1";

    if (newView == 'trash' && !isAdmin) {
      // Si no es admin y trata de ver eliminados, mostrar alerta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para ver usuarios eliminados'),
          backgroundColor: Colors.red,
        ),
      );
      // Mantener la vista en activos
      setState(() {
        _selectedView = 'active';
      });
      return;
    }

    setState(() {
      _selectedView = newView ?? 'active';
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _loadPage(int page) async {
    final userData = await AuthService.getUserData();
    final isAdmin = userData != null && userData['admin']?.toString() == "1";

    setState(() {
      _currentPage = page;
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      if (_selectedView == 'active') {
        if (isAdmin) {
          await userProvider.getUsers(
            page: page,
            search: _searchController.text.trim(),
          );
        } else {
          await userProvider.infoUsers(
            page: page,
            search: _searchController.text.trim(),
          );
        }
      } else if (isAdmin) {
        await userProvider.getTrashUsers(
          page: page,
          search: _searchController.text.trim(),
        );
      }

      setState(() {
        _filteredUsers = userProvider.users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterUsers(String query) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = await AuthService.getUserData();
    final isAdmin = userData != null && userData['admin']?.toString() == "1";

    if (query.isEmpty) {
      _loadPage(1);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedView == 'active') {
        if (isAdmin) {
          await userProvider.getUsers(page: 1, search: query);
        } else {
          await userProvider.infoUsers(page: 1, search: query);
        }
      } else if (isAdmin) {
        await userProvider.getTrashUsers(page: 1, search: query);
      }

      setState(() {
        _filteredUsers = userProvider.users;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar usuarios: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<DataRow>> _buildRows(
      UserProvider userProvider, bool isAdmin) async {
    // Obtener el ID del usuario actual
    final currentUserId = await AuthService.getCurrentUserId();

    print('Current User ID: $currentUserId'); // Para depuración

    return Future.wait(_filteredUsers.map<Future<DataRow>>(
      (user) async {
        // Imprimir IDs para depuración
        print('Comparing - User ID: ${user.id}, Current ID: $currentUserId');

        // Verificar si es el usuario actual
        final isCurrentUser = user.id?.toString() == currentUserId;

        print('Is Current User: $isCurrentUser'); // Para depuración

        return DataRow(cells: [
          DataCell(
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () => showInfoModal(context, user),
            ),
          ),
          DataCell(SelectableText(user.name.toString())),
          DataCell(SelectableText(user.email.toString())),
          DataCell(SelectableText(user.telefono.toString())),
          DataCell(SelectableText(user.anexo.toString())),
          DataCell(
            Row(
              children: _selectedView == 'active'
                  ? [
                      // Solo mostrar botones si NO es el usuario actual
                      if (!isCurrentUser && isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showEditModal(context, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  title: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        radius: 24,
                                        child: const Icon(
                                          Icons.warning_amber,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        '¿Eliminar usuario?',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    'Esta acción no se puede deshacer.',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Eliminar',
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        try {
                                          Navigator.of(context).pop();
                                          await userProvider
                                              .deleteUser(user.id!.toInt());
                                          // Recargar la lista después de eliminar
                                          if (_selectedView == 'active') {
                                            _loadUsers();
                                          } else {
                                            // Si estamos en la vista de eliminados, actualizar esa lista
                                            await userProvider.getTrashUsers(
                                                page: _currentPage);
                                            setState(() {
                                              _filteredUsers =
                                                  userProvider.users;
                                            });
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Usuario eliminado exitosamente'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error al eliminar usuario: ${e.toString()}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ]
                  : [
                      if (!isCurrentUser && isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () async {
                            try {
                              await userProvider.restoreUser(user.id!.toInt());
                              _loadUsers();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Usuario restaurado exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error al restaurar usuario: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          onPressed: () {
                            // Mostrar el AlertDialog
                            showDialog(
                              context:
                                  context, // Necesitas el contexto para mostrar el diálogo
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.zero, // Borde cuadrado
                                  ),
                                  title: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color.fromARGB(
                                            255,
                                            162,
                                            23,
                                            23), // Color de fondo del círculo
                                        radius: 24, // Tamaño del círculo
                                        child: const Icon(
                                          Icons
                                              .warning_amber, // Ícono de advertencia
                                          color:
                                              Colors.white, // Color del ícono
                                          size: 32, // Tamaño del ícono
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              16), // Espacio entre el ícono y el texto
                                    ],
                                  ),
                                  content: const Text(
                                    'Esta seguro de eliminar permanentemente este usuario.', // Mensaje adicional
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () {
                                        // Cerrar el diálogo sin hacer nada
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Eliminar',
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        // Cerrar el diálogo y proceder con la eliminación
                                        Navigator.of(context).pop();
                                        userProvider
                                            .forceDeleteUser(user.id!.toInt());
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
            ),
          ),
        ]);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: AuthService.getUserData().then((value) => value ?? {}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar datos"));
        }
        Map<String, dynamic> userData = snapshot.data ?? {};
        bool isAdmin = userData['admin']?.toString() == "1";
        return Card(
          elevation: 5,
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila de búsqueda
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Botón de crear usuario (solo para administradores)
                    if (isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _showCreateUserDialog(context),
                          icon: const Icon(Icons.person_add, size: 20),
                          label: const Text('Crear Usuario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    // Campo de búsqueda con tamaño flexible
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Buscar',
                            hintText: 'Ingrese un nombre',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón de búsqueda
                    ElevatedButton(
                      onPressed: _onSearchPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text("Buscar"),
                    ),
                  ],
                ),
              ),
              // SegmentedButton para cambiar entre Activos y Eliminados
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedButton<String>(
                  segments: [
                    const ButtonSegment<String>(
                      value: 'active',
                      label: Text('Activos'),
                    ),
                    if (isAdmin) // Solo mostrar el segmento de eliminados si es admin
                      const ButtonSegment<String>(
                        value: 'trash',
                        label: Text('Eliminados'),
                      ),
                  ],
                  selected: {_selectedView},
                  onSelectionChanged: (Set<String> newSelection) {
                    _handleViewChange(newSelection.first);
                  },
                ),
              ),
              // Indicador de carga o mensaje de vacío
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (_filteredUsers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay usuarios disponibles.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                // Tabla de datos con formato condicional según la vista
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FutureBuilder<List<DataRow>>(
                    future: _buildRows(userProvider, isAdmin),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text("")),
                          DataColumn(label: Text("Nombre")),
                          DataColumn(label: Text("Correo")),
                          DataColumn(label: Text("Teléfono")),
                          DataColumn(label: Text("Anexo")),
                          DataColumn(label: Text("Acciones")),
                        ],
                        rows: snapshot.data ?? [],
                      );
                    },
                  ),
                ),
              // Controles de paginación
              if (userProvider.pagination != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () => _loadPage(_currentPage - 1)
                          : null,
                    ),
                    Text('Página $_currentPage'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed:
                          _currentPage < userProvider.pagination!.totalPages
                              ? () => _loadPage(_currentPage + 1)
                              : null,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // Modal de información adicional
  void showInfoModal(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Información adicional",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Text("Nombre: ${user.name ?? '-'}"),
                const SizedBox(height: 8),
                Text("Correo electronico: ${user.email ?? '-'}"),
                const SizedBox(height: 8),
                Text("Estado: ${user.estado ?? '-'}"),
                const SizedBox(height: 8),
                Text("Telefono: ${user.telefono ?? '-'}"),
                const SizedBox(height: 8),
                Text("Anexo: ${user.anexo ?? '-'}"),
                const SizedBox(height: 8),
                Text("Última Conexión: ${user.ultimaConexion ?? '-'}"),
                const SizedBox(height: 8),
                Text("Rol: ${user.rol ?? '-'}"),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cerrar"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal de edición (se utiliza sólo en vista activa)
  void showEditModal(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.telefono);
    final anexoController = TextEditingController(text: user.anexo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Editar información",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: anexoController,
                  decoration: const InputDecoration(labelText: 'Anexo'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final updatedUser = User(
                          id: user.id,
                          name: nameController.text,
                          email: emailController.text,
                          telefono: phoneController.text,
                          anexo: anexoController.text,
                          rol: user.rol,
                          ultimaConexion: user.ultimaConexion,
                          estado: '',
                          updatedAt: '',
                          createdAt: '',
                          admin: '',
                        );
                        try {
                          await context
                              .read<UserProvider>()
                              .updateUser(user.id!.toInt(), updatedUser);
                          _loadUsers(); // Recargar la lista de usuarios
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Usuario actualizado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          String errorMessage = 'Error al actualizar usuario';
                          if (e is Map && e.containsKey('message')) {
                            final errors = e['message'] as Map<String, dynamic>;
                            errorMessage = errors.values
                                .expand((x) => x as List)
                                .join('\n');
                          } else {
                            errorMessage = e.toString();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _passwordConfirmationController = TextEditingController();
    final _phoneController = TextEditingController();
    final _anexoController = TextEditingController();
    final _rolController = TextEditingController();
    String _selectedAdmin = '0'; // Por defecto usuario común

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Usuario'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (!value!.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña *',
                    helperText: 'Mínimo 6 caracteres',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (value!.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordConfirmationController,
                  decoration: const InputDecoration(
                      labelText: 'Confirmar Contraseña *'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                TextFormField(
                  controller: _anexoController,
                  decoration: const InputDecoration(labelText: 'Anexo'),
                ),
                TextFormField(
                  controller: _rolController,
                  decoration: const InputDecoration(labelText: 'Rol *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAdmin,
                  decoration:
                      const InputDecoration(labelText: 'Tipo de Usuario *'),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Usuario Común')),
                    DropdownMenuItem(value: '1', child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAdmin = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final userData = {
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                  'password_confirmation': _passwordConfirmationController.text,
                  'rol': _rolController.text, // Rol personalizado
                  'telefono': _phoneController.text,
                  'admin': _selectedAdmin, // 0 o 1 para tipo de usuario
                  'anexo': _anexoController.text,
                  'estado': 'activo'
                };

                try {
                  await context
                      .read<UserProvider>()
                      .createUser({'user': userData});
                  Navigator.of(context).pop();
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario creado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  String errorMessage = 'Error al crear usuario';
                  if (e is Map && e.containsKey('message')) {
                    final errors = e['message'] as Map<String, dynamic>;
                    errorMessage =
                        errors.values.expand((x) => x as List).join('\n');
                  } else {
                    errorMessage = e.toString();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
