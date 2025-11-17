import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twad/presentation/providers/locale_provider.dart';
import 'package:twad/widgets/buildheader.dart';
import 'package:twad/widgets/buildfooter.dart';
import 'package:twad/pages/dashboard/dashboard.dart';
import 'package:twad/pages/grievancestatus/grivancestatus.dart';
import 'package:twad/pages/profile/profile.dart';
import '../constants/app_constants.dart';
import '../utils/simple_encryption.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<String> _displayedUserName = ValueNotifier<String>("");
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return DashboardPage(displayedUserName: _displayedUserName);
      case 1:
        return GrievanceStatusPage();
      case 2:
        return ProfilePage(displayedUserName: _displayedUserName);
      default:
        return DashboardPage(displayedUserName: _displayedUserName);
    }
  }

  Future<void> _loadUserName() async {
    final userData = await SimpleUsage.getCurrentUser();
    if (userData != null && userData['name'] != null) {
      _displayedUserName.value = userData['name'].toString();
    }
  }

  void _onTabTapped(int index) {
    _selectedIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, _) {
          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: ValueListenableBuilder<String>(
                valueListenable: _displayedUserName,
                builder: (context, userName, _) {
                  return BuildHeader(displayedUserName: _displayedUserName);
                },
              ),
            ),
            body: Stack(
              children: [
                SafeArea(child: _getPageForIndex(selectedIndex)),
                // Positioned(
                //   bottom: 50,
                //   right: 20,
                //   child: FloatingActionButton(
                //     onPressed: () {
                //     },
                //     backgroundColor: Colors.green,
                //     child: Icon(Icons.access_time_sharp, size: 28, color: Colors.white),
                //   ),
                // ),
              ],
            ),
            bottomNavigationBar: Consumer<LocaleProvider>(
              builder: (context, locale, child) {
                return Buildfooter(
                  selectedIndex: selectedIndex,
                  onTap: _onTabTapped,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
