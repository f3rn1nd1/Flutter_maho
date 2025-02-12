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

  void _loadUsers() async {
    // Obtén los datos del usuario desde AuthService
    final userData = await AuthService.getUserData();

    // Verifica si el usuario es admin (ajusta la validación según cómo se guarden los datos)
    bool isAdmin = userData != null && userData['admin']?.toString() == "1";

    // Obtén el provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Dependiendo del rol y la vista seleccionada, realiza la petición correspondiente
    if (isAdmin) {
      if (_selectedView == 'active') {
        await userProvider.getUsers(page: _currentPage);
        setState(() {
          _filteredUsers = userProvider.users;
        });
      } else {
        await userProvider.getTrashUsers(page: _currentPage);
        setState(() {
          _filteredUsers = userProvider.users;
        });
      }
    } else {
      if (_selectedView == 'active') {
        await userProvider.infoUsers(page: _currentPage);
        setState(() {
          _filteredUsers = userProvider.users;
        });
      } else {
        // En caso de que el usuario no admin seleccione "Eliminados", puedes mostrar un mensaje o definir otra acción
        setState(() {
          _filteredUsers = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes permisos para ver usuarios eliminados.')),
        );
      }
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
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
    });
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
              Padding(
                padding: const EdgeInsets.all(
                    16.0), // Padding para el Row de búsqueda
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
              Padding(
                padding: const EdgeInsets.all(
                    16.0), // Padding para el SegmentedButton
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
                      _loadUsers();
                    });
                  },
                ),
              ),
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
                    rows: _filteredUsers.map((user) {
                      return DataRow(cells: [
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.blue),
                            onPressed: () => showInfoModal(context, user),
                          ),
                        ),
                        DataCell(SelectableText(user.name.toString())),
                        DataCell(SelectableText(user.email.toString())),
                        DataCell(SelectableText(user.telefono.toString())),
                        DataCell(SelectableText(user.anexo.toString())),
                        DataCell(
                          Row(
                            children: [
                              if (isAdmin)
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => showEditModal(context, user),
                                ),
                              if (isAdmin)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      userProvider.deleteUser(user.id!.toInt()),
                                ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const Divider(),
                Text("Ultima Conexion: ${user.ultimaConexion}"),
                const SizedBox(height: 8),
                Text("Rol: ${user.rol}"),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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

  // Modal de edición
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
