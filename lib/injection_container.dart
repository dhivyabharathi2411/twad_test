import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_api_service.dart';
import '../services/login_service.dart';
import 'data/datasources/local/local_storage.dart';
import 'data/datasources/remote/remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/check_login_status.dart';
import 'domain/usecases/get_current_user.dart';
import 'domain/usecases/login_with_otp.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/register_user.dart';
import 'domain/usecases/send_otp.dart';
import 'presentation/providers/auth_provider.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ??= ServiceLocator._();
  
  ServiceLocator._();

  final Map<Type, dynamic> _services = {};
  bool _isInitialized = false;

  /// Initialize all dependencies
  Future<void> init() async {
    if (_isInitialized) return;

    // Core dependencies
    await _initCore();
    
    // Data layer
    await _initDataLayer();
    
    // Domain layer
    _initDomainLayer();
    
    // Presentation layer
    _initPresentationLayer();

    _isInitialized = true;
  }

  /// Initialize core dependencies
  Future<void> _initCore() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _services[SharedPreferences] = sharedPreferences;

    // Use your configured AuthApiService 
    final authApiService = AuthApiService();
    _services[AuthApiService] = authApiService;
    
    // Master-level LoginService
    final loginService = LoginService(authApiService: authApiService);
    _services[LoginService] = loginService;
  }

  /// Initialize data layer dependencies
  Future<void> _initDataLayer() async {
    // Local storage
    _services[LocalStorage] = LocalStorageImpl(
      get<SharedPreferences>(),
    );

    // Remote data source
    _services[RemoteDataSource] = RemoteDataSourceImpl(
      apiService: get<AuthApiService>(),
    );

    // Repository
    _services[AuthRepository] = AuthRepositoryImpl(
      remoteDataSource: get<RemoteDataSource>(),
      localStorage: get<LocalStorage>(),
    );
  }

  /// Initialize domain layer dependencies
  void _initDomainLayer() {
    final authRepository = get<AuthRepository>();

    // Use cases
    _services[LoginWithOtp] = LoginWithOtp(authRepository);
    _services[SendOtp] = SendOtp(authRepository);
    _services[GetCurrentUser] = GetCurrentUser(authRepository);
    _services[Logout] = Logout(authRepository);
    _services[CheckLoginStatus] = CheckLoginStatus(authRepository);
    _services[RegisterUser] = RegisterUser(authRepository);
  }

  /// Initialize presentation layer dependencies
  void _initPresentationLayer() {
    // Auth provider
    _services[AuthProvider] = AuthProvider(
      loginUseCase: get<LoginWithOtp>(),
      sendOtpUseCase: get<SendOtp>(),
      getCurrentUserUseCase: get<GetCurrentUser>(),
      logoutUseCase: get<Logout>(),
      checkLoginStatusUseCase: get<CheckLoginStatus>(),
      registerUseCase: get<RegisterUser>(),
    );
  }

  /// Get service by type
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    return service as T;
  }

  /// Register a service
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Check if service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Clear all services (for testing)
  void clear() {
    _services.clear();
    _isInitialized = false;
  }

  /// Reset singleton instance (for testing)
  static void reset() {
    _instance = null;
  }
}

/// Convenience function to get services
T getIt<T>() => ServiceLocator.instance.get<T>();
