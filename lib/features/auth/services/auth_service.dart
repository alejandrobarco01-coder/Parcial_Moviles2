// auth_service.dart
// Servicio de autenticación JWT con la API de VisionTic Parking
// Swagger: https://parking.visiontic.com.co/api/documentation
// Endpoint login: POST https://parking.visiontic.com.co/api/login
//
// Solo lógica de red — sin manejo de estado.
// Usa Dio (ya incluido en el proyecto) en lugar de http.

import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const _baseUrl = 'https://parking.visiontic.com.co/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ));

  /// Realiza el login con email y password.
  /// Retorna un mapa con 'access_token' (String) y 'user' (UserModel).
  /// Lanza [AuthException] con mensaje legible en caso de error.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw const AuthException('Respuesta inesperada del servidor');
      }

      return {
        'access_token': token,
        'user': UserModel.fromJson(userData),
      };
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const AuthException('Sin conexión a internet');
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw const AuthException('Credenciales incorrectas');
      }
      throw AuthException('Error del servidor (código ${statusCode ?? 'desconocido'})');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error inesperado: ${e.toString()}');
    }
  }
}
