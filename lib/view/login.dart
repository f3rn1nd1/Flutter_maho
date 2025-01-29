import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'profile.dart'; // Importar la vista de perfil
import 'register.dart'; // Importar la vista de registro

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      final authService = AuthService();
      final response = await authService.login({
        'email': email,
        'password': password,
      });

      // Guardar token y datos del usuario
      await AuthService.saveUserData(
        response['token'],
        response['user'],
      );

      if (!mounted) return;

      // Navegar a ProfilePage con datos del usuario
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(userData: response['user']),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Campo de correo electrónico
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Campo de contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Casilla de "Recuérdame"
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Recuérdame'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Botón de inicio de sesión
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50), // Ancho completo
                    ),
                    child: const Text('Ingresar'),
                  ),
                  const SizedBox(height: 16),
                  // Enlaces adicionales
                  TextButton(
                    onPressed: () {
                      // Acción para recuperar contraseña
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navegar a la vista de registro (RegisterPage)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text('¿No tienes una cuenta? Regístrate'),
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
