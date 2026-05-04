// app_router.dart
// Configuración de rutas con GoRouter (router de referencia).
// La lógica de sesión persistida se maneja en main.dart.
// Este archivo exporta appRouter como fallback; el router principal
// es construido dinámicamente en main.dart con initialRoute apropiada.

import 'package:go_router/go_router.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/accidentes/accidentes_view.dart';
import '../views/establecimientos/establecimientos_list_view.dart';
import '../views/establecimientos/establecimiento_detail_view.dart';
import '../views/establecimientos/establecimiento_form_view.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/evidence_screen.dart';

// Router de referencia (la app real usa el router construido en main.dart)
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // ── Rutas de Autenticación JWT ──────────────────────────────
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/evidence',
      builder: (context, state) => const EvidenceScreen(),
    ),

    // ── Rutas existentes del proyecto ────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/accidentes',
      builder: (context, state) => const AccidentesView(),
    ),
    GoRoute(
      path: '/establecimientos',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    GoRoute(
      path: '/establecimientos/new',
      builder: (context, state) => const EstablecimientoFormView(),
    ),
    GoRoute(
      path: '/establecimientos/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '') ?? 0;
        return EstablecimientoDetailView(id: id);
      },
    ),
    GoRoute(
      path: '/establecimientos/:id/edit',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '') ?? 0;
        return EstablecimientoFormView(id: id);
      },
    ),
  ],
);
