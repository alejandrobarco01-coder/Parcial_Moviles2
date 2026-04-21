import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/establecimientos_service.dart';
import '../../models/establecimiento.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() => _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  final EstablecimientosService _service = EstablecimientosService();
  
  late Future<List<Establecimiento>> _establecimientosFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _establecimientosFuture = _service.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Establecimientos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/establecimientos/new');
          setState(() {
            _loadData();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Establecimiento>>(
        future: _establecimientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Skeletonizer(
              enabled: true,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.image, size: 50),
                      title: Text('Nombre del Establecimiento'),
                      subtitle: Text('NIT: 000000000\nDirección: Calle Falsa 123'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay establecimientos registrados.'));
          }

          final establecimientos = snapshot.data!;

          return ListView.builder(
            itemCount: establecimientos.length,
            itemBuilder: (context, index) {
              final est = establecimientos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      est.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 50),
                    ),
                  ),
                  title: Text(est.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('NIT: ${est.nit}\nDir: ${est.direccion}\nTel: ${est.telefono}'),
                  isThreeLine: true,
                  onTap: () async {
                    await context.push('/establecimientos/${est.id}');
                    setState(() {
                      _loadData();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
