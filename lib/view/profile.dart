import 'package:flutter/material.dart';
import 'search.dart'; // Importar la tabla de búsqueda

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Datos aleatorios del estudiante
  final String studentName = "Juan Pérez";
  final int studentAge = 22;
  final String studentEmail = "juan.perez@example.com";
  final String studentAddress = "Calle Falsa 123, Ciudad";
  final String studentPhone = "+1 234 567 890";
  final String studentImageUrl =
      "https://via.placeholder.com/150"; // Imagen de perfil aleatoria

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para determinar el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Definimos un breakpoint para dispositivos móviles (por ejemplo, 600 píxeles)
    const mobileBreakpoint = 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Perfil del Estudiante"),
      ),
      body: screenWidth < mobileBreakpoint
          ? _buildMobileLayout() // Diseño para móviles
          : _buildDesktopLayout(), // Diseño para escritorio/tablet
    );
  }

  // Diseño para móviles (una columna vertical)
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Perfil del estudiante
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(studentImageUrl),
                    radius: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Edad: $studentAge años",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    studentEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Dirección: $studentAddress",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Teléfono: $studentPhone",
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
          ),
          const SizedBox(height: 16),
          // Tabla de datos (usando SearchTable)
          const SearchTable(), // Llamada al widget SearchTable
        ],
      ),
    );
  }

  // Diseño para escritorio/tablet (dos columnas horizontales)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: Perfil del estudiante
        Expanded(
          flex: 4, // Equivalente a col-4 en Bootstrap
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(studentImageUrl),
                    radius: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Edad: $studentAge años",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    studentEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Dirección: $studentAddress",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Teléfono: $studentPhone",
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
          ),
        ),
        const SizedBox(width: 16), // Espaciado entre columnas
        // Columna derecha: Tabla de datos (usando SearchTable)
        Expanded(
          flex: 8, // Equivalente a col-8 en Bootstrap
          child: const SearchTable(), // Llamada al widget SearchTable
        ),
      ],
    );
  }
}
