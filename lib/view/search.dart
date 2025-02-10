import 'package:flutter/material.dart';
import 'package:projects/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projects/providers/user_provider.dart';
import '../models/user.dart';

class SearchTable extends StatefulWidget {
  const SearchTable({super.key});

  @override
  SearchTableState createState() => SearchTableState();
}

class SearchTableState extends State<SearchTable> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  int _currentPage = 1;

  void _onSearchPressed() {
    String query = _searchController.text.trim();
    _filterUsers(query);
  }

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAdmin = userProvider.currentUser?.admin == 1;

    // Cargar los usuarios de acuerdo con el rol
    if (isAdmin) {
      userProvider.getUsers(page: _currentPage).then((_) {
        _filteredUsers = userProvider.users;
      });
    } else {
      userProvider.infoUsers().then((_) {
        _filteredUsers = userProvider.users;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función de búsqueda en tiempo real
  void _filterUsers(String query) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        // Si la consulta está vacía, carga la primera página sin filtro
        _loadPage(1);
      } else {
        // Si hay una consulta, llama a getUsers con el parámetro search
        userProvider.getUsers(page: 1, search: query).then((_) {
          setState(() {
            _filteredUsers = userProvider.users;
          });
        });
      }
    });
  }

  // Función para manejar la paginación
  void _loadPage(int page) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getUsers(page: page).then((_) {
      setState(() {
        _filteredUsers = userProvider.users;
        _currentPage = page;
      });
    });
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

        return
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
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
                          onChanged: (value) {
                            // Opcional: Si quieres que busque en tiempo real al escribir, mantenlo
                          },
                        ),
                      ),
                      const SizedBox(width: 8), // Espaciado entre el campo de texto y el botón
                      ElevatedButton(
                        onPressed: _onSearchPressed,
                        child: const Text("Buscar"),
                      ),
                    ],
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
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
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
                                  children: [
                                    if (isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => showEditModal(context, user),
                                      ),
                                    if (isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
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
                    ),
                  ),
                // Paginación
                if (userProvider.pagination != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _currentPage > 1
                            ? () => _loadPage(_currentPage - 1)
                            : null,
                      ),
                      Text('Página $_currentPage'),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: _currentPage < userProvider.pagination!.totalPages
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      onPressed: () {
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
                        context.read<UserProvider>().updateUser(1, updatedUser);
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
