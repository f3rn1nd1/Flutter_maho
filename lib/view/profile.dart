import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Estudiante'),
      ),
      body: Center(
        child: Card(
          elevation: 5, // Sombra de la tarjeta
          margin: const EdgeInsets.all(16), // Márgenes exteriores
          child: Padding(
            padding: const EdgeInsets.all(16), // Márgenes internos
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tamaño mínimo de la columna
              children: [
                // Imagen de perfil
                CircleAvatar(
                  backgroundImage: NetworkImage(studentImageUrl),
                  radius: 50, // Tamaño del círculo
                ),
                const SizedBox(height: 16), // Espaciado
                // Nombre del estudiante
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8), // Espaciado
                // Edad del estudiante
                Text(
                  "Edad: $studentAge años",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8), // Espaciado
                // Correo electrónico del estudiante
                Text(
                  studentEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8), // Espaciado
                // Dirección del estudiante
                Text(
                  "Dirección: $studentAddress",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8), // Espaciado
                // Teléfono del estudiante
                Text(
                  "Teléfono: $studentPhone",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16), // Espaciado
                // Botón de acción (opcional)
                ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
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
    );
  }
}
