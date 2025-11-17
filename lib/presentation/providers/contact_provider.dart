import 'package:flutter/foundation.dart';

import '../../services/user_profile_service.dart';

class ContactProfileProvider extends ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();

  bool _isLoading = false;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profileData => _profileData;
  String? get errorMessage => _errorMessage;

  // Fetch profile data
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _profileService.getUserProfile();

    if (result['success'] == true) {
      _profileData = result['data'];
    } else {
      _errorMessage = result['message'] ?? 'Something went wrong';
    }

    _isLoading = false;
    notifyListeners();
  }
}