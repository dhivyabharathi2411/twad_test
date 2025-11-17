import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/error/exceptions.dart';
import '../utils/simple_encryption.dart';
import 'api_config.dart';

abstract class IApiClient {
  Future<Response> get(String endpoint, {Map<String, dynamic>? params});
  Future<Response> post(String endpoint, {dynamic data, Options? options});
  Future<Response> put(String endpoint, {dynamic data, Options? options});
  Future<Response> delete(String endpoint, {Map<String, dynamic>? params});
  Future<Response> patch(String endpoint, {dynamic data, Options? options});
  void updateToken(String? token);
  void setDefaultAccessToken(String token);
}

class ApiClient implements IApiClient {
  final Dio _dio;
  String? _currentToken;
  String _defaultAccessToken = 'your_access_token_here';
  Map<String, dynamic>? _cachedUserData;
  DateTime? _userDataCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  static bool? _encryptEnabledCache;

  static Function()? _onInvalidTokenCallback;

  ApiClient({Dio? dio, String? initialToken})
    : _dio = dio ?? _createDio(),
      _currentToken = initialToken {
    _setupInterceptors();
  }
  Dio get dio => _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30), 
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        validateStatus: (status) => status != null && status < 500,
        persistentConnection: true, 
      ),
    );
  }
  void _setupInterceptors() {
    _encryptEnabledCache ??=
        dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase() == 'true';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storedToken = await SimpleEncryption.instance.getToken();
          if (storedToken != null && storedToken != _currentToken) {
            _currentToken = storedToken;
            _cachedUserData = null;
            _userDataCacheTime = null;
          }
          _setBasicHeaders(options);
          final isRegistrationEndpoint = _isRegistrationEndpoint(options.path);
          final isUploadFileEndpoint = options.path.contains(
            '/common/uploadfile',
          );

          if (!isRegistrationEndpoint) {
            await _setUserHeaders(options);
          }
          options.headers['encrypt'] = _encryptEnabledCache! ? 'true' : 'false';

          if (_encryptEnabledCache! &&
              options.data != null &&
              options.data is! FormData &&
              !isUploadFileEndpoint) {
            await _handleRequestEncryption(options);
          }
          if (!isRegistrationEndpoint) {
            options.headers['Authorization'] =
                _currentToken != null && _currentToken!.isNotEmpty
                ? 'bearer $_currentToken'
                : 'bearer $_defaultAccessToken';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          try {

            if (response.statusCode == 204) {
              _currentToken = null;
              _cachedUserData = null;
              _userDataCacheTime = null;
              
              await SimpleEncryption.instance.clearToken();
              _handleInvalidTokenNavigation();
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  error: 'Invalid token Authentication',
                  type: DioExceptionType.badResponse,
                  response: response,
                ),
              );
            }
            
            if (response.statusCode == 401) {
              _currentToken = null;
              _cachedUserData = null;
              _userDataCacheTime = null;
              
              await SimpleEncryption.instance.clearToken();
            
              _handleInvalidTokenNavigation();
            
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  error: 'Unauthorized',
                  type: DioExceptionType.badResponse,
                  response: response,
                ),
              );
            }
            if (response.data != null && 
                response.data is Map<String, dynamic> &&
                (response.data['message'] == 'Invalid token Authentication' ||
                 response.data['message'] == 'Authentication required' ||
                 response.data['code'] == 'UNAUTHORIZED')) {
              _currentToken = null;
              _cachedUserData = null;
              _userDataCacheTime = null;
              
              await SimpleEncryption.instance.clearToken();
            
              _handleInvalidTokenNavigation();
            
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  error: 'Invalid token Authentication',
                  type: DioExceptionType.badResponse,
                  response: response,
                ),
              );
            }
            
            if (_encryptEnabledCache! &&
                response.data != null &&
                response.data is Map<String, dynamic> &&
                response.data['data'] is String) {
              final responseData = response.data as Map<String, dynamic>;
              final encryptedData = responseData['data'] as String;

              final decrypted = await SimpleEncryption.instance.decryptCryptoJS(
                encryptedData,
                'unused_iv_parameter',
              );

              if (decrypted != null) {
                try {
                  responseData['data'] = jsonDecode(decrypted);
                } catch (e) {
                  responseData['data'] = decrypted;
                }
              }
            }
          } catch (e) {
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 204 || 
              error.response?.statusCode == 401 ||
              (error.response?.data != null && 
               error.response?.data is Map<String, dynamic> &&
               (error.response?.data['message'] == 'Invalid token Authentication' ||
                error.response?.data['message'] == 'Authentication required' ||
                error.response?.data['code'] == 'UNAUTHORIZED'))) {
          
            _currentToken = null;
            _cachedUserData = null;
            _userDataCacheTime = null;

            SimpleEncryption.instance.clearToken();
            _handleInvalidTokenNavigation();
          }

          final exception = _handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout(error);

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return NetworkException.noConnection(error);
        }
        return NetworkException.connectionFailed(error);

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return const NetworkException(
          'Request was cancelled',
          'REQUEST_CANCELLED',
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException.noConnection(error);
        }
        return NetworkException.connectionFailed(error);

      default:
        return NetworkException.connectionFailed(error);
    }
  }
  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    String errorMessage = 'An error occurred';
    if (responseData is Map<String, dynamic>) {
      errorMessage =
          responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          errorMessage;
    }

    if (statusCode == null) {
      return NetworkException.connectionFailed(error);
    }

    switch (statusCode) {
      case 400:
        return ClientException.badRequest(error);
      case 401:
        return ClientException.unauthorized(error);
      case 403:
        return ClientException.forbidden(error);
      case 404:
        return ClientException.notFound(error);
      case 422:
        return ValidationException(errorMessage, 'VALIDATION_ERROR', error);
      case 429:
        return const ClientException(
          'Too many requests',
          'RATE_LIMIT_EXCEEDED',
        );
      default:
        if (statusCode >= 500) {
          return ServerException.internalServerError(error);
        }
        return ClientException(errorMessage, 'HTTP_ERROR_$statusCode', error);
    }
  }

  @override
  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(endpoint, queryParameters: params);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      if (options != null) {
      }
      return await _dio.post(endpoint, data: data, options: options);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put(endpoint, data: data, options: options);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _dio.delete(endpoint, queryParameters: params);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch(endpoint, data: data, options: options);
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw _handleDioError(e);
    }
  }

  @override
  void updateToken(String? token) {
    _currentToken = token;
  }

  @override
  void setDefaultAccessToken(String token) {
    _defaultAccessToken = token;
  }
  void _setBasicHeaders(RequestOptions options) {
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    } else {
      options.headers.remove('Content-Type');
    }

    if (!options.path.contains('uploadfile')) {
      options.headers['Accept'] = 'application/json';
    }
  }
  bool _isRegistrationEndpoint(String path) {
    return path.contains('new_registration') ||
        path.contains('request_otp') ||
        path.contains('registration');
  }

  Future<void> _setUserHeaders(RequestOptions options) async {
    options.headers['device_type'] = 'mobile';
    options.headers['device_id'] = '0';
    options.headers['device_token'] = '0';

    if (_currentToken != null && _currentToken!.isNotEmpty) {
      Map<String, dynamic>? userData;

      if (_cachedUserData != null &&
          _userDataCacheTime != null &&
          DateTime.now().difference(_userDataCacheTime!) <
              _cacheValidDuration) {
        userData = _cachedUserData;
      } else {
        userData = await SimpleEncryption.instance.getUserData();
        if (userData != null) {
          _cachedUserData = userData;
          _userDataCacheTime = DateTime.now();
        }
      }

      if (userData != null) {
        options.headers['user_id'] =
            userData['userid']?.toString() ?? userData['id']?.toString() ?? '';
        final userType = userData['user_type']?.toString();
        options.headers['user_type'] = userType?.isEmpty == true
            ? 'public'
            : (userType ?? 'public');
        options.headers['role_id'] = userData['role_id']?.toString() ?? '';
      } else {
        _setEmptyUserHeaders(options);
      }
    } else {
      _setEmptyUserHeaders(options);
    }
  }

  void _setEmptyUserHeaders(RequestOptions options) {
    options.headers['user_id'] = '';
    options.headers['user_type'] = '';
    options.headers['role_id'] = '';
  }

  Future<void> _handleRequestEncryption(RequestOptions options) async {
    try {
      if (options.path.contains('/login') &&
          options.data is Map<String, dynamic>) {
        final data = options.data as Map<String, dynamic>;
        options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
        options.data = data.entries
            .map(
              (entry) =>
                  '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
            )
            .join('&');
        return;
      }

      String jsonData;
      if (options.data is Map || options.data is List) {
        jsonData = jsonEncode(options.data);
      } else if (options.data is String) {
        jsonData = options.data;
      } else {
        jsonData = options.data.toString();
      }

      final encryptResult = await SimpleEncryption.instance.encryptCryptoJS(
        jsonData,
      );
      if (encryptResult['success'] == 'true') {
        options.data = {"requested_data": encryptResult['data']};
      } else {
      }
      
    } catch (e) {
    }
  }
  void clearCache() {
    _currentToken = null;
    _cachedUserData = null;
    _userDataCacheTime = null;
  }

  void _handleInvalidTokenNavigation() {
    if (_onInvalidTokenCallback != null) {
      try {
        _onInvalidTokenCallback!();
      } catch (e) {
      }
    } else {
    }
  }
  static void setInvalidTokenCallback(Function() callback) {
    _onInvalidTokenCallback = callback;
  }

  static void clearInvalidTokenCallback() {
    _onInvalidTokenCallback = null;
  }

  static bool get hasInvalidTokenCallback => _onInvalidTokenCallback != null;
}
