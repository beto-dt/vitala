import 'package:flutter/material.dart';
import 'theme/colors.dart';
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VITALA', style: text.headlineMedium),
              Text('teleconsultas por video', style: text.labelMedium),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: VitalaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: VitalaColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu consulta, sin salas de espera',
                        style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Crea una sala, comparte el código y atiende por video — sin instalar nada.',
                      style: text.bodyMedium!.copyWith(color: VitalaColors.inkSoft),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Crear sala'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: VitalaColors.teal),
                        foregroundColor: VitalaColors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Unirme con código'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
