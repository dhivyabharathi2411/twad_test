import 'package:flutter/material.dart';

import '../../services/acknowledgement_service.dart';

class AcknowledgementProvider extends ChangeNotifier {
  final AcknowledgementService _service = AcknowledgementService();

  String? _pdfUrl;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Track download processing state for each grievance
  final Map<int, bool> _downloadProcessingStates = {};

  String? get pdfUrl => _pdfUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Check if a specific grievance is being downloaded
  bool isDownloadProcessing(int grievanceId) {
    return _downloadProcessingStates[grievanceId] ?? false;
  }
  
  // Set download processing state for a specific grievance
  void setDownloadProcessing(int grievanceId, bool isProcessing) {
    _downloadProcessingStates[grievanceId] = isProcessing;
    notifyListeners();
  }


 Future<void> fetchAcknowledgementPdf(int grievanceId) async {
  _isLoading = true;
  _pdfUrl = null;
  _errorMessage = null;
  notifyListeners();

  try {
    final result = await _service.downloadAcknowledgement(grievanceId);
    if (result['success'] == true && result['filePath'] != null) {
      _pdfUrl = result['filePath']; 
    } else {
      _errorMessage = result['message'] ?? 'Failed to fetch PDF';
    }
  } catch (e) {
    _errorMessage = e.toString();
  }

  _isLoading = false;
  notifyListeners();
}


  void resetAcknowledgementState() {
    _pdfUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
}
