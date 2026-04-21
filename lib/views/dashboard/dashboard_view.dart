import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/accidentes_service.dart';
import '../../services/establecimientos_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AccidentesService _accidentesService = AccidentesService();
  final EstablecimientosService _establecimientosService = EstablecimientosService();

  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = Future.wait([
      _accidentesService.fetchAccidentes(),
      _establecimientosService.getAll(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;

          if (hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error al cargar datos:\n${snapshot.error}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          }

          int numAccidentes = 0;
          int numEstablecimientos = 0;

          if (snapshot.hasData) {
            numAccidentes = (snapshot.data![0] as List).length;
            numEstablecimientos = (snapshot.data![1] as List).length;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard(
                  title: 'Estadísticas de Accidentes',
                  count: numAccidentes,
                  isLoading: isLoading,
                  icon: Icons.car_crash,
                  color: Colors.orange,
                  onTap: () => context.push('/accidentes'),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Gestión de Establecimientos',
                  count: numEstablecimientos,
                  isLoading: isLoading,
                  icon: Icons.store,
                  color: Colors.blue,
                  onTap: () => context.push('/establecimientos'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required int count,
    required bool isLoading,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Skeletonizer(
                enabled: isLoading,
                child: Text(
                  isLoading ? '000000' : '$count Registros',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
