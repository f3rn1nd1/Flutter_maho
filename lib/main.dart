import 'package:flutter/material.dart';
import 'view/login.dart';

void main() {
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
