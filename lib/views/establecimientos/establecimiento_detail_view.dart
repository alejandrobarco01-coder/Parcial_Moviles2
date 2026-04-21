import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/establecimientos_service.dart';
import '../../models/establecimiento.dart';

class EstablecimientoDetailView extends StatefulWidget {
  final int id;
  const EstablecimientoDetailView({super.key, required this.id});

  @override
  State<EstablecimientoDetailView> createState() => _EstablecimientoDetailViewState();
}

class _EstablecimientoDetailViewState extends State<EstablecimientoDetailView> {
  final EstablecimientosService _service = EstablecimientosService();
  late Future<Establecimiento> _establecimientoFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _establecimientoFuture = _service.getById(widget.id);
  }

  Future<void> _deleteEstablecimiento() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este establecimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.delete(widget.id);
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Establecimiento'),
      ),
      body: FutureBuilder<Establecimiento>(
        future: _establecimientoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el establecimiento.'));
          }

          final est = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (est.logo.isNotEmpty)
                  Image.network(
                    est.logo,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 100),
                  )
                else
                  const Icon(Icons.store, size: 100),
                const SizedBox(height: 24),
                Text(est.nombre, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildInfoRow('NIT', est.nit),
                _buildInfoRow('Dirección', est.direccion),
                _buildInfoRow('Teléfono', est.telefono),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/establecimientos/${est.id}/edit');
                        setState(() {
                          _loadData();
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _deleteEstablecimiento,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
