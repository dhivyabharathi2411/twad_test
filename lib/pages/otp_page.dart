import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/common/app_text_field.dart';
import '../presentation/providers/auth_provider.dart';
import '../pages/profile/profile_provider.dart';
import 'home_screen.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;

  const OTPPage({super.key, required this.phoneNumber});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  final ValueNotifier<int> _timeRemaining = ValueNotifier<int>(
    300,
  ); 
  final ValueNotifier<bool> _isResendEnabled = ValueNotifier<bool>(false);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _timeRemaining.dispose();
    _isResendEnabled.dispose();
    super.dispose();
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
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Card(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxCardWidth,
              ),
              padding: const EdgeInsets.all(AppConstants.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/twad_logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 30),
                  _buildOTPInput(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  _buildOTPTimer(),
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

  Widget _buildOTPInput() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (authProvider.otp != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧪 Development Mode Only',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Test OTP: ${authProvider.otp}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'In production, OTP will be sent via SMS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            AppTextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              hintText: context.tr.enterOTP,
              maxLength: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleOTPVerification(),
              prefixIcon: Icons.security,
            ),
          ],
        );
      },
    );
  }
  Widget _buildActionButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 48, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4F46E5), 
                      Color(0xFF3B82F6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: authProvider.isLoginLoading
                      ? null
                      : _handleOTPVerification,
                  style: AppConstants.primaryButtonStyle.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all(const Size(0, 48)),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                  child: authProvider.isLoginLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.tr.signin,
                          style: AppConstants.buttonTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center, 
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
            ),

            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 48, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  color: Colors.grey[800], 
                ),
                child: ElevatedButton(
                  onPressed: _handleBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    context.tr.back,
                    style: AppConstants.buttonTextStyle.copyWith(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
  Widget _buildOTPTimer() {
    return ValueListenableBuilder<int>(
      valueListenable: _timeRemaining,
      builder: (context, time, _) {
        return Column(
          children: [
            Text(
              'OTP Expires in ${_formatTime(time)}',
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

  void _handleOTPVerification() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.validOtp),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await authProvider.loginWithOtp(
        phoneNumber: widget.phoneNumber,
        otp: _otpController.text,
      );

      if (!mounted) return;
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.loginSuccessful),
            backgroundColor: AppConstants.accentColor,
          ),
        );

        final districtId = result['data']?['district_id'];
        if (districtId != null && 
            districtId.toString() != '0' && 
            districtId.toString().isNotEmpty) {
          try {
            if (mounted) {
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              profileProvider.setProfileUpdatedTrue();
            }
          } catch (e) {
            //
          }
        } else {
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false, 
        );
      } else {
        String errorMessage = 'Invalid OTP. Please try again.';
        if (authProvider.loginError != null &&
            authProvider.loginError!.isNotEmpty) {
          errorMessage = authProvider.loginError!;
        }
        else if (result['message'] != null &&
            result['message'].toString().isNotEmpty) {
          errorMessage = result['message'].toString();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
  void _handleBack() {
    Navigator.of(context).pop(); 
  }
}
