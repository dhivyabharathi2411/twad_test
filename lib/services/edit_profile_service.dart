import 'package:twad/api/api_client.dart';
import 'package:twad/api/api_config.dart';
import 'package:twad/services/api_setup.dart';
import 'package:twad/utils/simple_encryption.dart';

// Make userData a global variable
final Future<Map<String, dynamic>?> userData = SimpleUsage.getCurrentUser();

class EditProfileService {
  final ApiClient _apiClient;

  EditProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiSetup.apiClient;

  // Helper to get headers and publicId
  Future<Map<String, dynamic>?> getUserHeaders() async {
    final user = await userData;
    if (user == null) {
      
      return null;
    }

    final publicId = user['public_id'] ?? user['id'] ?? user['userid'];

    if (publicId == null) {
      
      return null;
    }


    final userId = user['userid'] ?? user['user_id'] ?? user['id'];
    final userType = user['usertype'] ?? user['user_type'] ?? 'public';
    final role = user['role_id'] ?? user['user_role'] ?? 'user';

   

    return {
      'publicId': publicId,
      'headers': {
        'user_id': userId?.toString() ?? '',
        'user_type': userType?.toString() ?? 'public',
        'role_id': role?.toString() ?? 'user',
      },
    };
  }
    Future<List<dynamic>> getDistrictList() async {
    try {
      final response = await _apiClient.post(AppConfig.getDistrictList,
      data: {
        "action_type": "getlist",
        "data":{}
      });
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch districts');
      }
    } catch (e) {
      throw Exception('Error in getDistrictList: $e');
    }
  }

  Future<List<dynamic>> getBlockByDistrict(int districtId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getBlockByDistrict,
        data: {'district_id': districtId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch blocks');
      }
    } catch (e) {
      throw Exception('Error in getBlockByDistrict: $e');
    }
  }

  Future<List<dynamic>> getVillageByBlock(int blockId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getVillageByBlock,
        data: {'block_id': blockId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch villages');
      }
    } catch (e) {
      throw Exception('Error in getVillageByBlock: $e');
    }
  }

  Future<List<dynamic>> getHabitationByVillage(int villageId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getHabitationByVillage,
        data: {'village_id': villageId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch habitations');
      }
    } catch (e) {
      throw Exception('Error in getHabitationByVillage: $e');
    }
  }

}
