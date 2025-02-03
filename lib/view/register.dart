import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projects/providers/user_provider.dart'; // Importa el provider

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _anexoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variable para ocultar/mostrar la contraseña
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); // Accede al provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5, // Sombra de la tarjeta
            margin: const EdgeInsets.all(16), // Márgenes exteriores
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
            ),
            child: Container(
              width: 400, // Ancho fijo para la tarjeta
              padding: const EdgeInsets.all(20), // Márgenes internos
              child: Column(
                mainAxisSize: MainAxisSize.min, // Tamaño mínimo de la columna
                children: [
                  // Título de la tarjeta
                  const Text(
                    'Registro de Usuario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de nombre
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Campo de correo electrónico
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  // Campo de telefono
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Telefono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_iphone),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _anexoController,
                    decoration: const InputDecoration(
                      labelText: 'Anexo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Campo de contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Campo de confirmar contraseña
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón de registro
                  ElevatedButton(
                    onPressed: () async {
                      // Validar los campos
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text('Por favor, completa todos los campos'),
                          ),
                        );
                      } else if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Las contraseñas no coinciden'),
                          ),
                        );
                      } else {
                        // Crear un mapa con los datos del usuario
                        Map<String, dynamic> userData = {
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'telefono': _telefonoController.text,
                          'anexo': _anexoController.text,
                          'password': _passwordController.text,
                          'password_confirmation': _passwordController.text,
                        };

                        try {
                          // Llamar al método register del provider
                          final response =await userProvider.register(userData);

                          // Mostrar mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registro exitoso'),
                            ),
                          );

                          // Navegar a otra vista después del registro (opcional)
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const LoginPage()),
                          // );
                        } catch (e) {
                          // Mostrar mensaje de error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                      const Size(double.infinity, 50), // Ancho completo
                    ),
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}