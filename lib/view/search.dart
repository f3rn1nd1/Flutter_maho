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
  final TextEditingController _searchController =
      TextEditingController(); // Controlador para el campo de búsqueda
  List<User> _filteredUsers = []; // Lista de usuarios filtrados

  @override
  void initState() {
    super.initState();

    // Obtener el proveedor de usuarios
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Verificar si el usuario es admin o no
    final isAdmin = userProvider.currentUser?.admin ==
        1; // Asume que `currentUser` tiene un campo `admin`

    // Llamar al método correspondiente según el tipo de usuario
    if (isAdmin) {
      userProvider.getUsers().then((_) {
        // Inicializar la lista filtrada con todos los usuarios
        _filteredUsers = userProvider.users;
      });
    } else {
      userProvider.infoUsers().then((_) {
        // Inicializar la lista filtrada con todos los usuarios
        _filteredUsers = userProvider.users;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Limpiar el controlador
    super.dispose();
  }

  // Función para filtrar usuarios
  void _filterUsers(String query, List<User> allUsers) {
    setState(() {
      if (query.isEmpty) {
        // Si la consulta está vacía, mostrar todos los usuarios
        _filteredUsers = allUsers;
      } else {
        // Filtrar usuarios que coincidan con la consulta
        _filteredUsers = allUsers
            .where((user) =>
                user.name!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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

        return Card(
          elevation: 5,
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController, // Asignar el controlador
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    hintText: 'Ingrese un nombre',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    // Filtrar usuarios cada vez que el texto cambia
                    _filterUsers(value, userProvider.users);
                  },
                ),
              ),
              if (userProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (userProvider.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    userProvider.errorMessage,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
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
                      DataColumn(label: Text("")), // Botón "+"
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
            ],
          ),
        );
      },
    );
  }

  // Función para mostrar el modal de información
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

  // Función para mostrar el modal de edición
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
                      child: const Text("Guardar"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancelar"),
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
