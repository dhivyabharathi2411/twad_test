import 'dart:convert'; // for jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twad/data/models/user_model.dart';

import '../../data/models/block_list_model.dart';
import '../../data/models/district_list_model.dart';
import '../../data/models/habitation_list.dart';
import '../../data/models/village_list_model.dart';
import '../../services/grievance_service.dart';

class ProfileProvider extends ChangeNotifier {
  /// Call this after registration or first login to ensure profileupdated is false for new users
  Future<void> resetProfileUpdatedFlag() async {
    _profileupdated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(profileUpdatedKey, false);
    notifyListeners();
  }

  bool _profileLoaded = false;
  bool get profileLoaded => _profileLoaded;

  bool _profilefetched = false;
  bool get profilefetched => _profilefetched;
  bool _profileupdated = false;
  // Persist profile updated status in SharedPreferences
  static String profileUpdatedKey = 'profileUpdated';

  /// Loads user profile from API only if not already loaded. Returns cached user otherwise.
  Future<UserModel> loadUserProfileIfNeeded(
    Future<UserModel> Function() apiCall,
  ) async {
    if (_profileLoaded) {
      return _currentUser;
    }
    final user = await apiCall();
    setUserFromApi(user);
    return user;
  }

  /// Set user from API and mark profile as loaded (call this after login)
  void setUserFromApi(UserModel user) {
    _currentUser = user;
    _profileLoaded = true;
    _saveUserToStorage(user);
    notifyListeners();
  }

  /// Call this to force a refresh (e.g. after logout or profile update)
  // void resetProfileLoaded() {
  //   _profileLoaded = false;
  //   notifyListeners();
  // }

  /// Clear all user and dropdown data from memory and SharedPreferences
  Future<void> clearUserData() async {
    // Reset profile loaded flag so next login fetches fresh profile
    _profileLoaded = false;
    // _profileupdated = false;

    // Reset provider fields
    _currentUser = const UserModel(
      id: '21',
      name: 'King',
      contactno: '8148471303',
      emailid: 'boo7@gmail.com',
      districtName: 'Coimbatore',
      organisationName: 'TWAD Board',
      isActive: true,
    );
    _isEditing = false;
    _isLoggingOut = false;
    // Do NOT reset _profileupdated here, so it persists after logout/login
    _selectedDistrict = '';
    _selectedOrganization = '';
    _selectedZone = '';
    _selectedZoneward = '';
    _selectedCorporation = '';
    _selectedMunicipality = '';
    _selectedMunicipalityward = '';
    _selectedTownpanchayat = '';
    _selectedTownpanchayatward = '';
    _selectedTwaddivison = '';
    _selectedBlock = '';
    _selectedVillage = '';
    _selectedHabitation = '';

    // // Clear SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('currentUser');
    // await prefs.remove('selectedDistrict');
    // await prefs.remove('selectedOrganization');
    // await prefs.remove('selectedBlock');
    // await prefs.remove('selectedVillage');
    // await prefs.remove('selectedHabitation');
    // await prefs.remove('selectedZone');
    // await prefs.remove('selectedZoneward');
    // await prefs.remove('selectedMunicipality');
    // await prefs.remove('selectedMunicipalityward');
    // await prefs.remove('selectedTownpanchayat');
    // await prefs.remove('selectedTownpanchayatward');
    // Do NOT remove profileUpdatedKey so it persists
    notifyListeners();
  }

  ProfileProvider() {
    _init();
  }

  UserModel _currentUser = const UserModel(
    id: '21',
    name: 'King',
    contactno: '8148471303',
    emailid: 'boo7@gmail.com',
    districtName: 'Coimbatore',
    organisationName: 'TWAD Board',
    isActive: true,
  );

  bool _isEditing = false;
  bool _isLoggingOut = false;

  // _profileupdated is now persisted

  String _selectedDistrict = '';
  String _selectedOrganization = '';

  String _selectedZone = '';
  String _selectedZoneward = '';
  String _selectedMunicipality = '';
  String _selectedMunicipalityward = '';
  String _selectedCorporation = '';
  String _selectedTownpanchayat = '';
  String _selectedTownpanchayatward = '';
  String _selectedTwaddivison = '';
  String _selectedBlock = '';
  String _selectedVillage = '';
  String _selectedHabitation = '';

  UserModel get currentUser => _currentUser;
  bool get isEditing => _isEditing;
  bool get isLoggingOut => _isLoggingOut;
  bool get isprofileUpated => _profileupdated;
  // Corrected getter to return _profileupdated
  bool get isprofilefetched => _profilefetched;
  String get selectedDistrict => _selectedDistrict;
  String get selectedOrganization => _selectedOrganization;
  String get selectedCorporation => _selectedCorporation;
  String get selectedZone => _selectedZone;
  String get selectedZoneward => _selectedZoneward;
  String get selectedMunicipality => _selectedMunicipality;
  String get selectedMunicipalityward => _selectedMunicipalityward;
  String get selectedTownpanchayat => _selectedTownpanchayat;
  String get selectedTownpanchayatward => _selectedTownpanchayatward;
  String get selectedTwaddivison => _selectedTwaddivison;
  String get selectedBlock => _selectedBlock;
  String get selectedVillage => _selectedVillage;
  String get selectedHabitation => _selectedHabitation;

  void setEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  void setLoggingOut(bool value) {
    _isLoggingOut = value;
    notifyListeners();
  }

  void setSelectedDistrict(String value) {
    _selectedDistrict = value;
    _saveToStorage("selectedDistrict", value);
    notifyListeners();
  }

  void setSelectedOrganization(String value) {
    _selectedOrganization = value;
    _saveToStorage("selectedOrganization", value);
    notifyListeners();
  }

  void setSelectedCorporation(String value) {
    _selectedCorporation = value;
    _saveToStorage("selectedCorporation", value);
    notifyListeners();
  }

  void setSelectedZone(String value) {
    _selectedZone = value;
    _saveToStorage("selectedZone", value);
    notifyListeners();
  }

  void setSelectedZoneward(String value) {
    _selectedZoneward = value;
    _saveToStorage("selectedZoneward", value);
    notifyListeners();
  }

  void setSelectedMunicipality(String value) {
    _selectedMunicipality = value;
    _saveToStorage("selectedMunicipality", value);
    notifyListeners();
  }

  void setSelectedMunicipalityward(String value) {
    _selectedMunicipalityward = value;
    _saveToStorage("selectedMunicipalityward", value);
    notifyListeners();
  }

  void setSelectedTownpanchayat(String value) {
    _selectedTownpanchayat = value;
    _saveToStorage("selectedTownpanchayat", value);
    notifyListeners();
  }

  void setSelectedTownpanchayatward(String value) {
    _selectedTownpanchayatward = value;
    _saveToStorage("selectedTownpanchayatward", value);
    notifyListeners();
  }

  void setSelectedTwaddivison(String value) {
    _selectedTwaddivison = value;
    notifyListeners();
  }

  void setSelectedBlock(String value) {
    _selectedBlock = value;
    _saveToStorage("selectedBlock", value);
    notifyListeners();
  }

  void setSelectedVillage(String value) {
    _selectedVillage = value;
    _saveToStorage("selectedVillage", value);
    notifyListeners();
  }

  void setSelectedHabitation(String value) {
    _selectedHabitation = value;
    _saveToStorage("selectedHabitation", value);
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    await _saveUserToStorage(user);
    notifyListeners();
  }

  void cancelEdit() {
    _isEditing = false;
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void setprofilefetched() {
    _profilefetched = true;
    notifyListeners();
  }

  /// Call this for already registered users to ensure profileupdated is true
  Future<void> setProfileUpdatedTrue() async {
    _profileupdated = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(profileUpdatedKey, true);
    notifyListeners();
  }

  final GrievanceService _service = GrievanceService();

  List<DistrictModel> _districts = [];
  List<BlockModel> _blocks = [];
  List<VillageModel> _villages = [];
  List<HabitationModel> _habitations = [];

  List<DistrictModel> get districts => _districts;
  List<BlockModel> get blocks => _blocks;
  List<VillageModel> get villages => _villages;
  List<HabitationModel> get habitations => _habitations;

  Future<void> fetchDistricts() async {
    try {
      final data = await _service.getDistrictList();
      _districts = data
          .map<DistrictModel>((e) => DistrictModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (e) {
      _districts = [];
      notifyListeners();
    }
  }

  Future<void> fetchBlocks(int districtId) async {
    try {
      final data = await _service.getBlockByDistrict(districtId);
      _blocks = data.map<BlockModel>((e) => BlockModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _blocks = [];
      notifyListeners();
    }
  }

  Future<void> fetchVillages(int blockId) async {
    try {
      final data = await _service.getVillageByBlock(blockId);
      _villages = data
          .map<VillageModel>((e) => VillageModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (e) {
      _villages = [];
      notifyListeners();
    }
  }

  Future<void> fetchHabitations(int villageId) async {
    try {
      final data = await _service.getHabitationByVillage(villageId);
      _habitations = data
          .map<HabitationModel>((e) => HabitationModel.fromJson(e))
          .toList();
      notifyListeners();
    } catch (e) {
      _habitations = [];
      notifyListeners();
    }
  }

  Future<void> _saveToStorage(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveUserToStorage(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('currentUser');
    if (userString != null && userString.isNotEmpty) {
      final Map<String, dynamic> jsonMap = jsonDecode(userString);
      _currentUser = UserModel.fromJson(jsonMap);
    }
  }

  Future<void> _init() async {
    await _loadUserFromStorage();
    await _loadFromStorage();
    await _loadProfileUpdatedFromStorage();
    notifyListeners();
  }

  Future<void> _saveProfileUpdatedToStorage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(profileUpdatedKey, value);
  }

  Future<void> _loadProfileUpdatedFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _profileupdated = prefs.getBool(profileUpdatedKey) ?? false;
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedDistrict = prefs.getString("selectedDistrict") ?? '';
    _selectedOrganization = prefs.getString("selectedOrganization") ?? '';
    _selectedCorporation = prefs.getString("selectedCorporation") ?? '';
    _selectedBlock = prefs.getString("selectedBlock") ?? '';
    _selectedVillage = prefs.getString("selectedVillage") ?? '';
    _selectedHabitation = prefs.getString("selectedHabitation") ?? '';
    _selectedZone = prefs.getString("selectedZone") ?? '';
    _selectedZoneward = prefs.getString("selectedZoneward") ?? '';
    _selectedMunicipality = prefs.getString("selectedMunicipality") ?? '';
    _selectedMunicipalityward =
        prefs.getString("selectedMunicipalityward") ?? '';
    _selectedTownpanchayat = prefs.getString("selectedTownpanchayat") ?? '';
    _selectedTownpanchayatward =
        prefs.getString("selectedTownpanchayatward") ?? '';
  }

  // Method to get saved profile selections for use as defaults in new grievance
  static Future<Map<String, String>> getSavedProfileSelections() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'district': prefs.getString("selectedDistrict") ?? '',
      'organization': prefs.getString("selectedOrganization") ?? '',
      'corporation': prefs.getString("selectedCorporation") ?? '',
      'block': prefs.getString("selectedBlock") ?? '',
      'village': prefs.getString("selectedVillage") ?? '',
      'habitation': prefs.getString("selectedHabitation") ?? '',
      'zone': prefs.getString("selectedZone") ?? '',
      'zoneward': prefs.getString("selectedZoneward") ?? '',
      'municipality': prefs.getString("selectedMunicipality") ?? '',
      'municipalityward': prefs.getString("selectedMunicipalityward") ?? '',
      'townpanchayat': prefs.getString("selectedTownpanchayat") ?? '',
      'townpanchayatward': prefs.getString("selectedTownpanchayatward") ?? '',
    };
  }
}
