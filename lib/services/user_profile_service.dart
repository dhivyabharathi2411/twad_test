import 'package:twad/data/models/user_model.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';

import '../utils/simple_encryption.dart';
import 'api_setup.dart';
import 'package:dio/dio.dart';

/// User Profile API service for TWAD app - handles all profile-related API calls
class UserProfileService {
  final ApiClient _apiClient;

  UserProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiSetup.apiClient;

  /// Get user profile from API using POST with public_id
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userData = await SimpleUsage.getCurrentUser();
      if (userData == null) {
        throw Exception('User not logged in');
      }
      final userId = userData['userid'];
      if (userId == null) {
        throw Exception('User ID not found in stored data');
      }
      final requestBody = {'public_id': userId};

      // Make POST request with additional headers and no encryption
      final response = await _apiClient.post(
        AppConfig.profileEndpoint,
        data: requestBody,
        options: Options(extra: {'no_encrypt_header': true}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile loaded successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to load profile',
          'data': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load profile: $e',
        'error': e.toString(),
      };
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? pincode,
    int? districtId,
    int? blockId,
    int? villageId,
    int? habitationId,
    int? organisationId,
    int? corporationId,
    int? zoneId,
    int? zoneWardId,
    int? municipalityId,
    int? municipalityWardId,
    int? townPanchayatId,
    int? townPanchayatWardId,
    int? divisionId,
  }) async {
    try {
      // Get current user data to extract headers
      final userData = await SimpleUsage.getCurrentUser();

      if (userData == null) {
        return {
          'success': false,
          'message': 'User not logged in',
          'error': 'No user data available',
        };
      }

      // Extract header data from user data
      final userId =
          userData['userid'] ?? userData['user_id'] ?? userData['id'];
      final userType =
          userData['usertype'] ?? userData['user_type'] ?? 'public';
      final role = userData['role_id'] ?? userData['user_role'] ?? 'user';

      // Prepare additional headers
      final additionalHeaders = {
        'user_id': userId?.toString() ?? '',
        'user_type': userType?.toString() ?? 'public',
        'role_id': role?.toString() ?? 'user',
      };

      final requestBody = {
        "public_name": name,
        "public_address": address ?? "",
        "public_emailid": email,
        "public_pincode": pincode ?? "",
        "public_whatsappno": phone,
        "district_id": districtId ?? 0,
        "block_id": blockId ?? 0,
        "village_id": villageId ?? 0,
        "habitation_id": habitationId ?? 0,
        "organisation_id": organisationId ?? 0,
        "corporation_id": corporationId ?? 0,
        "zone_id": zoneId ?? 0,
        "zone_ward_id": zoneWardId ?? 0,
        "municipality_id": municipalityId ?? 0,
        "municipality_ward_id": municipalityWardId ?? 0,
        "town_panchayat_id": townPanchayatId ?? 0,
        "town_panchayat_ward_id": townPanchayatWardId ?? 0,
        "division_id": divisionId ?? 0,
      };

      // Set headers temporarily for this request
      final originalHeaders = Map<String, dynamic>.from(
        _apiClient.dio.options.headers,
      );
      _apiClient.dio.options.headers.addAll(additionalHeaders);

      try {
        final response = await _apiClient.post(
          AppConfig.updateProfileEndpoint,
          data: requestBody,
          options: Options(
            extra: {'no_encrypt_header': true},
            headers: additionalHeaders,
          ),
        );

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Profile updated successfully',
            'data': response.data,
          };
        } else {
          return {
            'success': false,
            'message': response.data['message'] ?? 'Failed to update profile',
            'data': response.data,
          };
        }
      } finally {
        // Restore original headers
        _apiClient.dio.options.headers = originalHeaders;
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile: $e',
        'error': e.toString(),
      };
    }
  }

  /// Get user profile with proper error handling
  Future<UserModel?> fetchUserProfile() async {
    try {
      final result = await getUserProfile();

      if (result['success'] == true) {
        final responseData = result['data'];

        // Parse the nested response structure
        if (responseData != null &&
            responseData['status'] == true &&
            responseData['data'] != null &&
            responseData['data'].isNotEmpty) {
          // Get the first user data from the array
          final userData = responseData['data'][0];

          return UserModel.fromJson(userData);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
