import 'package:go_router/go_router.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/accidentes/accidentes_view.dart';
import '../views/establecimientos/establecimientos_list_view.dart';
import '../views/establecimientos/establecimiento_detail_view.dart';
import '../views/establecimientos/establecimiento_form_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
