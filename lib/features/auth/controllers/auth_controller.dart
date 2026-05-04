// auth_controller.dart
// Controlador de autenticación usando Provider para gestión de estado.
// Maneja los estados: isLoading, errorMessage, currentUser.
// El manejo de errores se centraliza aquí, nunca en la vista.

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Realiza el login, guarda sesión y actualiza el estado.
  /// Retorna true si fue exitoso, false si hubo error.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.login(email, password);
      final user = result['user'] as UserModel;
      final token = result['access_token'] as String;

      await _storageService.saveSession(user, token);
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      // Manejo de errores centralizado en el controller
      String message = e.toString();
      if (e.toString().contains('Sin conexión')) {
        message = 'Sin conexión a internet';
      } else if (e.toString().contains('Credenciales')) {
        message = 'Credenciales incorrectas';
      } else if (e.toString().contains('Error del servidor')) {
        message = e.toString();
      } else {
        message = 'Error inesperado. Intenta de nuevo.';
      }
      _setError(message);
      _setLoading(false);
      return false;
    }
  }

  /// Cierra sesión: borra datos locales y limpia el estado.
  Future<void> logout() async {
    await _storageService.clearSession();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Carga el usuario desde almacenamiento local (para persistencia de sesión).
  Future<void> loadSessionFromStorage() async {
    final name = await _storageService.getUserName();
    final email = await _storageService.getUserEmail();
    if (name != null && email != null) {
      _currentUser = UserModel(name: name, email: email);
      notifyListeners();
    }
  }
}
