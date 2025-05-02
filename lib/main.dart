import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Pastikan file ini berada di direktori yang benar

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Opsional: hilangkan label debug
      home: LoginPage(),
    );
  }
}
