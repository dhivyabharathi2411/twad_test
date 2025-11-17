import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:twad/extensions/translation_extensions.dart';

import 'package:twad/pages/grievancestatus/grievacnecard.dart';
import 'package:twad/pages/home_screen.dart';
import '../../constants/app_constants.dart';
import '../../data/models/grievance_model.dart';
import '../../data/models/grievance_status.dart';
import '../../presentation/providers/acknowledgement_provider.dart';
import '../../presentation/providers/locale_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../presentation/providers/grievance_provider.dart';
import '../complaintdetails/complaintdetails.dart';
import '../newgrievance/newgrievance.dart';
import '../profile/profile_provider.dart';
import '../profile/profile.dart';

class GrievanceStatusPage extends StatefulWidget {
  const GrievanceStatusPage({super.key});

  @override
  State<GrievanceStatusPage> createState() => _GrievanceStatusPageState();
}

class _GrievanceStatusPageState extends State<GrievanceStatusPage> {
  final ValueNotifier<int?> _selectedComplaintId = ValueNotifier<int?>(null);
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<GrievanceModel>> _allGrievances =
      ValueNotifier<List<GrievanceModel>>([]);
  final ValueNotifier<List<GrievanceModel>> _filteredGrievances =
      ValueNotifier<List<GrievanceModel>>([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final ValueNotifier<GrievanceStatus?> _selectedStatusFilter =
      ValueNotifier<GrievanceStatus?>(null);
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(1);
  final int _itemsPerPage = 10;
  final ValueNotifier<List<GrievanceModel>> _paginatedGrievances =
      ValueNotifier<List<GrievanceModel>>([]);

  // Add new ValueNotifiers for additional filters
  final ValueNotifier<DateTime?> _fromDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _toDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> _isFilterExpanded = ValueNotifier<bool>(false);

  final ValueNotifier<bool> _isInitialized = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<GrievanceProvider>(context, listen: false);
    final hasExistingData =
        provider.grievances != null && provider.grievances!.isNotEmpty;

    if (hasExistingData) {
      _allGrievances.value = provider.grievances!;
      _filterGrievances();

      _isLoading.value = false;
      _isInitialized.value = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasExistingData && !provider.isLoadingAll) {
        _isLoading.value = true;
        _loadGrievances();
      } else if (!hasExistingData) {
        _isInitialized.value = true;
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _forceRefresh() async {
    final provider = Provider.of<GrievanceProvider>(context, listen: false);
    provider.forceStatusSync();
    await _loadGrievances();
  }

  void _ensureDataConsistency() {
    if (_allGrievances.value.isNotEmpty && _isLoading.value) {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _selectedComplaintId.dispose();
    _allGrievances.dispose();
    _filteredGrievances.dispose();
    _isLoading.dispose();
    _searchQuery.dispose();
    _selectedStatusFilter.dispose();
    _currentPage.dispose();
    _paginatedGrievances.dispose();
    _isInitialized.dispose();
    _fromDate.dispose();
    _toDate.dispose();
    _isFilterExpanded.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchQuery.value = _searchController.text;
    _filterGrievances();
  }

  void _filterGrievances() {
    final all = _allGrievances.value;
    final search = _searchQuery.value;
    final status = _selectedStatusFilter.value;
    final fromDate = _fromDate.value;
    final toDate = _toDate.value;

    final filtered = all.where((grievance) {
      // Search filter
      final matchesSearch =
          search.isEmpty ||
          grievance.complaintSubType.toLowerCase().contains(
            search.toLowerCase(),
          ) ||
          grievance.districtName.toLowerCase().contains(search.toLowerCase()) ||
          grievance.complaintStatus.toString().contains(search.toLowerCase()) ||
          grievance.complaintNo.toLowerCase().contains(search.toLowerCase());

      // Status filter
      final matchesStatus =
          status == null || grievance.complaintStatus == status;

      // Date range filter
      final grievanceDate = grievance.complaintDateTime;
      final matchesDateRange =
          (fromDate == null ||
              grievanceDate.isAfter(fromDate.subtract(Duration(days: 1)))) &&
          (toDate == null ||
              grievanceDate.isBefore(toDate.add(Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesDateRange;
    }).toList();

    _filteredGrievances.value = filtered;
    _currentPage.value = 1; // Reset to first page when filtering
    _updatePaginatedGrievances();
  }

  void _updatePaginatedGrievances() {
    final filtered = _filteredGrievances.value;
    final startIndex = (_currentPage.value - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginated = filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
    _paginatedGrievances.value = paginated;
    _ensureDataConsistency();
  }

  int get _totalPages =>
      (_filteredGrievances.value.length / _itemsPerPage).ceil();

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage.value = page;
      _updatePaginatedGrievances();
      if (_isLoading.value && _allGrievances.value.isNotEmpty) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> _downloadAcknowledgement(
    BuildContext context,
    int grievanceId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<AcknowledgementProvider>(
      context,
      listen: false,
    );

    provider.setDownloadProcessing(grievanceId, true);
    await provider.fetchAcknowledgementPdf(grievanceId);

    final pdfPath = provider.pdfUrl;
    final errorMessage = provider.errorMessage;
    final fileName = 'TWAD_Acknowledgement_$grievanceId.pdf';
    final baseUrl = 'https://api.tanneer.com/uploads';
    final fullUrl = '$baseUrl$pdfPath';

    if (pdfPath == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Unable to get acknowledgement file'),
          backgroundColor: Colors.red,
        ),
      );
      provider.setDownloadProcessing(grievanceId, false);
      return;
    }

    try {
      final response = await Dio().get<List<int>>(
        fullUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);

      const platform = MethodChannel('com.example.twad/download');
      final savedPath = await platform.invokeMethod('saveFile', {
        'bytes': bytes,
        'fileName': fileName,
      });

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Download complete'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      if (savedPath != null && savedPath.isNotEmpty) {
        await OpenFilex.open(savedPath);
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6),
        ),
      );
    } finally {
      provider.setDownloadProcessing(grievanceId, false);
    }
  }

  Future<void> _loadGrievances() async {
    _isLoading.value = true;
    final provider = Provider.of<GrievanceProvider>(context, listen: false);
    await provider.fetchGrievances();
    _allGrievances.value = provider.grievances ?? [];
    _filterGrievances();
    _isLoading.value = false;
    _isInitialized.value = true; // Mark as initialized after loading
  }

  Widget _buildSearchSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFilterExpanded,
      builder: (context, isExpanded, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Search Filter Header with expand/collapse
              GestureDetector(
                onTap: () => _isFilterExpanded.value = !_isFilterExpanded.value,
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Text(
                      context.tr.search,
                      style: AppConstants.titleStyle.copyWith(
                        fontSize: 16,
                        color: Colors.blue[600],
                      ),
                    ),
                    Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.blue[600],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Basic Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[500]),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: context.tr.search,
                          hintStyle: AppConstants.bodyTextStyle.copyWith(
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: AppConstants.bodyTextStyle,
                        onChanged: (text) {
                          _searchQuery.value = text;
                          // Don't filter immediately, wait for search button
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Expandable Advanced Filters
              if (isExpanded) ...[
                SizedBox(height: 16),
                _buildAdvancedFilters(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Filters
        Row(
          children: [
            Expanded(
              child: _buildDateFilter(
                label: context.tr.from,
                selectedDate: _fromDate,
                onDateSelected: (date) {
                  _fromDate.value = date;
                  // Don't filter immediately, wait for search button
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDateFilter(
                label: context.tr.to,
                selectedDate: _toDate,
                onDateSelected: (date) {
                  _toDate.value = date;
                  // Don't filter immediately, wait for search button
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Grievance Status Filter
        _buildStatusFilter(),

        SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(context.tr.search),
              ),
            ),
            SizedBox(width: 12),
            // Expanded(
            //   child: OutlinedButton(
            //     onPressed: _clearFilters,
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: Colors.grey[600],
            //       padding: EdgeInsets.symmetric(vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //     ),
            //     child: Text('Clear'),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilter({
    required String label,
    required ValueNotifier<DateTime?> selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: selectedDate,
      builder: (context, date, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppConstants.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date != null
                            ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
                            : label,
                        style: AppConstants.bodyTextStyle.copyWith(
                          color: date != null ? Colors.black : Colors.grey[500],
                        ),
                      ),
                    ),
                    if (date != null)
                      GestureDetector(
                        onTap: () => onDateSelected(null),
                        child: Icon(
                          Icons.clear,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return ValueListenableBuilder<GrievanceStatus?>(
      valueListenable: _selectedStatusFilter,
      builder: (context, selectedStatus, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr.grievanceStatus,
              style: AppConstants.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<GrievanceStatus?>(
                        value: selectedStatus,
                        isExpanded: true,
                        hint: Text(
                          _isLoading.value
                              ? context.tr.loadingData
                              : (_allGrievances.value.isEmpty
                                    ? context.tr.noDataFound
                                    : context.tr.select),
                          style: AppConstants.bodyTextStyle.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: GrievanceStatus.submitted,
                            child: Text(context.tr.submittedStatus),
                          ),
                          DropdownMenuItem(
                            value: GrievanceStatus.inProgress,
                            child: Text(context.tr.inProgress),
                          ),
                          DropdownMenuItem(
                            value: GrievanceStatus.processing,
                            child: Text(context.tr.processing),
                          ),
                          DropdownMenuItem(
                            value: GrievanceStatus.closed,
                            child: Text(context.tr.closed),
                          ),
                        ],
                        onChanged: (value) {
                          _selectedStatusFilter.value = value;
                          // don't call _filterGrievances() here so filters are applied when user taps Search
                        },
                      ),
                    ),
                  ),
                  if (selectedStatus != null) ...[
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: Colors.grey[600],
                      ),

                      onPressed: () {
                        _selectedStatusFilter.value = null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    _filterGrievances();
  }

  Widget _buildLoadingState() {
    return _buildGrievanceListShimmer();
  }

  Widget _buildGrievanceListShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: List.generate(
          8,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 18,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Date
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 32,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          height: 32,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableGrievancesList() {
    return ValueListenableBuilder<List<GrievanceModel>>(
      valueListenable: _paginatedGrievances,
      builder: (context, paginated, _) {
        return ValueListenableBuilder<List<GrievanceModel>>(
          valueListenable: _filteredGrievances,
          builder: (context, filtered, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isInitialized,
              builder: (context, isInitialized, _) {
                final search = _searchQuery.value;
                if (filtered.isEmpty && isInitialized) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: 40,
                    ),
                    child: TWADEmptyState(
                      icon: Icons.assignment_outlined,
                      title: search.isNotEmpty
                          ? context.tr.noResultsFound
                          : context.tr.noGrievance,
                      subtitle: search.isNotEmpty
                          ? context.tr.tryAdjustingSearch
                          : context.tr.noGrievancesSubmitted,
                      action: search.isEmpty
                          ? Consumer<ProfileProvider>(
                              builder: (context, profileProvider, child) {
                                return ElevatedButton.icon(
                                  onPressed: () {
                                    if (profileProvider.isprofileUpated ==
                                        false) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            displayedUserName:
                                                ValueNotifier<String>(''),
                                          ),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NewGrievancePage(),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(context.tr.addGreivance),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  );
                }

                if (!isInitialized) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    ...paginated
                        .map(
                          (grievance) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultPadding,
                              vertical: 8,
                            ),
                            child: Consumer<AcknowledgementProvider>(
                              builder: (context, ackProvider, child) {
                                final isProcessing = ackProvider
                                    .isDownloadProcessing(grievance.id);
                                return GrievanceCard(
                                  grievance: grievance,
                                  onDownload: isProcessing
                                      ? null
                                      : () => _downloadAcknowledgement(
                                          context,
                                          grievance.id,
                                        ),
                                  onWhatsApp: () =>
                                      _showComplaintInline(grievance),
                                  isDownloadProcessing: isProcessing,
                                );
                              },
                            ),
                          ),
                        ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 20,
                      ),
                      child: _buildPaginationControls(),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
  void _showComplaintInline(GrievanceModel grievance) {
    _selectedComplaintId.value = grievance.id;
  }

  Widget _buildPaginationControls() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (context, currentPage, _) {
        return ValueListenableBuilder<List<GrievanceModel>>(
          valueListenable: _filteredGrievances,
          builder: (context, filtered, _) {
            if (filtered.isEmpty) return const SizedBox();

            final totalItems = filtered.length;
            final startItem = (currentPage - 1) * _itemsPerPage + 1;
            final endItem = currentPage * _itemsPerPage > totalItems
                ? totalItems
                : currentPage * _itemsPerPage;
            final totalPages = _totalPages;

            if (totalPages <= 1) return const SizedBox();

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing $startItem to $endItem of $totalItems',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: currentPage > 1
                            ? () => _goToPage(currentPage - 1)
                            : null,
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: currentPage > 1
                                ? const Color(0xFF6B7280)
                                : const Color(0xFFD1D5DB),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: currentPage > 1
                                ? TextDecoration.none
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '$currentPage',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: currentPage < totalPages
                            ? () => _goToPage(currentPage + 1)
                            : null,
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: currentPage < totalPages
                                ? const Color(0xFF6B7280)
                                : const Color(0xFFD1D5DB),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: currentPage < totalPages
                                ? TextDecoration.none
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home screen instead of closing the app
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Container(
        color: AppConstants.backgroundColor,
        child: SafeArea(
          child: ValueListenableBuilder<int?>(
            valueListenable: _selectedComplaintId,
            builder: (context, selectedId, _) {
              if (selectedId != null) {
                // Show ComplaintDetailsPage when a specific grievance is selected
                return Column(
                  children: [
                    SizedBox(height: 15),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => _selectedComplaintId.value = null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr.complaintdetails,
                          style: AppConstants.titleStyle.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ComplaintDetailsPage(grievanceId: selectedId),
                    ),
                  ],
                );
              }

              return ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, loading, _) {
                  final shouldShowShimmer =
                      loading && _allGrievances.value.isEmpty;

                  if (shouldShowShimmer) {
                    return _buildLoadingState();
                  }

                  return RefreshIndicator(
                    onRefresh: _forceRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultPadding,
                            ),
                            child: _buildPageHeader(),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultPadding,
                            ),
                            child: _buildSearchSection(),
                          ),
                          const SizedBox(height: 10),
                          _buildScrollableGrievancesList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                context.tr.statusPageTitle,
                style: AppConstants.titleStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    context.tr.grievance,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    context.tr.grievanceStatus,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
