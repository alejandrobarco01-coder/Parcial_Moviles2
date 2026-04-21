import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/accidente.dart';

class AccidentesService {
  final Dio _dio = Dio();

  Future<List<Accidente>> fetchAccidentes() async {
    try {
      final baseUrl = dotenv.env['BASE_URL_ACCIDENTES'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('BASE_URL_ACCIDENTES no está configurado en el archivo .env');
      }

      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          r'$limit': 100000,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Accidente.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener accidentes: código ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('DioException al obtener accidentes: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener accidentes: $e');
    }
  }
}
