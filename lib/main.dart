import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa el paquete flutter_doten
import 'package:projects/providers/user_provider.dart';
import 'package:projects/services/auth_service.dart';
import 'package:projects/view/login.dart';
import 'package:projects/view/profile.dart';
import 'package:provider/provider.dart';

void main() async {
  // Carga las variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Login Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: FutureBuilder(
          future: AuthService.getUserToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return snapshot.hasData ? const ProfilePage() : const LoginPage();
          },
        ),
      ),
    );
  }
}
