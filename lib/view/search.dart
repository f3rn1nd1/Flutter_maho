import 'package:flutter/material.dart';

class SearchTable extends StatefulWidget {
  const SearchTable({super.key});

  @override
  _SearchTableState createState() => _SearchTableState();
}

class _SearchTableState extends State<SearchTable> {
  bool _showAllColumns =
      false; // Estado para controlar la visibilidad de las columnas

  @override
  Widget build(BuildContext context) {
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // Aquí puedes agregar la lógica para filtrar la tabla
              },
            ),
          ),
          // Botón para expandir/colapsar la tabla

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                    label:
                        Text("Acciones")), // Columna de acciones al principio
                DataColumn(label: Text("Nombre")),
                DataColumn(label: Text("Correo")),
                DataColumn(label: Text("Rol")),
                if (_showAllColumns) DataColumn(label: Text("Teléfono")),
                if (_showAllColumns) DataColumn(label: Text("Anexo")),
                if (_showAllColumns) DataColumn(label: Text("Última conexión")),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Lógica para editar el elemento
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Lógica para eliminar el elemento
                          },
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text("Motaleb")),
                  DataCell(Text("example@gmail.com")),
                  DataCell(Text("Admin")),
                  if (_showAllColumns) DataCell(Text("12345678")),
                  if (_showAllColumns) DataCell(Text("12345678")),
                  if (_showAllColumns) DataCell(Text("No disponible")),
                ]),
                DataRow(cells: [
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Lógica para editar el elemento
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Lógica para eliminar el elemento
                          },
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text("Juan Pérez")),
                  DataCell(Text("example@gmail.com")),
                  DataCell(Text("Usuario")),
                  if (_showAllColumns) DataCell(Text("12345678")),
                  if (_showAllColumns) DataCell(Text("12345678")),
                  if (_showAllColumns) DataCell(Text("No disponible")),
                ]),
                DataRow(cells: [
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Lógica para editar el elemento
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Lógica para eliminar el elemento
                          },
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text("Ana López")),
                  DataCell(Text("example@gmail.com")),
                  DataCell(Text("Usuario")),
                  if (_showAllColumns) DataCell(Text("12345678")),
                  if (_showAllColumns) DataCell(Text("12345678")),
                  if (_showAllColumns) DataCell(Text("No disponible")),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
