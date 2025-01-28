import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'view/login.dart';


Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Carga las variables de entorno
  runApp(const MyApp());
}

void runApp(MyApp myApp) {
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
