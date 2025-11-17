import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twad/extensions/translation_extensions.dart';
import '../constants/app_constants.dart';
import '../presentation/providers/auth_provider.dart';
import '../widgets/common/app_text_field.dart';
import 'otp_page.dart';
import 'registration_page.dart';

/// Login page widget for user authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
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
                  _buildMobileInput(),
                  const SizedBox(height: 30),
                  _buildOTPButton(),
                  const SizedBox(height: 30),
                  _buildCreateAccount(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the title section widget
  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          AppConstants.appNameEnglish,
          style: AppConstants.titleStyle,
          textAlign: TextAlign.center,
          key: Key('app_title'),
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

  Widget _buildMobileInput() {
    return AppTextField(
      key: Key('login_mobile_field'),
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      hintText: context.tr.hintcontact,
      prefixIcon: Icons.phone,
      inputFormatters: [
        // Only allow digits and limit to 10 characters
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleSignInWithOTP(),
    );
  }

  /// Builds the OTP sign in button
  Widget _buildOTPButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        key: Key('otp_button'),
        onPressed: _handleSignInWithOTP,
        style: AppConstants.primaryButtonStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        child: Text(
          context.tr.signninwithotp,
          style: AppConstants.buttonTextStyle,
        ),
      ),
    );
  }

  /// Builds the create account link
  Widget _buildCreateAccount() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppConstants.bodyTextStyle,
          children: [
            TextSpan(text: context.tr.noaccount),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: TextButton(
                onPressed: _handleCreateAccount,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  context.tr.createaccount,
                  style: AppConstants.linkTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles sign in with OTP button press
  void _handleSignInWithOTP() async {
    final phoneNumber = _mobileController.text.trim();

    // Validate phone number
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar(context.tr.hintcontact);
      return;
    }

    if (!AppConstants.isValidPhoneNumber(phoneNumber)) {
      _showErrorSnackBar(context.tr.validContactNumber);
      return;
    }

    // Get AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Show loading indicator
      _showLoadingDialog();

      // Use AuthProvider to send OTP (clean architecture)
      final result = await authProvider.sendOtp(phoneNumber);

      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      if (result['success'] == true) {
        // Navigate to OTP page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPPage(phoneNumber: phoneNumber),
          ),
        );
      } else {
        // Extract the specific error message from the API response
        String errorMessage = 'Failed to send OTP. Please try again.';

        // First try to get the message from authProvider.otpError
        if (authProvider.otpError != null &&
            authProvider.otpError!.isNotEmpty) {
          errorMessage = authProvider.otpError!;
        }
        // Then try to get the specific message from result data
        else if (result['data'] != null && result['data'] is Map) {
          final data = result['data'] as Map<String, dynamic>;
          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            errorMessage = data['message'].toString();
          } else if (data['data'] != null &&
              data['data'].toString().isNotEmpty) {
            errorMessage = data['data'].toString();
          }
        }
        // Fallback to result message
        else if (result['message'] != null &&
            result['message'].toString().isNotEmpty) {
          errorMessage = result['message'].toString();
        }

        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar('Error: ${e.toString()}');
      }
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

  /// Shows loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(context.tr.sendingOtp),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCreateAccount() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => RegistrationScreen()));
  }
}
