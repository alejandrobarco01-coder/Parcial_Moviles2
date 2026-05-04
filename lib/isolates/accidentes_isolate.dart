import '../models/accidente.dart';

Map<String, dynamic> calcularEstadisticas(List<Accidente> accidentes) {
// print('[Isolate] Iniciado — ${accidentes.length} registros recibidos');
  final stopwatch = Stopwatch()..start();

  final Map<String, int> distribucionClase = {};
  final Map<String, int> distribucionGravedad = {};
  final Map<String, int> conteoBarrios = {};
  final Map<String, int> distribucionDia = {};

  final clasesValidas = {'Choque', 'Atropello', 'Volcamiento'};

  for (final accidente in accidentes) {
    // Clase de accidente
    String clase = accidente.claseDeAccidente ?? 'Otros';
    if (!clasesValidas.contains(clase)) {
      clase = 'Otros';
    }
    distribucionClase[clase] = (distribucionClase[clase] ?? 0) + 1;

    // Gravedad del accidente
    final gravedad = accidente.gravedadDelAccidente ?? 'Desconocida';
    distribucionGravedad[gravedad] = (distribucionGravedad[gravedad] ?? 0) + 1;

    // Barrio hecho
    final barrio = accidente.barrioHecho ?? 'Desconocido';
    conteoBarrios[barrio] = (conteoBarrios[barrio] ?? 0) + 1;

    // Día
    final dia = accidente.dia ?? 'Desconocido';
    distribucionDia[dia] = (distribucionDia[dia] ?? 0) + 1;
  }

  // Top 5 barrios
  var barriosList = conteoBarrios.entries.toList();
  barriosList.sort((a, b) => b.value.compareTo(a.value));
  final top5Barrios = barriosList.take(5).toList();

  stopwatch.stop();
// print('[Isolate] Completado en ${stopwatch.elapsedMilliseconds} ms');

  return {
    'distribucionClase': distribucionClase,
    'distribucionGravedad': distribucionGravedad,
    'top5Barrios': top5Barrios,
    'distribucionDia': distribucionDia,
  };
}
