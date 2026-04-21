import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/accidentes_service.dart';
import '../../isolates/accidentes_isolate.dart';
import '../../models/accidente.dart';

class AccidentesView extends StatefulWidget {
  const AccidentesView({super.key});

  @override
  State<AccidentesView> createState() => _AccidentesViewState();
}

class _AccidentesViewState extends State<AccidentesView> {
  final AccidentesService _accidentesService = AccidentesService();
  
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadAndProcessData();
  }

  Future<void> _loadAndProcessData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Accidente> accidentes = await _accidentesService.fetchAccidentes();
      final stats = await compute(calcularEstadisticas, accidentes);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Accidentes'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAndProcessData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildChartPlaceholder(),
            _buildChartPlaceholder(),
            _buildChartPlaceholder(),
            _buildChartPlaceholder(),
          ],
        ),
      );
    }

    if (_stats == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildChartContainer(
          title: 'Distribución por Clase de Accidente',
          child: _buildPieChart(Map<String, int>.from(_stats!['distribucionClase'])),
        ),
        _buildChartContainer(
          title: 'Distribución por Gravedad',
          child: _buildPieChart(Map<String, int>.from(_stats!['distribucionGravedad'])),
        ),
        _buildChartContainer(
          title: 'Top 5 Barrios con más accidentes',
          child: _buildHorizontalBarChart((_stats!['top5Barrios'] as List).cast<MapEntry<String, int>>()),
        ),
        _buildChartContainer(
          title: 'Distribución por Día de la Semana',
          child: _buildBarChart(Map<String, int>.from(_stats!['distribucionDia'])),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 20, width: 200, color: Colors.grey),
            const SizedBox(height: 16),
            Expanded(child: Container(color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: child),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    if (data.isEmpty) return const Center(child: Text('No hay datos'));
    
    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.brown];
    int colorIndex = 0;

    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    data.forEach((key, value) {
      final color = colors[colorIndex % colors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: value.toDouble(),
          title: '$value',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      legendItems.add(_buildLegendItem(color, key));
      colorIndex++;
    });

    return Column(
      children: [
        Expanded(child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40))),
        Wrap(spacing: 8, runSpacing: 4, children: legendItems),
      ],
    );
  }

  Widget _buildHorizontalBarChart(List<MapEntry<String, int>> data) {
    if (data.isEmpty) return const Center(child: Text('No hay datos'));
    
    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].key, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].value.toDouble(),
                color: Colors.blueAccent,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    if (data.isEmpty) return const Center(child: Text('No hay datos'));
    
    final entries = data.entries.toList();
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(entries[value.toInt()].key.substring(0, 3), style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(entries.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entries[index].value.toDouble(),
                color: Colors.teal,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
