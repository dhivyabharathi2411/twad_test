import 'package:equatable/equatable.dart';

/// Authentication token entity
class AuthToken extends Equatable {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final String? refreshToken;

  const AuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
    this.refreshToken,
  });

  /// Check if token is expired
  bool get isExpired {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }

  /// Check if token is about to expire (within 5 minutes)
  bool get isExpiringSoon {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    final warningTime = expiryTime.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(warningTime);
  }

  /// Get token with bearer prefix
  String get bearerToken => '$tokenType $accessToken';

  /// Get remaining time until expiry
  Duration get timeUntilExpiry {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) {
      return Duration.zero;
    }
    return expiryTime.difference(now);
  }

  @override
  List<Object?> get props => [
        accessToken,
        tokenType,
        expiresIn,
        issuedAt,
        refreshToken,
      ];

  /// Create a copy of this token with updated fields
  AuthToken copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    String? refreshToken,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  /// Create token from response data
  factory AuthToken.fromResponse({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    String? refreshToken,
  }) {
    return AuthToken(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      issuedAt: DateTime.now(),
      refreshToken: refreshToken,
    );
  }
}
