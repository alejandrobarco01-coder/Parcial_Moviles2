// lib/screens/universidades/lista_universidades_screen.dart
// Pantalla que muestra en tiempo real la lista de universidades desde Firestore.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/universidad_service.dart';
import '../../models/universidad.dart';

class ListaUniversidadesScreen extends StatelessWidget {
  const ListaUniversidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UniversidadService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/universidades/nueva'),
        tooltip: 'Nueva universidad',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Universidad>>(
        stream: service.getUniversidades(),
        builder: (context, snapshot) {
          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar universidades: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final universidades = snapshot.data ?? [];

          // Lista vacía
          if (universidades.isEmpty) {
            return const Center(
              child: Text(
                'No hay universidades registradas',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Lista con datos
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: universidades.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = universidades[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  u.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('NIT: ${u.nit}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar universidad',
                  onPressed: () => _confirmarEliminar(context, service, u),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar.
  void _confirmarEliminar(
    BuildContext context,
    UniversidadService service,
    Universidad u,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar universidad'),
        content: Text('¿Deseas eliminar "${u.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmado) async {
      if (confirmado == true && u.id != null) {
        try {
          await service.eliminarUniversidad(u.id!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Universidad "${u.nombre}" eliminada.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }
}
