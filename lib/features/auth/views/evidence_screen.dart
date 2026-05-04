// evidence_screen.dart
// Vista de Evidencia JWT — muestra datos de sesión local.
//
// Lee desde:
//   - SharedPreferences: nombre y email del usuario
//   - FlutterSecureStorage: presencia del token (sin exponerlo)
//
// Botón "Cerrar sesión": llama logout() y regresa a /login

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../services/storage_service.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();

  String? _userName;
  String? _userEmail;
  bool? _hasToken;
  bool _loadingData = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadSessionData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionData() async {
    final name = await _storageService.getUserName();
    final email = await _storageService.getUserEmail();
    final token = await _storageService.getToken();

    if (mounted) {
      setState(() {
        _userName = name;
        _userEmail = email;
        _hasToken = token != null && token.isNotEmpty;
        _loadingData = false;
      });
      _animController.forward();
    }
  }

  Future<void> _handleLogout() async {
    final controller = context.read<AuthController>();
    await controller.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
          ),
        ),
        child: SafeArea(
          child: _loadingData
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667EEA)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 15,
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified_user_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vista de Evidencia',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Datos de sesión JWT',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Tarjeta de datos del usuario
                          _buildCard(
                            title: 'Información del Usuario',
                            icon: Icons.person_rounded,
                            children: [
                              _buildDataRow(
                                id: 'evidence_name_row',
                                label: 'Nombre',
                                value: _userName ?? 'No disponible',
                                icon: Icons.badge_outlined,
                                source: 'SharedPreferences',
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildDataRow(
                                id: 'evidence_email_row',
                                label: 'Email',
                                value: _userEmail ?? 'No disponible',
                                icon: Icons.email_outlined,
                                source: 'SharedPreferences',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta del token
                          _buildCard(
                            title: 'Estado del Token',
                            icon: Icons.key_rounded,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (_hasToken == true
                                              ? const Color(0xFF48BB78)
                                              : const Color(0xFFE53E3E))
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _hasToken == true
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: _hasToken == true
                                          ? const Color(0xFF48BB78)
                                          : const Color(0xFFE53E3E),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _hasToken == true
                                              ? '✅ Token presente'
                                              : '❌ Sin token',
                                          key: const Key(
                                              'evidence_token_status'),
                                          style: TextStyle(
                                            color: _hasToken == true
                                                ? const Color(0xFF68D391)
                                                : const Color(0xFFFC8181),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'FlutterSecureStorage',
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tarjeta de fuentes de almacenamiento
                          _buildCard(
                            title: 'Fuentes de Almacenamiento',
                            icon: Icons.storage_rounded,
                            children: [
                              _buildStorageChip(
                                label: 'SharedPreferences',
                                desc: 'Nombre y email (no sensibles)',
                                icon: Icons.folder_open_rounded,
                                color: const Color(0xFF4299E1),
                              ),
                              const SizedBox(height: 10),
                              _buildStorageChip(
                                label: 'FlutterSecureStorage',
                                desc: 'Access Token (cifrado)',
                                icon: Icons.security_rounded,
                                color: const Color(0xFF667EEA),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Botón Cerrar Sesión
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              key: const Key('evidence_logout_button'),
                              onPressed: _handleLogout,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53E3E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF667EEA), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required String id,
    required String label,
    required String value,
    required IconData icon,
    required String source,
  }) {
    return Row(
      key: Key(id),
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                source,
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageChip({
    required String label,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
