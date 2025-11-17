import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getFeedbackQuestions(int grievanceId) async {
    try {
      final requestBody = {
        'grievance_id': grievanceId,
        'type': "Mobile",
      };

      final response = await _apiClient.post(
        AppConfig.getFeedbackData,
        data: requestBody,
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
          'message': response.data['message'] ?? 'Failed to get feedback questions',
        };
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  Future<Map<String, dynamic>> submitFeedback(Map<String, dynamic> request) async {
  try {
    final response = await _apiClient.post(
      AppConfig.createFeedback,
      data: request,
    );

    if (response.statusCode == 200 && response.data['status'] == true) {
      return {
        'success': true,
        'message': response.data['message'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to submit feedback',
      };
    }
  } on DioException catch (e) {
    throw Exception('Network error: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
Future<Map<String, dynamic>> updateFeedback(Map<String, dynamic> request) async {
  try {
    final response = await _apiClient.post(
      AppConfig.updateFeedback,
      data: request,
    );

    if (response.statusCode == 200 && response.data['status'] == true) {
      return {
        'success': true,
        'message': response.data['message'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to submit feedback',
      };
    }
  } on DioException catch (e) {
    throw Exception('Network error: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
}
