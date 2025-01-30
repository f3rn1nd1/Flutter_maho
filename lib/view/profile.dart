import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'search.dart'; // Importar la tabla de búsqueda

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
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : screenWidth < mobileBreakpoint
          ? _buildMobileLayout(_currentUser!)
          : _buildDesktopLayout(_currentUser!),
    );
  }

  // Diseño para móviles (una columna vertical)
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

  // Diseño para escritorio/tablet (dos columnas horizontales)
  Widget _buildDesktopLayout(Map<String, dynamic> userData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: Perfil del estudiante
        Expanded(
          flex: 4,
          child: _buildProfileCard(userData),
        ),
        const SizedBox(width: 16),
        // Columna derecha: Tabla de datos (usando SearchTable)
        Expanded(
          flex: 8,
          child: const SearchTable(),
        ),
      ],
    );
  }

  // Tarjeta de perfil reutilizable
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Perfil actualizado!'),
                  ),
                );
              },
              child: const Text('Editar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}