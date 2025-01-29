import 'package:flutter/material.dart';

class SearchTable extends StatefulWidget {
  const SearchTable({super.key});

  @override
  _SearchTableState createState() => _SearchTableState();
}

class _SearchTableState extends State<SearchTable> {
  final List<Map<String, String>> tableData = [
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
                Text("Dirección: ${rowData['address']}"),
                const SizedBox(height: 8),
                Text("Cargo: ${rowData['position']}"),
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

  int currentPage = 1;
  final int rowsPerPage = 2;

  List<Map<String, String>> get paginatedData {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = startIndex + rowsPerPage;
    return tableData.sublist(
      startIndex,
      endIndex > tableData.length ? tableData.length : endIndex,
    );
  }

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
                        setState(() {
                          rowData['name'] = nameController.text;
                          rowData['email'] = emailController.text;
                          rowData['phone'] = phoneController.text;
                          rowData['anexo'] = anexoController.text;
                        });
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

  @override
  Widget build(BuildContext context) {
    final totalPages = (tableData.length / rowsPerPage).ceil();

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
                hintText: 'Ingrese un nombre, correo, teléfono o anexo',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {},
            ),
          ),
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
              rows: paginatedData.map((row) {
                return DataRow(cells: [
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        showInfoModal(context, row);
                      },
                    ),
                  ),
                  DataCell(Text(row["name"]!)),
                  DataCell(Text(row["email"]!)),
                  DataCell(Text(row["phone"]!)),
                  DataCell(Text(row["anexo"]!)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showEditModal(context, row);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              tableData.remove(row);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 1
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                ),
                for (int i = 1; i <= totalPages; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            i == currentPage ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          currentPage = i;
                        });
                      },
                      child: Text("$i"),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: currentPage < totalPages
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
