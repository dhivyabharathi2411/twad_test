import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Master-level app constants with comprehensive configuration
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ================================
  // APP INFORMATION
  // ================================
  static const String appName = 'TWAD - Tamil Nadu Water Supply and Drainage Board';
  static const String appNameShort = 'TWAD';
  static const String appNameTamil = 'தமிழ்நாடு குடிநீர் மற்றும் வடிகால் வாரியம்';
  static const String appNameEnglish = 'Tamil Nadu Water Supply and Drainage Board';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ================================
  // DESIGN TOKENS - COLORS
  // ================================
  
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF9C27B0); // Purple
  static const Color secondaryDark = Color(0xFF7B1FA2);
  static const Color secondaryLight = Color(0xFFBA68C8);
  
  // Accent Colors
  static const Color accentColor = Color(0xFF4CAF50); // Green
  static const Color accentDark = Color(0xFF388E3C);
  static const Color accentLight = Color(0xFF81C784);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFF9E9E9E);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF);
  static const Color textOnSecondaryColor = Color(0xFFFFFFFF);
  static const Color submitbuttoncolor = Color.fromRGBO(108, 99, 255, 1);
  static const Color grievanceViolet = Color(0xFF8A63D2);
  static const Color grievanceGreen = Color(0xFF34C759);
  static const Color grievanceRed = Color(0xFFFF3B30);
  static const Color grievanceLightViolet = Color.fromRGBO(138, 99, 210, 0.10);
  static const Color grievanceLightGreen = Color.fromRGBO(52, 199, 89, 0.10);
  static const Color grievanceLightRed = Color.fromRGBO(255, 59, 48, 0.10);
  static const Color grievanceText = Color(0xFF2C3E50);
  static const Color editBg= Color(0xFFFFC107);
  static const Color acknowledgementButtonBg = Color(0xFF22C55E);
  static const Color detailIconBg = Color(0xFFDCFCE7);
  static const Color detailIconGreen = Color(0xFF16A34A);
  static const Color acknowledgementIconBg = Color(0xFFFEE2E2);
  static const Color acknowledgementIconRed = Color(0xFFDC2626);
  // ================================
  // DESIGN TOKENS - DIMENSIONS
  // ================================
  
  // Spacing Scale (8pt grid system)
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 20.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  static const double space3XL = 64.0;
  
  // Legacy spacing (maintain backward compatibility)
  static const double defaultPadding = spaceLG;
  static const double cardPadding = spaceXL;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  
  // Legacy radius (maintain backward compatibility)
  static const double borderRadius = radiusMD;
  static const double cardBorderRadius = radiusXL;
  
  // Component Sizes
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 56.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double logoSize = 120.0;
  static const double innerLogoSize = 100.0;
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  
  // Layout Constraints
  static const double maxCardWidth = 400.0;
  static const double maxContentWidth = 1200.0;
  static const double minTouchTarget = 44.0;
  
  // Legacy dimensions (maintain backward compatibility)
  static const double buttonHeight = spaceMD;

  // ================================
  // DESIGN TOKENS - TYPOGRAPHY
  // ================================
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 28.0;
  static const double fontSize5XL = 32.0;
  
  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  
  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // ================================
  // TEXT STYLES
  // ================================
  
  // Headings
  static TextStyle get headingXL => GoogleFonts.poppins(
    fontSize: fontSize5XL,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    height: lineHeightTight,
  );
  
  static TextStyle get headingLG => GoogleFonts.poppins(
    fontSize: fontSize3XL,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    height: lineHeightTight,
  );
  
  static TextStyle get headingMD => GoogleFonts.poppins(
    fontSize: fontSize2XL,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    height: lineHeightNormal,
  );
  
  static TextStyle get headingSM => GoogleFonts.poppins(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    height: lineHeightNormal,
  );
  
  // Body Text
  static TextStyle get bodyLG => GoogleFonts.poppins(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: lineHeightRelaxed,
  );
  
  static TextStyle get bodyMD => GoogleFonts.poppins(
    fontSize: fontSizeMD,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: lineHeightRelaxed,
  );
  
  static TextStyle get bodySM => GoogleFonts.poppins(
    fontSize: fontSizeSM,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: lineHeightNormal,
  );
  
  // Specialized Text Styles
  static TextStyle get buttonTextLG => GoogleFonts.poppins(
    fontSize: fontSizeLG,
    fontWeight: FontWeight.w600,
    color: textOnPrimaryColor,
    height: lineHeightNormal,
  );
  
  static TextStyle get buttonTextMD => GoogleFonts.poppins(
    fontSize: fontSizeMD,
    fontWeight: FontWeight.w600,
    color: textOnPrimaryColor,
    height: lineHeightNormal,
  );
  
  static TextStyle get linkText => GoogleFonts.poppins(
    fontSize: fontSizeMD,
    fontWeight: FontWeight.w500,
    color: primaryColor,
    height: lineHeightNormal,
    decoration: TextDecoration.underline,
  );
  
  static TextStyle get captionText => GoogleFonts.poppins(
    fontSize: fontSizeSM,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: lineHeightNormal,
  );
  
  static TextStyle get overlineText => GoogleFonts.poppins(
    fontSize: fontSizeXS,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  // ================================
  // LEGACY TEXT STYLES (for backward compatibility)
  // ================================
  static TextStyle get titleStyle => headingMD;
  static TextStyle get subtitleStyle => GoogleFonts.poppins(
    fontSize: fontSizeLG,
    color: accentColor,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get buttonTextStyle => buttonTextMD;
  static TextStyle get bodyTextStyle => bodyMD.copyWith(color: textSecondaryColor);
  static TextStyle get linkTextStyle => linkText.copyWith(decoration: null);

  // ================================
  // COMPONENT STYLES
  // ================================
  
  // Input Decoration
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMD),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spaceMD,
      vertical: spaceMD,
    ),
    hintStyle: bodyMD.copyWith(color: textHintColor),
  );
  
  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textOnPrimaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceXL,
      vertical: spaceMD,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMD),
    ),
    textStyle: buttonTextMD,
    minimumSize: const Size(0, buttonHeightMD),
  );
  
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceXL,
      vertical: spaceMD,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMD),
    ),
    textStyle: buttonTextMD.copyWith(color: primaryColor),
    minimumSize: const Size(0, buttonHeightMD),
  );
  
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLG,
      vertical: spaceSM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSM),
    ),
    textStyle: bodyMD.copyWith(
      fontWeight: FontWeight.w500,
      color: primaryColor,
    ),
    shadowColor: Colors.transparent,
  );

  // ================================
  // ANIMATION DURATIONS
  // ================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ================================
  // SHADOWS
  // ================================
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // ================================
  // VALIDATION PATTERNS
  // ================================
  static const String phoneNumberPattern = r'^[6-9]\d{9}$';
  static const String otpPattern = r'^\d{6}$';
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // ================================
  // API CONFIGURATION
  // ================================
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // ================================
  // CACHE CONFIGURATION
  // ================================
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB

  // ================================
  // HELPER METHODS
  // ================================
  
  /// Check if phone number is valid
  static bool isValidPhoneNumber(String phone) {
    return RegExp(phoneNumberPattern).hasMatch(phone);
  }
  
  /// Check if OTP is valid
  static bool isValidOTP(String otp) {
    return RegExp(otpPattern).hasMatch(otp);
  }
  
  /// Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }
  
  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }
  
  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(double screenWidth) {
    if (screenWidth > 600) {
      return const EdgeInsets.all(spaceXXL);
    } else if (screenWidth > 400) {
      return const EdgeInsets.all(spaceXL);
    }
    return const EdgeInsets.all(spaceLG);
  }
}
