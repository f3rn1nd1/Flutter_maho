import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projects/providers/user_provider.dart';
import '../models/user.dart';

class SearchTable extends StatefulWidget {
  const SearchTable({super.key});

  @override
  SearchTableState createState() => SearchTableState();
}

class SearchTableState extends State<SearchTable> {
  @override
  void initState() {
    super.initState();
    // Obtener los usuarios cuando el widget se inicializa
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar',
                hintText: 'Ingrese un nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // Filtrar usuarios según el valor de búsqueda
                userProvider.getUsers(search: value);
              },
            ),
          ),
          // Mostrar un indicador de carga si los datos están cargando
          if (userProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          // Mostrar un mensaje de error si ocurre un problema
          if (userProvider.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                userProvider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          // Tabla de usuarios
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("")), // Columna para el botón "+"
                DataColumn(label: Text("Nombre")),
                DataColumn(label: Text("Correo")),
                DataColumn(label: Text("Teléfono")),
                DataColumn(label: Text("Anexo")),
                DataColumn(label: Text("Acciones")),
              ],
              rows: userProvider.users.map((user) {
                return DataRow(cells: [
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        showInfoModal(
                            context, user); // Mostrar el modal de información
                      },
                    ),
                  ),
                  DataCell(Text(user.name.toString())),
                  DataCell(Text(user.email.toString())),
                  DataCell(Text(user.telefono.toString())),
                  DataCell(Text(user.anexo.toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showEditModal(
                                context, user); // Mostrar el modal de edición
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Lógica para eliminar el usuario
                            userProvider.deleteUser(user.id!.toInt());
                          },
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
                // Título del modal
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
                        Navigator.of(context).pop(); // Cierra el modal
                      },
                    ),
                  ],
                ),
                const Divider(),
                // Contenido adicional
                Text("Ultima Conexion: ${user.ultimaConexion}"),
                const SizedBox(height: 8),
                Text("Rol: ${user.rol}"),
                const SizedBox(height: 16),
                // Botón para cerrar
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el modal
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
                // Título del modal
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
                        Navigator.of(context).pop(); // Cierra el modal
                      },
                    ),
                  ],
                ),
                const Divider(),
                // Formulario de edición
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
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Lógica para guardar cambios
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
                        Navigator.of(context).pop(); // Cierra el modal
                      },
                      child: const Text("Guardar"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el modal
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
