import 'package:flutter/material.dart';

class OrganizationProvider extends ChangeNotifier {
  String? _selectedOrganization;
  String? _selectedDistrictName;
  String? _safeOrganization;

  // Call this when district changes
  void setSelectedDistrictName(String? districtName) {
    _selectedDistrictName = districtName;
    notifyListeners();
  }

  List<String> get organizationItems {
    final allowedCorporationDistricts = [
      'CHENGALPATTU',
      'CUDDALORE',
      'DINDIGUL',
      'ERODE',
      'KANCHEEPURAM',
      'KANNIYAKUMARI',
      'MADURAI',
      'COIMBATORE',
      'KARUR',
      'KRISHNAGIRI',
      'MADURAI',
      'NAMAKKAL',
      'PUDUKKOTTAI',
      'SALEM',
      'SIVAGANGAI',
      'THANJAVUR',
      'THOOTHUKUDI',
      'TIRUCHIRAPPALLI',
      'TIRUNELVELI',
      'TIRUPPUR',
      'TIRUVALLUR',
      'TIRUVANNAMALAI',
      'VELLORE',
      'VILLUPURAM',
      'CHENNAI',
    ];
    final orgs = <String>[];
    if (_selectedDistrictName != null &&
        allowedCorporationDistricts.contains(
          _selectedDistrictName!.toUpperCase(),
        )) {
      orgs.add('CORPORATION');
    }
    orgs.addAll(['MUNICIPALITY', 'PANCHAYAT', 'TOWN PANCHAYAT']);
    return orgs;
  }

  String? get selectedOrganization => _selectedOrganization;

  void selectOrganization(String? value) {
    _selectedOrganization = value;
    notifyListeners();
  }

  String? get safeOrganization => _safeOrganization;

  void safeselectOrganization(String? value) {
    _safeOrganization = value;
    notifyListeners();
  }
}
