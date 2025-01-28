import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class SearchTable extends StatefulWidget {
  const SearchTable({Key? key}) : super(key: key);

  @override
  _SearchTableState createState() => _SearchTableState();
}

class _SearchTableState extends State<SearchTable> {
  late TextEditingController _searchController;
  bool _isFirstLoad = true; // Controla la carga inicial

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        final userController =
            Provider.of<UserController>(context, listen: false);
        userController.loadInfoAllUsers(
            '498|G3w7lIFALHORlNAY4t5z8NeuSlR8hIjZImdAILxR'); // Token de ejemplo
        setState(() {
          _isFirstLoad = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        return Scaffold(
          appBar: AppBar(title: Text('User Table')),
          body: userController.isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: (value) {
                          userController.loadInfoAllUsers(
                            '498|G3w7lIFALHORlNAY4t5z8NeuSlR8hIjZImdAILxR',
                            search: value,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Correo')),
                            DataColumn(label: Text('Rol')),
                          ],
                          rows: userController.users.map((user) {
                            return DataRow(cells: [
                              DataCell(Text(user['name'])),
                              DataCell(Text(user['email'])),
                              DataCell(Text(user['role'] ?? 'N/A')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
