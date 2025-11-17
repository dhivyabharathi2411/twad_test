import 'package:dio/dio.dart';
import '../../api/api_client.dart';
import '../../api/api_config.dart';
import 'maintenance_model.dart';

class MaintenanceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getMaintenanceWork(MaintenanceModel maintenance) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getMaintenanceWork,
        data: maintenance.toJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];

        final works = list.map((json) => MaintenanceWork.fromJson(json)).toList();

        return {
          'success': true,
          'data': works,
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

class MaintenanceWork {
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  MaintenanceWork({
    this.description,
    this.startDate,
    this.endDate,
  });

  factory MaintenanceWork.fromJson(Map<String, dynamic> json) {
    return MaintenanceWork(
      description: json['description'] as String?,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['expected_completion_date'] != null
          ? DateTime.tryParse(json['expected_completion_date'])
          : null,
    );
  }
}
