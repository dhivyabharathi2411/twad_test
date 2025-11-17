import '../../domain/entities/auth_token.dart';

/// AuthToken data model for API responses and local storage
class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    required super.tokenType,
    required super.expiresIn,
    required super.issuedAt,
    super.refreshToken,
  });

  /// Create AuthTokenModel from JSON (API response)
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      issuedAt: DateTime.now(), // Set current time as issued time
      refreshToken: json['refresh_token'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
    };
  }

  /// Convert to local storage JSON
  Map<String, dynamic> toLocalJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'issued_at': issuedAt.millisecondsSinceEpoch,
      'refresh_token': refreshToken,
    };
  }

  /// Create from local storage JSON
  factory AuthTokenModel.fromLocalJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(
        json['issued_at'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      refreshToken: json['refresh_token'],
    );
  }

  /// Convert to domain entity
  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      issuedAt: issuedAt,
      refreshToken: refreshToken,
    );
  }

  /// Create from domain entity
  factory AuthTokenModel.fromEntity(AuthToken token) {
    return AuthTokenModel(
      accessToken: token.accessToken,
      tokenType: token.tokenType,
      expiresIn: token.expiresIn,
      issuedAt: token.issuedAt,
      refreshToken: token.refreshToken,
    );
  }

  /// Create from API response with current timestamp
  factory AuthTokenModel.fromResponse({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    String? refreshToken,
  }) {
    return AuthTokenModel(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      issuedAt: DateTime.now(),
      refreshToken: refreshToken,
    );
  }

  /// Create a copy with updated fields
  @override
  AuthTokenModel copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    String? refreshToken,
  }) {
    return AuthTokenModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
