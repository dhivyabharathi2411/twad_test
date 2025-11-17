import 'package:flutter/foundation.dart';
import '../../data/models/maintanance_work.dart' hide MaintenanceService;
import '../../data/models/maintenance_model.dart';
import '../../services/maintenance_service.dart';

class MaintenanceProvider extends ChangeNotifier {
  final MaintenanceService _service = MaintenanceService();

  bool _isLoading = false;
  List<MaintenanceWork> _maintenanceWorks = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<MaintenanceWork> get maintenanceWorks => _maintenanceWorks;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchMaintenanceWorks(MaintenanceModel maintenance) async {
  _isLoading = true;
  notifyListeners();

  try {
    final result = await _service.getMaintenanceWork(maintenance);

    if (result['success'] == true && result['data'] != null) {
      final List<dynamic> jsonList = result['data'];
      _maintenanceWorks = jsonList
          .map((item) => MaintenanceWork.fromJson(item))
          .toList();

      _errorMessage = null;
      return true;
    } else {
      _maintenanceWorks = [];
      _errorMessage = result['message'] ?? "Unknown error occurred";
      return false;
    }
  } catch (e) {
    _maintenanceWorks = [];
    _errorMessage = "Something went wrong. Please try again.";
    if (kDebugMode) {
    }
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


}
