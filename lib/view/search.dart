import 'package:flutter/material.dart';
import 'package:projects/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projects/providers/user_provider.dart';
import '../models/user.dart';

class SearchTable extends StatefulWidget {
  final dynamic currentUser; // O el tipo que corresponda

  const SearchTable({Key? key, required this.currentUser}) : super(key: key);

  @override
  SearchTableState createState() => SearchTableState();
}

class SearchTableState extends State<SearchTable> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  int _currentPage = 1;
  String _selectedView = 'active';

  void _onSearchPressed() {
    String query = _searchController.text.trim();
    _filterUsers(query);
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // Obtén los datos del usuario desde AuthService
    final userData = await AuthService.getUserData();
    bool isAdmin = userData != null && userData['admin']?.toString() == "1";
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (isAdmin) {
      if (_selectedView == 'active') {
        await userProvider.getUsers(page: _currentPage);
      } else {
        await userProvider.getTrashUsers(page: _currentPage);
      }
    } else {
      if (_selectedView == 'active') {
        await userProvider.infoUsers(page: _currentPage);
      } else {
        // Usuario no admin: no se permite ver la papelera
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No tienes permisos para ver usuarios eliminados.')),
        );
        _filteredUsers = [];
        return;
      }
    }
    setState(() {
      _filteredUsers = userProvider.users;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (query.isEmpty) {
      _loadPage(1);
    } else {
      if (_selectedView == 'active') {
        userProvider.getUsers(page: 1, search: query).then((_) {
          setState(() {
            _filteredUsers = userProvider.users;
          });
        });
      } else {
        userProvider.getTrashUsers(page: 1, search: query).then((_) {
          setState(() {
            _filteredUsers = userProvider.users;
          });
        });
      }
    }
  }

  void _loadPage(int page) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_selectedView == 'active') {
      userProvider.getUsers(page: page).then((_) {
        setState(() {
          _filteredUsers = userProvider.users;
          _currentPage = page;
        });
      });
    } else {
      userProvider.getTrashUsers(page: page).then((_) {
        setState(() {
          _filteredUsers = userProvider.users;
          _currentPage = page;
        });
      });
    }
  }

  // Método auxiliar para construir las filas de la tabla de forma condicional
  List<DataRow> _buildRows(UserProvider userProvider, bool isAdmin) {
    return _filteredUsers.map((user) {
      return DataRow(cells: [
        // Puedes conservar el botón de información si lo deseas
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
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showEditModal(context, user),
                      ),
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
                                      backgroundColor: Colors
                                          .orange, // Color de fondo del círculo
                                      radius: 24, // Tamaño del círculo
                                      child: const Icon(
                                        Icons
                                            .warning_amber, // Ícono de advertencia
                                        color: Colors.white, // Color del ícono
                                        size: 32, // Tamaño del ícono
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            16), // Espacio entre el ícono y el texto
                                    const Text(
                                      '¿Eliminar usuario?', // Texto de confirmación
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  'Esta acción no se puede deshacer.', // Mensaje adicional
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
                                      userProvider.deleteUser(user.id!.toInt());
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ]
                : [
                    // Para la vista trash se muestran botones para restaurar o eliminar permanentemente
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () =>
                            userProvider.restoreUser(user.id!.toInt()),
                      ),
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
                                        color: Colors.white, // Color del ícono
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
          ),
        ),
      ]);
    }).toList();
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          hintText: 'Ingrese un nombre',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onSearchPressed,
                      child: const Text("Buscar"),
                    ),
                  ],
                ),
              ),
              // SegmentedButton para cambiar entre Activos y Eliminados
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'active', label: Text('Activos')),
                    ButtonSegment(value: 'trash', label: Text('Eliminados')),
                  ],
                  selected: <String>{_selectedView},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedView = newSelection.first;
                      _currentPage = 1;
                    });
                    _loadUsers();
                  },
                ),
              ),
              // Indicador de carga o mensaje de vacío
              if (userProvider.isLoading)
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
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("Nombre")),
                      DataColumn(label: Text("Correo")),
                      DataColumn(label: Text("Teléfono")),
                      DataColumn(label: Text("Anexo")),
                      DataColumn(label: Text("Acciones")),
                    ],
                    rows: _buildRows(userProvider, isAdmin),
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
                Text("Nombre: ${user.name}"),
                const SizedBox(height: 8),
                Text("Correo electronico: ${user.email}"),
                const SizedBox(height: 8),
                Text("Estado: ${user.estado}"),
                const SizedBox(height: 8),
                Text("Telefono: ${user.telefono}"),
                const SizedBox(height: 8),
                Text("Anexo: ${user.anexo}"),
                const SizedBox(height: 8),
                Text("Última Conexión: ${user.ultimaConexion}"),
                const SizedBox(height: 8),
                Text("Rol: ${user.rol}"),
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
                        await context
                            .read<UserProvider>()
                            .updateUser(user.id!.toInt(), updatedUser);
                        _loadUsers(); // Actualizar la lista de usuarios
                        Navigator.of(context).pop();
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
}
