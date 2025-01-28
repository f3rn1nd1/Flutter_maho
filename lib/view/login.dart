import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../controllers/user_controller.dart';
import '../models/user_response.dart';
import 'profile.dart'; // Importar la vista de perfil
import 'register.dart'; // Importar la vista de registro

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late UserController _userController; // Instancia del controlador.
  late Future<UserResponse> _futureUsers; // Futuro que obtendrá los usuarios.
  int _currentPage = 1; // Página actual para la paginación.



  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Verificar que los campos no estén vacíos
    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return; // Verificar si el widget está montado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    // URL de la API
<<<<<<< HEAD
    final url = Uri.parse('http://10.10.160.116:8888/api/login');
=======
    //final url = Uri.parse('http://10.10.160.116:8888/api/login');
    final url = Uri.parse("${dotenv.get('BASE_URL')}/login");

>>>>>>> 29b53941a24684ae6773062834b9724c591412b3

    try {
      // Hacer la solicitud POST
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      // Verificar si el widget está montado antes de usar el contexto
      if (!mounted) return;

      // Verificar el código de estado de la respuesta
      if (response.statusCode == 200) {
        // Si la solicitud es exitosa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );

        // Navegar a la vista de perfil (ProfilePage)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      } else {
        // Si la solicitud falla
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      // Verificar si el widget está montado antes de usar el contexto
      if (!mounted) return;

      // Manejar errores de conexión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
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
