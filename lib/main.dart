// main.dart
// Punto de entrada de la aplicación.
// Configura Provider con AuthController y determina la ruta inicial
// según si existe un token almacenado en flutter_secure_storage.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/services/storage_service.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/evidence_screen.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/accidentes/accidentes_view.dart';
import 'views/establecimientos/establecimientos_list_view.dart';
import 'views/establecimientos/establecimiento_detail_view.dart';
import 'views/establecimientos/establecimiento_form_view.dart';
import 'screens/universidades/lista_universidades_screen.dart';
import 'screens/universidades/nueva_universidad_screen.dart';
import 'services/universidad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }

  try {
    await Firebase.initializeApp();
    // Sembrar dato de ejemplo si la colección universidades está vacía
    await UniversidadService().sembrarSiVacia();
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  // Determinar ruta inicial según sesión persistida
  final storage = StorageService();
  final token = await storage.getToken();
  final initialRoute = (token != null && token.isNotEmpty) ? '/evidence' : '/login';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: _AppRouter(initialRoute: initialRoute),
    );
  }
}

class _AppRouter extends StatefulWidget {
  final String initialRoute;
  const _AppRouter({required this.initialRoute});

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: widget.initialRoute,
      routes: [
        // ── Autenticación JWT ─────────────────────────────────────
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/evidence',
          builder: (context, state) => const EvidenceScreen(),
        ),
        // ── Rutas existentes ──────────────────────────────────────
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
        // ── Universidades (Firebase Firestore) ────────────────────────────
        GoRoute(
          path: '/universidades',
          builder: (context, state) => const ListaUniversidadesScreen(),
        ),
        GoRoute(
          path: '/universidades/nueva',
          builder: (context, state) => const NuevaUniversidadScreen(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parcial 2 - Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
