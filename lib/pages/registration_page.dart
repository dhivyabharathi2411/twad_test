import 'dart:async';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:twad/constants/app_constants.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/pages/profile/profile_provider.dart';
import 'package:twad/presentation/providers/auth_provider.dart';
import 'package:twad/services/auth_api_service.dart';
import 'package:twad/widgets/customtextfield.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final ValueNotifier<int> _timeRemaining = ValueNotifier<int>(
    300,
  ); // 5 minutes in seconds
  final ValueNotifier<bool> _isResendEnabled = ValueNotifier<bool>(false);
  Timer? _timer;
  int? testOtp;
  void _showOtpDialog(String phoneNumber) {
    _timeRemaining.value = 300;
    _isResendEnabled.value = false;
    _startTimer();
    String otpValue = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 24.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: screenWidth - 32, // Full width minus padding
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _clearFormFields();
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  context.tr.enterOtpVerifyMobile,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  context.tr.textOtpTesting +
                      (testOtp != null ? ' $testOtp' : ''),
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 30),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    otpValue = value;
                  },
                  autoFocus: true,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 48,
                    fieldWidth: 40,
                    activeColor: Colors.blue,
                    selectedColor: Colors.blueAccent,
                    inactiveColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final AuthApiService _registerService =
                            AuthApiService();
                        final result = await _registerService.validateOtp(
                          phoneNumber,
                          otpValue,
                        );
                        if (result['message'] == "Success") {
                          _register();
                          _clearFormFields(); // Clear form fields after successful registration
                          _goToSignIn();
                          if (mounted) {
                            Provider.of<ProfileProvider>(
                              context,
                              listen: false,
                            ).resetProfileUpdatedFlag();
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      context.tr.otpValidationFailed,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: AppConstants.backgroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(context.tr.confirm),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _clearFormFields();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: AppConstants.backgroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(context.tr.cancel),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildOTPTimer(),
              ],
            ),
          ),
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    otpController.dispose();
    _timer?.cancel();
    _timeRemaining.dispose();
    super.dispose();
  }

  void _handleSignUpWithOTP() async {
    // Validate all fields (including email)
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final phoneNumber = contactController.text.trim();

    // Validate phone number
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Form is invalid, show inline errors
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final result = await authProvider.sendOtpRegistration(phoneNumber);
      if (result['success'] == true) {
        _showOtpDialog(phoneNumber);
        testOtp = result['data'];
      } else {
        String errorMessage = mounted ? context.tr.failedToSendOtp : 'Failed to send OTP';
        if (authProvider.otpError != null &&
            authProvider.otpError!.isNotEmpty) {
          errorMessage = authProvider.otpError!;
        } else if (result['data'] != null && result['data'] is Map) {
          final data = result['data'] as Map<String, dynamic>;
          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            errorMessage = data['message'].toString();
          } else if (data['data'] != null &&
              data['data'].toString().isNotEmpty) {
            errorMessage = data['data'].toString();
          }
        } else if (result['message'] != null &&
            result['message'].toString().isNotEmpty) {
          errorMessage = result['message'].toString();
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  /// Shows error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        name: nameController.text,
        contactNo: contactController.text,
        email: emailController.text,
        otp: otpController.text,
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.registrationSuccessful),
            backgroundColor: AppConstants.accentColor,
          ),
        );
        _goToSignIn();
      } else {
        final message =
            authProvider.registrationError ??
            context.tr.registrationFailed;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  void _goToSignIn() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _clearFormFields() {
    nameController.clear();
    contactController.clear();
    emailController.clear();
    otpController.clear();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.value > 0) {
        _timeRemaining.value = _timeRemaining.value - 1;
      } else {
        _isResendEnabled.value = true;
        timer.cancel();
      }
    });
  }

  void _resendOTP() {
    _timeRemaining.value = 300;
    _isResendEnabled.value = false;
    _startTimer();
    // TODO: Implement OTP resend logic
  }

  /// Formats time in MM:SS format
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Builds the OTP timer section
  Widget _buildOTPTimer() {
    return ValueListenableBuilder<int>(
      valueListenable: _timeRemaining,
      builder: (context, time, _) {
        return Column(
          children: [
            Text(
              ('${context.tr.otpExpiresIn} ${_formatTime(time)}'),
              style: GoogleFonts.poppins(
                color: AppConstants.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isResendEnabled,
              builder: (context, enabled, __) {
                if (enabled) {
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _resendOTP,
                        child: Text(
                          context.tr.resendOtp,
                          style: AppConstants.linkTextStyle,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/twad_logo.png', height: 80),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 30),
                  CustomTextField(
                    hintText: context.tr.hintname,
                    controller: nameController,
                    validator: (value) =>
                        value!.isEmpty ? context.tr.hintname : null,
                  ),
                  CustomTextField(
                    hintText: context.tr.hintcontact,
                    controller: contactController,
                    inputFormatters: [
                      // Only allow digits and limit to 10 characters
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.phone,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.tr.hintcontact;
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return context.tr.errorcontact;
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    hintText: context.tr.hintEmail,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return context.tr.hintEmail;
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return context.tr.validEmail;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4F46E5), // #4F46E5
                                Color(0xFF3B82F6), // #3B82F6
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: auth.isRegistering
                                ? null
                                : _handleSignUpWithOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Transparent so gradient shows
                              shadowColor:
                                  Colors.transparent, // Remove button shadow
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: auth.isRegistering
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Text(
                                    context.tr.register,
                                    style: GoogleFonts.poppins(
                                      color: AppConstants.backgroundColor,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _goToSignIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr.alreadyhaveanaccount,
                          style: TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr.signin,
                          style: TextStyle(
                            color: AppConstants.primaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          AppConstants.appNameEnglish,
          style: AppConstants.titleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.appNameTamil,
          style: AppConstants.subtitleStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
