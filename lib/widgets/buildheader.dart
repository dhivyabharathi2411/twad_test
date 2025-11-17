import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/presentation/providers/locale_provider.dart';
import '../constants/app_constants.dart';
import '../pages/login_page.dart';
import '../pages/profile/profile_provider.dart';
import '../presentation/providers/grievance_provider.dart';
import '../services/logout_service.dart';
import '../utils/app_utils.dart';

class BuildHeader extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<String> displayedUserName;

  const BuildHeader({Key? key, required this.displayedUserName})
    : super(key: key);

  @override
  _BuildHeaderState createState() => _BuildHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BuildHeaderState extends State<BuildHeader> {
  final ValueNotifier<bool> _isLoggingOut = ValueNotifier(false);

  Future<void> _performLogout() async {
    _isLoggingOut.value = true;
    final LogoutService _logoutService = LogoutService();
    try {
      final logoutResult = await _logoutService.logout();

      // Clear all profile and dropdown data from provider and SharedPreferences
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.clearUserData();

      final grievanceProvider = Provider.of<GrievanceProvider>(context, listen: false);
      grievanceProvider.resetData();

      // Clear all session data from SharedPreferences (user form data)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('name');
      await prefs.remove('contactno');
      await prefs.remove('emailid');
      await prefs.remove('address');
      
      // Clear any other session data that might be stored
      await prefs.remove('token');
      await prefs.remove('user_id');
      await prefs.remove('login_status');
      
      // Clear all SharedPreferences keys to ensure complete logout
      // You can also use prefs.clear() if you want to clear everything
      // await prefs.clear();

      if (logoutResult['success'] == true) {
        AppUtils.showSnackBar(
          context,
          context.tr.loggedOut,
          type: SnackBarType.success,
        );
      } else {
        AppUtils.showSnackBar(
          context,
          'Logout completed with warnings: ${logoutResult['message']}',
          type: SnackBarType.warning,
        );
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      AppUtils.showSnackBar(
        context,
        'Logout completed with errors: ${e.toString()}',
        type: SnackBarType.error,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } finally {
      _isLoggingOut.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Image.asset(
              'assets/images/twad_logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TWAD',
                  style: AppConstants.titleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: widget.displayedUserName,
                  builder: (context, value, child) {
                    return Text(
                      '${context.tr.welcome} $value',
                      style: AppConstants.bodyTextStyle.copyWith(
                        fontSize: 8,
                        color: AppConstants.textSecondaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),

            /// Language Selector
            _buildLanguageSelector(),

            const SizedBox(width: 16),

            /// Logout dropdown
            /// Logout dropdown
            ValueListenableBuilder<bool>(
              valueListenable: _isLoggingOut,
              builder: (context, isLoggingOut, child) {
                return PopupMenuButton<String>(
                  icon: isLoggingOut
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Icon(Icons.person_outline, color: Colors.black),
                  offset: const Offset(0, 65),
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'logout') {
                      _performLogout();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 8),
                          Text(context.tr.logout),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLanguageOption(context, 'en', 'English'),
                        const SizedBox(height: 8),
                        _buildLanguageOption(context, 'ta', 'தமிழ்'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Row(
            children: [
              Icon(Icons.language, color: Colors.red),
              SizedBox(width: 6),
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  String languageText =
                      localeProvider.locale.languageCode == 'ta'
                      ? 'தமிழ்'
                      : 'English';
                  return Text(
                    languageText,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isSelected = localeProvider.locale.languageCode == code;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        localeProvider.setLocale(Locale(code));
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.language, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
