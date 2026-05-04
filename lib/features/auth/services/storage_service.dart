// storage_service.dart
// Gestión de sesión con doble almacenamiento:
//   - SharedPreferences: datos no sensibles (nombre, email)
//   - FlutterSecureStorage: datos sensibles (access_token)
//
// Credenciales de prueba VisionTic Parking:
//   Email: testjwt@visiontic.co
//   Password: Test1234!
//   (Registrado via POST https://parking.visiontic.com.co/api/register)

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class StorageService {
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyAccessToken = 'access_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Guarda la sesión completa:
  /// - Nombre y email en SharedPreferences (no sensibles)
  /// - Token de acceso en FlutterSecureStorage (sensible)
  Future<void> saveSession(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await _secureStorage.write(key: _keyAccessToken, value: token);
  }

  /// Borra todos los datos de sesión
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await _secureStorage.delete(key: _keyAccessToken);
  }

  /// Obtiene el token de acceso desde almacenamiento seguro
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  /// Obtiene el nombre de usuario desde SharedPreferences
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Obtiene el email desde SharedPreferences
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }
}
