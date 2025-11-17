import 'dart:convert';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../data/models/grievance_model.dart';
import '../utils/simple_encryption.dart';
import '../data/models/recent_grievance_model.dart';

class GrievanceService {
  final ApiClient _apiClient = ApiClient();


  Future<Map<String, dynamic>> getGrievanceCount() async {
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

      final response = await _apiClient.post(
        AppConfig.getGrievanceCountEntpoint,
        data: requestBody,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        return {'success': true, 'data': data};
      } else {
        throw Exception(
          'API returned error: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getRecentGrievances() async {
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
      final response = await _apiClient.post(
        AppConfig.getGrievanceListRecent,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> apiData = response.data['data'] ?? [];
        final List<RecentGrievanceModel> grievances = apiData
            .map((json) => RecentGrievanceModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': grievances,
          'message': response.data['message'],
        };
      } else {
        throw Exception(
          'API returned error: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<GrievanceModel>> fetchAllGrievances({
    String? fromDate,
    String? toDate,
    String? complaintStatus,
  }) async {
    try {
      final userData = await SimpleUsage.getCurrentUser();
      final userId = userData?['userid'];
      if (userId == null) throw Exception('User ID not found');

      final requestBody = {
        'public_id': userId,
        'from_date': fromDate ?? '',
        'to_date': toDate ?? '',
        'complaint_status': complaintStatus ?? '',
      };

      final response = await _apiClient.post(
        AppConfig.getGrievanceList,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> jsonList = response.data['data'] ?? [];
        return jsonList.map((json) => GrievanceModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch grievances',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<dynamic>> getGrievanceTypes() async {
    try {
      final response = await _apiClient.post(
        AppConfig.getGrievanceType,
        data: {"action_type": "getlist", "data": {}},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        var result = response.data['data'] ?? [];

        if (result is String) {
          result = jsonDecode(result);
        }

        return result;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch grievance types',
        );
      }
    } catch (e) {
      throw Exception('Error in getGrievanceTypes: $e');
    }
  }

  Future<List<dynamic>> getDistrictList() async {
    try {
      final response = await _apiClient.post(
        AppConfig.getDistrictList,
        data: {"action_type": "getlist", "data": {}},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch districts',
        );
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
        throw Exception(
          response.data['message'] ?? 'Failed to fetch habitations',
        );
      }
    } catch (e) {
      throw Exception('Error in getHabitationByVillage: $e');
    }
  }

  Future<List<dynamic>> getComplaintTypeList() async {
    try {
      final response = await _apiClient.post(
        AppConfig.getComplaintTypeList,
        data: {"action_type": "getlist", "data": {}},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch complaint types',
        );
      }
    } catch (e) {
      throw Exception('Error in getComplaintTypeList: $e');
    }
  }

  Future<List<dynamic>> getSubComplaintTypeByComplaint() async {
    try {
      final response = await _apiClient.post(
        AppConfig.getSubComplaintTypeByComplaint,
        data: {"action_type": "getlist", "data": {}},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch sub complaint types',
        );
      }
    } catch (e) {
      throw Exception('Error in getSubComplaintTypeByComplaint: $e');
    }
  }

  Future<List<dynamic>> getZoneByDistrict(
    int districtId,
    int corporationId,
  ) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getZoneByDistrict,

        data: {'district_id': districtId, 'corporation_id': corporationId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch zones');
      }
    } catch (e) {
      throw Exception('Error in getZoneByDistrict: $e');
    }
  }

  Future<List<dynamic>> getWardByZone(
    int zoneId,
    int districtId,
    int corporationId,
  ) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getWardByZone,
        data: {
          'zone_id': zoneId,
          'district_id': districtId,
          'corporation_id': corporationId,
        },
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch wards');
      }
    } catch (e) {
      throw Exception('Error in getWardByZone: $e');
    }
  }

  Future<List<dynamic>> getMunicipalityByDistrict(int districtId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getMunicipalityByDistrict,
        data: {'district_id': districtId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch municipalities',
        );
      }
    } catch (e) {
      throw Exception('Error in getMunicipalityByDistrict: $e');
    }
  }

  Future<List<dynamic>> getWardByMunicipality(int municipalityId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getWardByMunicipality,
        data: {'municipality_id': municipalityId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch municipality wards',
        );
      }
    } catch (e) {
      throw Exception('Error in getWardByMunicipality: $e');
    }
  }

  Future<List<dynamic>> getTownPanchayatByDistrict(int districtId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getTownPanchayatByDistrict,
        data: {'district_id': districtId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch town panchayats',
        );
      }
    } catch (e) {
      throw Exception('Error in getTownPanchayatByDistrict: $e');
    }
  }

  Future<List<dynamic>> getWardByTownPanchayat(int townPanchayatId) async {
    try {
      final response = await _apiClient.post(
        AppConfig.getWardByTownPanchayat,
        data: {'town_panchayat_id': townPanchayatId},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch town panchayat wards',
        );
      }
    } catch (e) {
      throw Exception('Error in getWardByTownPanchayat: $e');
    }
  }

  Future<Map<String, dynamic>> createGrievance(
    Map<String, dynamic> grievanceData,
  ) async {
    try {
      final userData = await SimpleUsage.getCurrentUser();
      if (userData == null) {
        throw Exception('User not logged in');
      }

      final userId = userData['userid'];
      if (userId == null) {
        throw Exception('User ID not found in stored data');
      }

      grievanceData['public_id'] = userId;

      final response = await _apiClient.post(
        AppConfig.createGrievanceRequest,
        data: grievanceData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'message':
              response.data['message'] ?? 'Grievance created successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create grievance',
        };
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  Future<Map<String, dynamic>> reopenGrievance(
    int grievanceId,
    String comments,
  ) async {
    try {
      final userData = await SimpleUsage.getCurrentUser();
      if (userData == null) {
        throw Exception('User not logged in');
      }

      final userId = userData['userid'];
      if (userId == null) {
        throw Exception('User ID not found in stored data');
      }

      final requestBody = {
        'grievance_id': grievanceId,
        'comments': comments,
      };

      final response = await _apiClient.post(
        AppConfig.reopenGrievanceEndpoint,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'message':
              response.data['message'] ?? 'Grievance reopened successfully',
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to reopen grievance',
          'data': null,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> getGrievanceDetails(int grievanceId) async {
    try {
      final requestBody = {"grievance_id": grievanceId};
      final response = await _apiClient.post(
        AppConfig.viewGrievanceDetails,
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
          'message':
              response.data['message'] ?? 'Failed to fetch grievance details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getCorporationByDistrict(int districtId) async {
    try {
      final requestBody = {"district_id": districtId};
      final response = await _apiClient.post(
        AppConfig.getCorporationByDistrict,
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
          'message':
              response.data['message'] ?? 'Failed to fetch corporation details',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
