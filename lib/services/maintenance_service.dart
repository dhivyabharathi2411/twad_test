import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../data/models/maintenance_model.dart';

class MaintenanceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getMaintenanceWork(MaintenanceModel maintenance) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getMaintenanceWork,
        data: maintenance.toJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'data': response.data['data'], 
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to fetch maintenance work',
        };
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
