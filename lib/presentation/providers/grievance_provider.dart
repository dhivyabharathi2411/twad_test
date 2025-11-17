import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/grievance_count_model.dart';
import '../../data/models/grievance_model.dart';
import '../../data/models/recent_grievance_model.dart';
import '../../data/models/grievance_detail_model.dart';
import '../../data/models/grievance_status.dart';
import '../../services/grievance_service.dart';

class GrievanceProvider extends ChangeNotifier {
  final GrievanceService _service = GrievanceService();
  int _lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;

  int get lastUpdateTimestamp => _lastUpdateTimestamp;

  @override
  void notifyListeners() {
    _lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
    super.notifyListeners();
  }

  GrievanceCount? _grievanceCount;
  String? _countError;
  bool _isLoadingCount = false;

  List<RecentGrievanceModel>? _recentGrievances;
  bool _isLoadingRecent = false;
  String? _recentError;

  List<GrievanceModel>? _grievances;
  bool _isLoadingAll = false;
  String? _grievanceError;

  bool _isSubmitting = false;
  String? _submitError;
  String? _submitSuccessMessage;

  bool _isReopening = false;
  String? _reopenError;
  String? _reopenSuccessMessage;

  GrievanceDetail? _grievanceDetail;
  bool _isLoadingDetail = false;
  String? _detailError;

  GrievanceCount? get grievanceCount => _grievanceCount;
  List<RecentGrievanceModel>? get recentGrievances => _recentGrievances;
  List<GrievanceModel>? get grievances => _grievances;

  bool get isLoadingCount => _isLoadingCount;
  bool get isLoadingRecent => _isLoadingRecent;
  bool get isLoadingAll => _isLoadingAll;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  String? get submitSuccessMessage => _submitSuccessMessage;

  bool get isReopening => _isReopening;
  String? get reopenError => _reopenError;
  String? get reopenSuccessMessage => _reopenSuccessMessage;

  String? get countError => _countError;
  String? get recentError => _recentError;
  String? get grievanceError => _grievanceError;

  GrievanceDetail? get grievanceDetail => _grievanceDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;


  Future<void> fetchGrievanceCount() async {
    _isLoadingCount = true;
    _countError = null;
    notifyListeners();

    try {
      final result = await _service.getGrievanceCount();

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        Map<String, dynamic>? jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else if (data is List &&
            data.isNotEmpty &&
            data[0] is Map<String, dynamic>) {
          jsonData = data[0] as Map<String, dynamic>;
        }

        if (jsonData != null) {
          _grievanceCount = GrievanceCount.fromJson(jsonData);
        } else {
          _countError = 'Data is not a valid object format';
        }
      } else {
        _countError = result['message'] ?? 'Failed to fetch grievance count';
      }
    } catch (e) {
      _countError = e.toString();
    }

    _isLoadingCount = false;
    notifyListeners();
  }
  Future<void> fetchRecentGrievances() async {
    _isLoadingRecent = true;
    _recentError = null;
    notifyListeners();

    try {
      final result = await _service.getRecentGrievances();

      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> apiData = result['data'] ?? [];
        if (apiData.isNotEmpty) {
        }

        if (apiData.isNotEmpty && apiData.first is RecentGrievanceModel) {

          _recentGrievances = List<RecentGrievanceModel>.from(apiData);

        } else {
          _recentGrievances = apiData
              .map((json) => RecentGrievanceModel.fromJson(json))
              .toList();
        }
      } else {
        _recentError = result['message'] ?? 'Failed to fetch recent grievances';
      }
    } catch (e) {
      _recentError = e.toString();
    }

    _isLoadingRecent = false;
    notifyListeners();
  }

  Future<void> fetchGrievances({
    String? fromDate,
    String? toDate,
    String? complaintStatus,
  }) async {
    _isLoadingAll = true;
    _grievanceError = null;
    notifyListeners();

    try {
      _grievances = await _service.fetchAllGrievances(
        fromDate: fromDate,
        toDate: toDate,
        complaintStatus: complaintStatus,
      );
      if (_grievances != null && _grievances!.isNotEmpty) {
        for (int i = 0; i < _grievances!.length; i++) {
          final grievance = _grievances![i];
        }
      }
    } catch (e) {
      _grievanceError = e.toString();
      _grievances = [];
    }

    _isLoadingAll = false;
    notifyListeners();
  }

  Future<void> submitGrievance(
  Map<String, dynamic> grievanceData, {
  double? selectedLatitude,
  double? selectedLongitude,
}) async {
  _isSubmitting = true;
  _submitError = null;
  _submitSuccessMessage = null;
  notifyListeners();

  try {
    if (selectedLatitude != null && selectedLongitude != null) {
      grievanceData['lat'] = selectedLatitude;
      grievanceData['lng'] = selectedLongitude;
    } else {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      grievanceData['lat'] = position.latitude;
      grievanceData['lng'] = position.longitude;
    }

    final result = await _service.createGrievance(grievanceData);
    if (result['success']) {
      _submitSuccessMessage = result['message'] ?? 'Grievance submitted successfully';
    } else {
      _submitError = result['message'] ?? 'Submission failed';
    }
  } catch (e) {
    _submitError = e.toString();
  }

  _isSubmitting = false;
  notifyListeners();
}
  Future<void> reopenGrievance(int grievanceId, String comments) async {
    _isReopening = true;
    _reopenError = null;
    _reopenSuccessMessage = null;
    notifyListeners();

    try {
      final result = await _service.reopenGrievance(grievanceId, comments);

      if (result['success'] && result['message']?.toLowerCase() != 'failed') {
        _reopenSuccessMessage =
            result['message'] ?? 'Grievance reopened successfully';
        GrievanceStatus newStatus = GrievanceStatus.submitted; 

        if (result['data'] != null && result['data'] is Map<String, dynamic>) {
          final data = result['data'] as Map<String, dynamic>;
          if (data['new_status'] != null) {
            try {
              newStatus = parseGrievanceStatus(data['new_status'].toString());
            } catch (e) {
            }
          }
        }

        await refreshAll();
        GrievanceModel? serverGrievance;
        try {
          serverGrievance = _grievances?.firstWhere((g) => g.id == grievanceId);
        } catch (e) {
        }

        if (serverGrievance != null) {
        } else {
        }
        updateGrievanceStatus(grievanceId, newStatus);
        RecentGrievanceModel? updatedRecentGrievance;
        try {
          updatedRecentGrievance = _recentGrievances?.firstWhere(
            (g) => g.id == grievanceId,
          );
        } catch (e) {
        }

        if (updatedRecentGrievance != null) {
        }

        GrievanceModel? updatedAllGrievance;
        try {
          updatedAllGrievance = _grievances?.firstWhere(
            (g) => g.id == grievanceId,
          );
        } catch (e) {
        }

        if (updatedAllGrievance != null) {
        }
        notifyListeners();
        await Future.delayed(Duration(milliseconds: 100));
        notifyListeners();
        await Future.delayed(Duration(milliseconds: 100));
        notifyListeners();
        forceRefreshGrievance(grievanceId);
        if (_grievanceDetail?.id == grievanceId) {
          await fetchGrievanceDetail(grievanceId);
        }
      } else {
        if (result['success'] && result['message']?.toLowerCase() == 'failed') {
          _reopenError = 'Failed to reopen grievance: ${result['message']}';
        } else {
          _reopenError = result['message'] ?? 'Failed to reopen grievance';
        }
      }
    } catch (e) {
      _reopenError = e.toString();
    }

    _isReopening = false;
    notifyListeners();
  }

  Future<void> fetchGrievanceDetail(int grievanceId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _grievanceDetail = null;
    notifyListeners();

    try {
      final result = await _service.getGrievanceDetails(grievanceId);
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        final details = data['grievance_details'];
        final documents = data['grievance_document_list'];
        final processHistory = data['grievance_process_history'];

        if (details != null && details is List && details.isNotEmpty) {
          final grievanceDetailData = Map<String, dynamic>.from(details[0]);
          grievanceDetailData['grievance_document_list'] = documents ?? [];
          grievanceDetailData['grievance_process_history'] = processHistory ?? [];
          _grievanceDetail = GrievanceDetail.fromJson(grievanceDetailData);
        } else {
          _detailError = 'No grievance detail found';
        }
      } else {
        _detailError = result['message'] ?? 'Failed to fetch grievance detail';
      }
    } catch (e) {
      _detailError = e.toString();
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {

    try {
      await Future.wait([
        fetchGrievanceCount(),
        fetchRecentGrievances(),
        fetchGrievances(),
      ]);
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> forceStatusSync() async {
    resetData();

    await Future.delayed(Duration(milliseconds: 50));
    await refreshAll();
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 50));
    notifyListeners();
  }

  void resetData() {
    _grievanceCount = null;
    _recentGrievances = null;
    _grievances = null;
    _grievanceDetail = null;

    _countError = null;
    _recentError = null;
    _grievanceError = null;
    _detailError = null;
    _submitError = null;
    _submitSuccessMessage = null;
    _reopenError = null;
    _reopenSuccessMessage = null;

    notifyListeners();
  }
  void resetReopenState() {
    _isReopening = false;
    _reopenError = null;
    _reopenSuccessMessage = null;
    notifyListeners();
  }
  void updateGrievanceStatus(int grievanceId, GrievanceStatus newStatus) {

    try {
      if (_recentGrievances != null) {
        final index = _recentGrievances!.indexWhere((g) => g.id == grievanceId);
        if (index != -1) {
          final oldGrievance = _recentGrievances![index];
          _recentGrievances![index] = RecentGrievanceModel(
            id: oldGrievance.id,
            complaintNo: oldGrievance.complaintNo,
            status: newStatus,
            title: oldGrievance.title,
            complaintDate: oldGrievance.complaintDate,
            complaintTime: oldGrievance.complaintTime,
            complaintTimeFormatted: oldGrievance.complaintTimeFormatted,
            districtName: oldGrievance.districtName,
            complaintType: oldGrievance.complaintType,
          );
        } else {
        }
      } else {
      }
      if (_grievances != null) {
        final index = _grievances!.indexWhere((g) => g.id == grievanceId);
        if (index != -1) {
          final oldGrievance = _grievances![index];
          _grievances![index] = GrievanceModel(
            id: oldGrievance.id,
            complaintDateTime: oldGrievance.complaintDateTime,
            complaintNo: oldGrievance.complaintNo,
            complaintStatus: newStatus,
            districtName: oldGrievance.districtName,
            complaintType: oldGrievance.complaintType,
            complaintSubType: oldGrievance.complaintSubType,
            grievanceType: oldGrievance.grievanceType,
            publicName: oldGrievance.publicName,
            publicWhatsappNo: oldGrievance.publicWhatsappNo,
            publicContactNo: oldGrievance.publicContactNo,
            publicEmailId: oldGrievance.publicEmailId,
            publicAddress: oldGrievance.publicAddress,
            complaintTimeFormatted: oldGrievance.complaintTimeFormatted,
            originImage: oldGrievance.originImage,
            reopen: oldGrievance.reopen,
            reopenedRefNo: oldGrievance.reopenedRefNo,
            isReopen: oldGrievance.isReopen,
            reopenRefId: oldGrievance.reopenRefId,
            reopenComments: oldGrievance.reopenComments,
            organisationName: oldGrievance.organisationName,
            zoneName: oldGrievance.zoneName,
            zoneWardName: oldGrievance.zoneWardName,
            municipalityName: oldGrievance.municipalityName,
            municipalityWardName: oldGrievance.municipalityWardName,
            townPanchayatName: oldGrievance.townPanchayatName,
            townPanchayatWardName: oldGrievance.townPanchayatWardName,
            divisionName: oldGrievance.divisionName,
            blockName: oldGrievance.blockName,
            villageName: oldGrievance.villageName,
            habitationName: oldGrievance.habitationName,
          );
        } else {
        }
      } else {
      }

      if (_grievanceDetail?.id == grievanceId) {
        final newStatusString = newStatus.toString().split('.').last;
      }
      notifyListeners();
    } catch (e) {
    }
  }

  void forceRefreshGrievance(int grievanceId) {
    _isReopening = !_isReopening;

    notifyListeners();
    _isReopening = !_isReopening;
    notifyListeners();
  }
}
