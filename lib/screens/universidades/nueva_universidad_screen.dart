// lib/screens/universidades/nueva_universidad_screen.dart
// Formulario para registrar una nueva universidad en Firestore.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/universidad_service.dart';
import '../../models/universidad.dart';

class NuevaUniversidadScreen extends StatefulWidget {
  const NuevaUniversidadScreen({super.key});

  @override
  State<NuevaUniversidadScreen> createState() =>
      _NuevaUniversidadScreenState();
}

class _NuevaUniversidadScreenState extends State<NuevaUniversidadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nitCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _webCtrl = TextEditingController();

  bool _guardando = false;

  @override
  void dispose() {
    _nitCtrl.dispose();
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  // ── Validadores ───────────────────────────────────────────────────────────

  String? _validarRequerido(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $campo es obligatorio.';
    }
    return null;
  }

  String? _validarPaginaWeb(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo página web es obligatorio.';
    }
    final trimmed = value.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'La URL debe comenzar con "http://" o "https://".';
    }
    return null;
  }

  // ── Envío ─────────────────────────────────────────────────────────────────

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final nueva = Universidad(
      nit: _nitCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      paginaWeb: _webCtrl.text.trim(),
    );

    try {
      await UniversidadService().crearUniversidad(nueva);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Universidad registrada exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Universidad'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _nitCtrl,
                label: 'NIT',
                hint: 'Ej: 890.123.456-7',
                icon: Icons.badge_outlined,
                validator: (v) => _validarRequerido(v, 'NIT'),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _nombreCtrl,
                label: 'Nombre',
                hint: 'Nombre de la universidad',
                icon: Icons.school_outlined,
                validator: (v) => _validarRequerido(v, 'nombre'),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _direccionCtrl,
                label: 'Dirección',
                hint: 'Ej: Cra 27A #48-144, Tuluá',
                icon: Icons.location_on_outlined,
                validator: (v) => _validarRequerido(v, 'dirección'),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _telefonoCtrl,
                label: 'Teléfono',
                hint: 'Ej: +57 602 2242202',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => _validarRequerido(v, 'teléfono'),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _webCtrl,
                label: 'Página web',
                hint: 'https://www.ejemplo.edu.co',
                icon: Icons.language_outlined,
                keyboardType: TextInputType.url,
                validator: _validarPaginaWeb,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_guardando ? 'Guardando...' : 'Guardar universidad'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
    );
  }
}
