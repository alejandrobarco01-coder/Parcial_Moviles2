import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../models/establecimiento.dart';

class EstablecimientosService {
  final Dio _dio = Dio();

  String get _baseUrl {
    final url = dotenv.env['BASE_URL_PARQUEADERO'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL_PARQUEADERO no está configurado en el archivo .env');
    }
    return url;
  }

  Future<List<Establecimiento>> getAll() async {
    try {
      final response = await _dio.get('$_baseUrl/establecimientos');
      if (response.statusCode == 200) {
        // La API de VisionTIC devuelve {"success":true,"data":[...]}
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Establecimiento.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener establecimientos: código ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('DioException al obtener establecimientos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener establecimientos: $e');
    }
  }

  Future<Establecimiento> getById(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/establecimientos/$id');
      if (response.statusCode == 200) {
        return Establecimiento.fromJson(response.data['data']);
      } else {
        throw Exception('Error al obtener el establecimiento: código ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('DioException al obtener el establecimiento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener el establecimiento: $e');
    }
  }

  Future<void> create(Map<String, dynamic> data, XFile? image) async {
    try {
      final formData = FormData.fromMap(data);

      if (image != null) {
        formData.files.add(MapEntry(
          'logo',
          MultipartFile.fromBytes(await image.readAsBytes(), filename: image.name),
        ));
      }

      await _dio.post(
        '$_baseUrl/establecimientos',
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception('DioException al crear el establecimiento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear el establecimiento: $e');
    }
  }

  Future<void> update(int id, Map<String, dynamic> data, XFile? image) async {
    try {
      final formDataMap = Map<String, dynamic>.from(data);

      final formData = FormData.fromMap(formDataMap);

      if (image != null) {
        formData.files.add(MapEntry(
          'logo',
          MultipartFile.fromBytes(await image.readAsBytes(), filename: image.name),
        ));
      }

      await _dio.post(
        '$_baseUrl/establecimiento-update/$id',
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception('DioException al actualizar el establecimiento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al actualizar el establecimiento: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('$_baseUrl/establecimientos/$id');
    } on DioException catch (e) {
      throw Exception('DioException al eliminar el establecimiento: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar el establecimiento: $e');
    }
  }
}
