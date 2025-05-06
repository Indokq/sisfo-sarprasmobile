import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Pastikan file ini berada di direktori yang benar

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        // Rute lainnya bisa ditambahkan di sini jika ada
      },
      home: const LoginPage(),
    );
  }
}

