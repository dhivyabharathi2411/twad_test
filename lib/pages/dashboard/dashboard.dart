import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/pages/dashboard/grievancelist.dart';
import 'package:twad/pages/dashboard/statisticCard.dart';
import 'package:twad/pages/profile/profile.dart';
import 'package:twad/pages/profile/profile_provider.dart';
import 'package:twad/presentation/providers/locale_provider.dart';

import '../../constants/app_constants.dart';
import '../../presentation/providers/grievance_provider.dart';
import '../complaintdetails/complaintdetails.dart';
import '../newgrievance/newgrievance.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final ValueNotifier<String> displayedUserName;

  const DashboardPage({
    super.key,
    this.userName = 'User',
    this.onProfileTap,
    this.onNotificationTap,
    required this.displayedUserName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  final ValueNotifier<int?> _selectedComplaintId = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void didPopNext() {
    _refreshDashboard();
  }

  @override
  void dispose() {
    _selectedComplaintId.dispose();
    super.dispose();
  }
  Future<void> _loadDashboardData() async {
    final provider = Provider.of<GrievanceProvider>(context, listen: false);

    if (provider.grievanceCount == null && !provider.isLoadingCount) {
      provider.fetchGrievanceCount();
    }

    if ((provider.recentGrievances == null ||
            provider.recentGrievances!.isEmpty) &&
        !provider.isLoadingRecent) {
      provider.fetchRecentGrievances();
    }
  }
  Future<void> _refreshDashboard() async {
    final provider = Provider.of<GrievanceProvider>(context, listen: false);

    try {
      await provider.forceStatusSync();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Refresh failed: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GrievanceProvider, LocaleProvider>(
      builder: (context, grievanceProvider, localeProvider, child) {
        final isDashboardLoading =
            grievanceProvider.isLoadingCount ||
            grievanceProvider.isLoadingRecent;

        return SafeArea(
          child: isDashboardLoading
              ? _buildDashboardShimmer()
              : ValueListenableBuilder<int?>(
                  valueListenable: _selectedComplaintId,
                  builder: (context, selectedId, _) {
                    if (selectedId != null) {
                      return Column(
                        children: [
                          SizedBox(height: 15),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => _selectedComplaintId.value =
                                    null, 
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr.complaintdetails,
                                style: AppConstants.titleStyle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ComplaintDetailsPage(
                              grievanceId: selectedId,
                            ),
                          ),
                        ],
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshDashboard,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Column(
                          children: [
                            _buildWelcomeSection(),
                            _buildStatisticsCards(grievanceProvider),
                            _buildGrievanceList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return ValueListenableBuilder<String>(
          valueListenable: widget.displayedUserName,
          builder: (context, name, _) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Text(
                key: Key('welcome_text'),
                '${context.tr.welcome} $name',
                style: AppConstants.titleStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatisticsCards(GrievanceProvider grievanceProvider) {
    return Consumer2<GrievanceProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        return Column(
          children: [
            StatisticCard(
              title: context.tr.dashboardCardtext1,
              count: grievanceProvider.grievanceCount?.total ?? 0,
              color: AppConstants.grievanceViolet,
              icon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 15),
            StatisticCard(
              title: context.tr.dashboardCardtext2,
              count: grievanceProvider.grievanceCount?.inProgress ?? 0,
              color: AppConstants.grievanceGreen,
              icon: Icons.trending_up_outlined,
            ),
            const SizedBox(height: 15),
            StatisticCard(
              title: context.tr.dashboardCardtext3,
              count: grievanceProvider.grievanceCount?.closed ?? 0,
              color: AppConstants.grievanceRed,
              icon: Icons.check_circle_outline,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrievanceList() {
    return Consumer2<GrievanceProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        return Column(
          children: [
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (profileProvider.isprofileUpated == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewGrievancePage(),
                              fullscreenDialog: true,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                displayedUserName: widget.displayedUserName,
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(context.tr.addGreivance),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _buildRecentGrievancesSection(),
          ],
        );
      },
    );
  }

  Widget _buildRecentGrievancesSection() {
    return Consumer2<GrievanceProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final displayGrievances = provider.recentGrievances ?? [];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  context.tr.recentCardstitle,
                  style: AppConstants.titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (provider.isLoadingRecent)
                _buildRecentGrievancesShimmer()
              else if (!provider.isLoadingRecent && displayGrievances.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr.noGrievance,
                          style: AppConstants.bodyTextStyle.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  key: ValueKey(
                    'recent_grievances_list_${displayGrievances.length}_${provider.lastUpdateTimestamp}',
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayGrievances.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final grievance = displayGrievances[index];
                    return GrievanceListItem(
                      grievanceId: grievance.id,
                      onShowDetails: (id) {
                        _selectedComplaintId.value = id;
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeShimmer(),
          const SizedBox(height: 10),
          _buildStatisticsShimmer(),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 160,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildRecentGrievancesSectionShimmer(),
        ],
      ),
    );
  }

  Widget _buildWelcomeShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 30,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                ),
              ),
            ),
            if (index < 2) const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGrievancesShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < 2) Divider(height: 1, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGrievancesSectionShimmer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 18,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          _buildRecentGrievancesShimmer(),
        ],
      ),
    );
  }
}
