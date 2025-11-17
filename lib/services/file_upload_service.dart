import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:twad/api/api_config.dart';
import '../api/api_client.dart';

class UploadService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String type,
  }) async {
    try {
      final file = File(filePath);
      final fileName = file.uri.pathSegments.last;

      final formData = FormData.fromMap({
        'file_name': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('application', 'octet-stream'), 
        ),
      });

      final response = await _apiClient.post(
        AppConfig.uploadFile,
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Upload failed',
        };
      }
    } on DioException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  Future<Map<String, dynamic>> deleteFile({required String fileName}) async {
    try {
      final response = await _apiClient.post(
        AppConfig.deleteFile,
        data: {
          "file_name": fileName,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Delete failed',
        };
      }
    } on DioException catch (e) {
      throw Exception('Delete failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
