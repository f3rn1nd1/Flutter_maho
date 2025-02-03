import 'package:flutter/material.dart';
import 'package:projects/providers/user_provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'search.dart'; // Importar la tabla de búsqueda
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = widget.userData ?? await AuthService.getUserData();
    setState(() {
      _currentUser = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileBreakpoint = 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sistema de agenda MAHO"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : screenWidth < mobileBreakpoint
          ? _buildMobileLayout(_currentUser!)
          : _buildDesktopLayout(_currentUser!),
    );
  }

  void _logout(BuildContext context) {
    final UserProvider userProvider = UserProvider();
    userProvider.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileCard(userData),
          const SizedBox(height: 16),
          const SearchTable(), // Llamada al widget SearchTable
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> userData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _buildProfileCard(userData),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 8,
          child: const SearchTable(),
        ),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> userData) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: userData['image_url'] != null &&
                  userData['image_url'].isNotEmpty
                  ? NetworkImage(userData['image_url'])
                  : const AssetImage('/maho.png') as ImageProvider,
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              userData['name'] ?? 'Nombre no disponible',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Email: ${userData['email'] ?? 'No disponible'}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Rol: ${userData['rol'] ?? 'No disponible'}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Teléfono: ${userData['telefono'] ?? 'No disponible'}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showEditProfileDialog(context, userData);
              },
              child: const Text('Editar Perfil'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, Map<String, dynamic> userData) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: userData['name']);
    final _emailController = TextEditingController(text: userData['email']);
    final _phoneController = TextEditingController(text: userData['telefono']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su teléfono';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedUser = {
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'telefono': _phoneController.text,
                  };

                  final userProvider = UserProvider();
                  await userProvider.updateUser(userData['id'], User.fromJson(updatedUser));
                  _loadUserData();

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}