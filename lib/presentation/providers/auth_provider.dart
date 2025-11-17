import 'package:flutter/foundation.dart';
import 'package:twad/services/auth_api_service.dart';
import '../../api/api_client.dart';
import '../../api/api_config.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_login_status.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_with_otp.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/send_otp.dart';
import '../../utils/simple_encryption.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _otpFieldEnabled = false;
  bool get otpFieldEnabled => _otpFieldEnabled;
  void setOtpFieldEnabled(bool value) {
    _otpFieldEnabled = value;
    notifyListeners();
  }

  final LoginWithOtp loginUseCase;
  final SendOtp sendOtpUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final Logout logoutUseCase;
  final CheckLoginStatus checkLoginStatusUseCase;
  final RegisterUser registerUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.sendOtpUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.checkLoginStatusUseCase,
    required this.registerUseCase,
  });

  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _user;
  AuthToken? _authToken;
  String? _error;
  bool _isOtpSent = false;
  bool _isOtpLoading = false;
  String? _otpError;
  bool _isLoginLoading = false;
  String? _loginError;
  bool _isRegistering = false;
  String? _registrationError;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  AuthToken? get authToken => _authToken;
  String? get error => _error;

  bool get isOtpSent => _isOtpSent;
  bool get isOtpLoading => _isOtpLoading;
  String? get otpError => _otpError;

  bool get isLoginLoading => _isLoginLoading;
  String? get loginError => _loginError;

  bool get isRegistering => _isRegistering;
  String? get registrationError => _registrationError;
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final result = await checkLoginStatusUseCase();
      result.fold(
        (failure) {
          _setError(failure.message);
          _setAuthenticated(false);
        },
        (isLoggedIn) {
          _setAuthenticated(isLoggedIn);
          if (isLoggedIn) {
            _loadCurrentUser();
          }
        },
      );
    } catch (e) {
      _setError('Failed to initialize auth state: ${e.toString()}');
      _setAuthenticated(false);
    } finally {
      _setLoading(false);
    }
  }
  String? _otp;
  String? get otp => _otp;

  final AuthApiService _apiService = AuthApiService();

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    setOtpFieldEnabled(true);
    try {
      final requestBody = {"contact_no": phoneNumber};

      final response = await _apiService.post(
        AppConfig.loginEndpoint,
        data: requestBody,
      );
      Map<String, dynamic> apiData;
      if (response['data'] != null && response['data'] is Map) {
        apiData = response['data'] as Map<String, dynamic>;
      } else {
        apiData = response;
      }

      final statusCode = apiData['statuscode'] is int
          ? apiData['statuscode'] as int
          : int.tryParse(apiData['statuscode'].toString()) ?? 0;

      final statusRaw = apiData['status'];
      final status =
          (statusRaw is bool && statusRaw == true) ||
          (statusRaw is String && statusRaw.toLowerCase() == 'true');

      final isSuccess = statusCode == 200 && status;

      if (isSuccess) {
        _otp = apiData['data'].toString(); 
        _otpError = null; 
        return {
          'success': true,
          'message': apiData['message'] ?? 'OTP sent successfully',
          'data': apiData['data'], 
        };
      } else {
        _otp = null;
        String errorMessage = apiData['message'] ?? 'Failed to send OTP';
        if (apiData['data'] != null && apiData['data'] is String) {
          errorMessage = apiData['data'].toString();
        }

        _otpError = errorMessage;
        return {'success': false, 'message': errorMessage, 'data': apiData};
      }
    } catch (e) {
      _otp = null;
      final errorMessage = 'Failed to send OTP: $e';
      _otpError = errorMessage;
      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendOtpRegistration(String phoneNumber) async {
    setOtpFieldEnabled(true);
    try {
      final requestBody = {"contact_no": phoneNumber};

      final response = await _apiService.post(
        AppConfig.registerEndpoint,
        data: requestBody,
      );
      Map<String, dynamic> apiData;
      if (response['data'] != null && response['data'] is Map) {
        apiData = response['data'] as Map<String, dynamic>;
      } else {
        apiData = response;
      }
      final statusCode = apiData['statuscode'] is int
          ? apiData['statuscode'] as int
          : int.tryParse(apiData['statuscode'].toString()) ?? 0;

      final statusRaw = apiData['status'];
      final status =
          (statusRaw is bool && statusRaw == true) ||
          (statusRaw is String && statusRaw.toLowerCase() == 'true');

      final isSuccess = statusCode == 200 && status;

      if (isSuccess) {
        _otp = apiData['data'].toString();
        _otpError = null; 
        return {
          'success': true,
          'message': apiData['message'] ?? 'OTP sent successfully',
          'data': apiData['data'], 
        };
      } else {
        _otp = null;
        String errorMessage = apiData['message'] ?? 'Failed to send OTP';
        if (apiData['data'] != null && apiData['data'] is String) {
          errorMessage = apiData['data'].toString();
        }

        _otpError = errorMessage; 
        return {'success': false, 'message': errorMessage, 'data': apiData};
      }
    } catch (e) {
      _otp = null;
      final errorMessage = 'Failed to send OTP: $e';
      _otpError = errorMessage; 
      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }
  Future<Map<String, dynamic>> loginWithOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    _setLoginLoading(true);
    _clearLoginError();

    try {
      final response = await _apiService.login(username: phoneNumber, otp: otp);

      if (response['success'] == true) {
        _setAuthenticated(true);
        _setOtpSent(false); 
        _setLoginError(null); 
         final responseData = response['data'];
      final accessToken = responseData?['access_token'];

      if (accessToken != null) {
        await SimpleUsage.login(
          authToken: accessToken,
          userData: responseData,
        );
        _apiClient.clearCache();
        _apiClient.updateToken(accessToken);
      }

        _checkAndUpdateProfileStatus(responseData);
        _loadCurrentUser();

        return {
          'success': true,
          'message': response['message'] ?? 'Login successful',
          'data': response['data'],
        };
      } else {
        String errorMessage = response['message'] ?? 'Login failed';

        if (response['data'] != null) {
          if (response['data'] is Map) {
            final data = response['data'] as Map<String, dynamic>;
            if (data['error_description'] != null &&
                data['error_description'].toString().isNotEmpty) {
              errorMessage = data['error_description'].toString();
            } else if (data['message'] != null &&
                data['message'].toString().isNotEmpty) {
              errorMessage = data['message'].toString();
            } else if (data['error'] != null &&
                data['error'].toString().isNotEmpty) {
              errorMessage = data['error'].toString();
            }
          } else if (response['data'] is String &&
              response['data'].toString().isNotEmpty) {
            errorMessage = response['data'].toString();
          }
        }

        _setLoginError(errorMessage);

        return {
          'success': false,
          'message': errorMessage,
          'data': response['data'],
        };
      }
    } catch (e) {
      final errorMessage = 'Login failed: ${e.toString()}';

      _setLoginError(errorMessage);
      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    } finally {
      _setLoginLoading(false);
    }
  }
  Future<bool> register({
    required String name,
    required String contactNo,
    required String email,
    required String otp,
  }) async {
    _setRegistering(true);
    _clearRegistrationError();

    try {
      final result = await registerUseCase(
        RegisterUserParams(
          name: name,
          contactNo: contactNo,
          email: email,
          otp: otp,
        ),
      );

      return result.fold(
        (failure) {
          _setRegistrationError(failure.message);
          return false;
        },
        (success) {
          return true;
        },
      );
    } catch (e) {
      _setRegistrationError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setRegistering(false);
    }
  }
  Future<void> _loadCurrentUser() async {
    try {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) {
        },
        (user) {
          _setUser(user);
        },
      );
    } catch (e) {
 //
    }
  }

  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      final result = await logoutUseCase();
      result.fold(
        (failure) {
        },
        (_) {
        },
      );
    } catch (e) {
      //
    } finally {
      _clearAuthState();
      _setLoading(false);
    }
  }

  void _clearAuthState() {
    _user = null;
    _authToken = null;
    _isAuthenticated = false;
    _isOtpSent = false;
    _clearErrors();
    notifyListeners();
  }
  void clearErrors() {
    _clearErrors();
    notifyListeners();
  }

  void _clearErrors() {
    _error = null;
    _otpError = null;
    _loginError = null;
    _registrationError = null;
  }

  void _clearLoginError() {
    _loginError = null;
    notifyListeners();
  }

  void _clearRegistrationError() {
    _registrationError = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  void _setLoginLoading(bool loading) {
    _isLoginLoading = loading;
    notifyListeners();
  }

  void _setRegistering(bool registering) {
    _isRegistering = registering;
    notifyListeners();
  }

  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }


  void _setLoginError(String? error) {
    _loginError = error;
    notifyListeners();
  }

  void _setRegistrationError(String? error) {
    _registrationError = error;
    notifyListeners();
  }

  void _setOtpSent(bool sent) {
    _isOtpSent = sent;
    notifyListeners();
  }
  void resetOtpState() {
    _isOtpSent = false;
    _otpError = null;
    notifyListeners();
  }
  bool isValidPhoneNumber(String phoneNumber) {

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length == 10 && RegExp(r'^[6-9]').hasMatch(cleanPhone)) {
      return true;
    }

    if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      final phoneWithoutCode = cleanPhone.substring(2);
      return RegExp(r'^[6-9]').hasMatch(phoneWithoutCode);
    }

    return false;
  }
  String formatPhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length == 10) {
      return '+91 ${cleanPhone.substring(0, 5)} ${cleanPhone.substring(5)}';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      final phone = cleanPhone.substring(2);
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }

    return phoneNumber;
  }
  String getCleanPhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return cleanPhone.substring(2);
    }

    return cleanPhone;
  }

  void _checkAndUpdateProfileStatus(Map<String, dynamic>? responseData) {
    try {
      if (responseData != null && responseData is Map<String, dynamic>) {
        final districtId = responseData['district_id'];
        if (districtId != null && districtId.toString() != '0' && districtId.toString().isNotEmpty) {
        } else {

        }
      }
    } catch (e) {
      //
    }
  }
}
