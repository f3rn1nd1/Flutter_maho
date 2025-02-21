import 'package:flutter/material.dart';
import 'package:projects/providers/user_provider.dart';
import 'package:provider/provider.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> userData) {
    // Obtén el provider del contexto
    final userProvider = Provider.of<UserProvider>(context);

    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(userData),
          const SizedBox(height: 16),
          // Ya no es const porque userProvider.currentUser es un valor en tiempo de ejecución
          SearchTable(currentUser: userProvider.currentUser),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> userData) {
    // Obtén el provider del contexto
    final userProvider = Provider.of<UserProvider>(context);

    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileCard(userData),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SearchTable(currentUser: userProvider.currentUser),
            ),
          ],
        ),
      ),
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

  void _showEditProfileDialog(
      BuildContext context, Map<String, dynamic> userData) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: userData['name']);
    final emailController = TextEditingController(text: userData['email']);
    final passwordController = TextEditingController();
    final passwordConfirmationController = TextEditingController();
    final phoneController = TextEditingController(text: userData['telefono']);
    final anexoController = TextEditingController(text: userData['anexo']);
    String selectedRol = userData['rol'] ?? 'Editor';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingrese un email válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña',
                      helperText: 'Dejar en blanco para mantener la actual',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordConfirmationController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nueva Contraseña',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (passwordController.text.isNotEmpty &&
                          value != passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  TextFormField(
                    controller: anexoController,
                    decoration: const InputDecoration(labelText: 'Anexo'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRol,
                    decoration: const InputDecoration(labelText: 'Rol *'),
                    items: const [
                      DropdownMenuItem(value: 'Editor', child: Text('Editor')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      selectedRol = value!;
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedUser = {
                    'name': nameController.text,
                    'email': emailController.text,
                    'rol': selectedRol,
                    'telefono': phoneController.text,
                    'anexo': anexoController.text,
                    'estado': userData['estado'] ?? 'activo',
                  };

                  if (passwordController.text.isNotEmpty) {
                    updatedUser['password'] = passwordController.text;
                    updatedUser['password_confirmation'] =
                        passwordConfirmationController.text;
                  }

                  try {
                    await context.read<UserProvider>().updateCurrentUser(
                        userData['id'], User.fromJson(updatedUser));

                    setState(() {
                      _currentUser = {
                        ..._currentUser!,
                        ...updatedUser,
                      };
                    });

                    final newUserData = {
                      ..._currentUser!,
                      ...updatedUser,
                    };
                    await AuthService.saveUserData(
                        await AuthService.getUserToken() ?? '', newUserData);

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Error al actualizar perfil: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            )
          ],
        );
      },
    );
  }
}
