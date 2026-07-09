import 'package:flutter/material.dart';
import '../data/vitala_api.dart';
import '../theme/colors.dart';
import 'call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = VitalaApi();
  bool _busy = false;

  Future<void> _createRoom() async {
    setState(() => _busy = true);
    try {
      final code = await _api.createRoom();
      final creds = await _api.getToken(code);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CallScreen(credentials: creds)),
      );
    } catch (_) {
      _showError('No pudimos crear la sala. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinWithCode() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unirme a una consulta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'VIT-XXXX'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim().toUpperCase()),
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    setState(() => _busy = true);
    try {
      final creds = await _api.getToken(code);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CallScreen(credentials: creds)),
      );
    } on RoomNotFoundException {
      _showError('Esa sala no existe o ya cerró.');
    } catch (_) {
      _showError('No pudimos conectarte. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
                    Text('Tu consulta, sin salas de espera', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Crea una sala, comparte el código y atiende por video — sin instalar nada.',
                      style: text.bodyMedium!.copyWith(color: VitalaColors.inkSoft),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _busy ? null : _createRoom,
                      child: Text(_busy ? 'Un momento…' : 'Crear sala'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _busy ? null : _joinWithCode,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: VitalaColors.teal),
                        foregroundColor: VitalaColors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
