import 'package:flutter/material.dart';

class SearchTable extends StatelessWidget {
  const SearchTable({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final tableData = [
      {
        "name": "Carlos Ramírez",
        "email": "carlos@example.com",
        "phone": "987654321",
        "anexo": "Ext. 101",
        "address": "Av. Siempre Viva 123, Ciudad",
        "position": "Gerente General",
      },
      {
        "name": "María Gómez",
        "email": "maria@example.com",
        "phone": "876543210",
        "anexo": "Ext. 102",
        "address": "Calle Principal 456, Ciudad",
        "position": "Jefa de Ventas",
      },
      {
        "name": "Luis Pérez",
        "email": "luis@example.com",
        "phone": "765432109",
        "anexo": "Ext. 103",
        "address": "Barrio Central 789, Ciudad",
        "position": "Coordinador de Proyectos",
      },
    ];

    // Función para mostrar el modal del botón "+"
    void showInfoModal(BuildContext context, Map<String, String> rowData) {
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                  // Contenido adicional con SelectableText
                  const Text(
                    "Dirección:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(rowData['address'] ?? "No disponible"),
                  const SizedBox(height: 8),
                  const Text(
                    "Cargo:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(rowData['position'] ?? "No disponible"),
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

    // Función para mostrar el modal del botón de edición
    void showEditModal(BuildContext context, Map<String, String> rowData) {
      final nameController = TextEditingController(text: rowData['name']);
      final emailController = TextEditingController(text: rowData['email']);
      final phoneController = TextEditingController(text: rowData['phone']);
      final anexoController = TextEditingController(text: rowData['anexo']);

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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                          // Aquí puedes manejar la lógica de guardar cambios
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
                // Aquí puedes agregar la lógica para filtrar la tabla
              },
            ),
          ),
          // Tabla
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
              rows: tableData.map((row) {
                return DataRow(cells: [
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        showInfoModal(
                            context, row); // Mostrar el modal de información
                      },
                    ),
                  ),
                  DataCell(SelectableText(row["name"]!)),
                  DataCell(SelectableText(row["email"]!)),
                  DataCell(SelectableText(row["phone"]!)),
                  DataCell(SelectableText(row["anexo"]!)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showEditModal(
                                context, row); // Mostrar el modal de edición
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Lógica para eliminar el elemento
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
}
