import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';

class AcknowledgementService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> downloadAcknowledgement(int grievanceId) async {
    try {
      final requestBody = {
        'grievance_id': grievanceId,
      };

      final response = await _apiClient.post(
        AppConfig.downloadAcknowledgement,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'filePath': response.data['data'],
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to download acknowledgement',
        };
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
