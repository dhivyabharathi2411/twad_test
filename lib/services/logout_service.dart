import 'package:twad/api/api_client.dart';
import 'package:twad/api/api_config.dart';
import 'package:twad/services/api_setup.dart';
import 'package:twad/utils/simple_encryption.dart';

class LogoutService {
  final ApiClient _apiClient;

  LogoutService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiSetup.apiClient;

  Future<Map<String, dynamic>> logout() async {
    try {
      // Call logout API
      final userData = await SimpleUsage.getCurrentUser();

      if (userData == null) {
        return {
          'success': false,
          'message': 'User not logged in',
          'error': 'No user data available',
        };
      }

      // Extract public_id from user data
      final publicId =
          userData['public_id'] ?? userData['id'] ?? userData['userid'];

      if (publicId == null) {
        return {
          'success': false,
          'message': 'Public ID not found in user data',
          'error': 'Missing public_id field',
        };
      }

      // Extract additional header data from user data
      final userId =
          userData['userid'] ?? userData['user_id'] ?? userData['id'];
      final userType =
          userData['usertype'] ?? userData['user_type'] ?? 'public';
      final role = userData['role'] ?? userData['user_role'] ?? 'user';
      final deviceId =
          userData['deviceid'] ??
          userData['device_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final deviceType =
          userData['devicetype'] ?? userData['device_type'] ?? 'mobile';
      final deviceToken =
          userData['devicetoken'] ?? userData['device_token'] ?? '0';

      // Prepare request body with public_id
      final requestBody = {'public_id': publicId};

      // Prepare additional headers
      final additionalHeaders = {
        'user_id': userId?.toString() ?? '',
        'user_type': userType?.toString() ?? 'public',
        'role': role?.toString() ?? 'user',
        'device_id': deviceId?.toString() ?? '',
        'device_type': deviceType?.toString() ?? 'mobile',
        'device_token': deviceToken?.toString() ?? '0',
      };

      // Make logout API call
      final response = await _apiClient.get(
        AppConfig.logoutEndpoint,
        params: additionalHeaders,
      );

      // Clear local data after successful API call
      await SimpleUsage.logout();

      // Clear token from API client
      _apiClient.updateToken(null);
      _apiClient.clearCache();

      return {'success': true, 'message': 'Logout successful'};
    } catch (e) {
      // Even if API call fails, clear local data
      await SimpleUsage.logout();
      _apiClient.updateToken(null);
      _apiClient.clearCache();

      return {
        'success': true,
        'message': 'Logout completed (with errors)',
        'error': e.toString(),
      };
    }
  }
}
