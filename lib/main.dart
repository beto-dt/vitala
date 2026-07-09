import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const VitalaApp());
}

class VitalaApp extends StatelessWidget {
  const VitalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitala — teleconsultas',
      theme: vitalaTheme(),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
