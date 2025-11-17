/// Simple API configuration for TWAD app
class AppConfig {
  // Base URL for your API
  static const String baseUrl = 'https://api.tanneer.com/api';
  // static const String baseUrl = 'https://livetwad.mobicsol.in/twad_api/api';

  // API endpoints
  static const String loginEndpoint = '/public/request_otp';
  static const String registerEndpoint = '/public/request_otp_open';
  static const String verifyOtpEndpoint = '/login';
  static const String validateOtp = '/public/validate_otp';
  static const String getGrievanceCountEntpoint = '/public/get_grievance_count';
  static const String getGrievanceListRecent =
      '/public/get_grievance_list_by_publicid_recent';
  static const String getGrievanceList =
      '/public/get_grievance_list_by_publicid';
  static const String getGrievanceType = '/master/grievance_type';
  static const String getDistrictList = '/master/district';
  static const String getBlockByDistrict = '/master/get_block_by_district';
  static const String getVillageByBlock = '/master/get_village_by_block';
  static const String getHabitationByVillage =
      '/master/get_habitation_by_village';
  static const String getComplaintTypeList = '/master/complaint_type';
  static const String getSubComplaintTypeByComplaint =
      '/master/complaint_sub_type';
  static const String createGrievanceRequest = '/grievance/create';
  static const String viewGrievanceDetails =
      '/public/view_grievance_detail_by_id_public';
  static const String reopenGrievanceEndpoint =
      '/grievance/reopen'; // New endpoint for reopening grievances
  static const String createFeedback = '/public/create_feedback';
  static const String updateFeedback = '/public/update_feedback';
  static const String getFeedbackData = '/public/get_feedback_data';
  static const String downloadAcknowledgement =
      '/grievance/download_acknowledgement';
  static const String uploadFile = '/common/uploadfile';
  static const String deleteFile = '/common/delete_file';
  static const String createAccountEndpoint = '/public/new_registration';
  static const String logoutEndpoint = '/common/logout';
  static const String profileEndpoint = '/public/get_public_details';
  static const String updateProfileEndpoint = '/public/update_public_profile';
  static const String getDistrict = '/master/district';
  static const String getBlock = '/master/get_block_by_district';
  static const String getVillage = '/master/get_village_by_block';
  static const String getHabitation = '/master/get_habitation_by_village';
  static const String getTranslationKeywords = '/common/gettranslations_open';
  static const String getZoneByDistrict = '/master/get_zone_by_district';
  static const String getWardByZone = '/master/get_ward_by_zone';
  static const String getMunicipalityByDistrict =
      '/master/get_municipality_by_district';
  static const String getWardByMunicipality =
      '/master/get_ward_by_municipality';
  static const String getTownPanchayatByDistrict =
      '/master/get_town_panchayat_by_district';
  static const String getWardByTownPanchayat =
      '/master/get_ward_by_town_panchayat';
  static const String getMaintenanceWork = '/grievance/get_maintenance_work';
  static const String getCorporationByDistrict =
      "/master/get_corporation_by_district";

  // Request timeouts (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Environment specific URLs
  static const String devBaseUrl = 'https://dev-api.your-domain.com/api/v1';
  static const String prodBaseUrl = 'https://api.your-domain.com/api/v1';

  // Get base URL based on environment
  static String get environmentBaseUrl {
    // You can change this based on your build configuration
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : devBaseUrl;
  }
}
