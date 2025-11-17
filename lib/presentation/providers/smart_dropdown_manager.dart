import 'package:flutter/material.dart';
import '../../data/models/block_list_model.dart';
import '../../data/models/corporation_model.dart';
import '../../data/models/district_list_model.dart';
import '../../data/models/habitation_list.dart';
import '../../data/models/municipality_model.dart';
import '../../data/models/municipality_ward_model.dart';
import '../../data/models/town_panchayat_model.dart';
import '../../data/models/town_panchayat_ward_model.dart';
import '../../data/models/village_list_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/zone_ward_model.dart';
import '../../presentation/providers/master_list_provider.dart';

/// Smart Dropdown Manager - Clean Architecture Implementation
/// 
/// This class manages the cascading dropdown logic for grievance creation
/// following clean architecture principles:
/// 
/// 1. **Single Responsibility**: Only manages dropdown dependencies
/// 2. **Dependency Inversion**: Depends on abstractions, not concrete implementations
/// 3. **Open/Closed**: Easy to extend without modifying existing code
/// 4. **Interface Segregation**: Clean interfaces for different dropdown types
/// 5. **Dependency Injection**: MasterListProvider injected, not created internally
class SmartDropdownManager extends ChangeNotifier {
  final MasterListProvider _masterProvider;
  
  // Current selections
  DistrictModel? _selectedDistrict;
  CorporationModel? _selectedCorporation;
  String? _selectedOrganization;
  
  // Cached data to prevent unnecessary API calls
  final Map<int, List<BlockModel>> _cachedBlocks = {};
  final Map<int, List<ZoneModel>> _cachedZones = {};
  final Map<int, List<MunicipalityModel>> _cachedMunicipalities = {};
  final Map<int, List<TownPanchayatModel>> _cachedTownPanchayats = {};
  
  // Dropdown states
  bool _isLoading = false;
  String? _error;
  
  SmartDropdownManager(this._masterProvider);
  
  // Getters
  DistrictModel? get selectedDistrict => _selectedDistrict;
  String? get selectedOrganization => _selectedOrganization;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Set district selection - NO API calls made here
  void selectDistrict(DistrictModel? district) {
    _selectedDistrict = district;
    _selectedOrganization = null;
    
    // Clear dependent dropdowns
    _clearDependentDropdowns();
    
    // Reset caches for new district
    if (district != null) {
      _clearCachedData(district.id);
    }
    
    _setError(null);
    notifyListeners();
  }
  
  /// Set organization selection - API calls made based on organization type
  Future<void> selectOrganization(String? organization) async {
    _selectedOrganization = organization;
    
    if (_selectedDistrict == null || organization == null) {
      _clearDependentDropdowns();
      notifyListeners();
      return;
    }
    
    await _fetchOrganizationSpecificData(organization);
  }
  
  /// Fetch data based on organization type - ONLY when needed
  Future<void> _fetchOrganizationSpecificData(String organization) async {
    if (_selectedDistrict == null) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final districtId = _selectedDistrict!.id;
      final corporationId = _selectedCorporation!.id;
      
      switch (organization.toUpperCase()) {
        case 'CORPORATION':
          // Corporation needs zones and zone wards
          await _fetchZonesIfNeeded(districtId, corporationId);
          break;
          
        case 'MUNICIPALITY':
          // Municipality needs municipalities and municipality wards
          await _fetchMunicipalitiesIfNeeded(districtId);
          break;
          
        case 'TOWN PANCHAYAT':
          // Town Panchayat needs town panchayats and town panchayat wards
          await _fetchTownPanchayatsIfNeeded(districtId);
          break;
          
        case 'PANCHAYAT':
          // Panchayat needs blocks, villages, and habitations
          await _fetchPanchayatDataIfNeeded(districtId);
          break;
          
        default:
          // Unknown organization type - clear all
          _clearDependentDropdowns();
      }
    } catch (e) {
      _setError('Failed to fetch organization data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Fetch zones only if not cached
  Future<void> _fetchZonesIfNeeded(int districtId, int corporationId) async {
    if (!_cachedZones.containsKey(districtId)) {
      await _masterProvider.fetchZones(districtId,corporationId);
      _cachedZones[districtId] = _masterProvider.zones;
    }
  }
  
  /// Fetch municipalities only if not cached
  Future<void> _fetchMunicipalitiesIfNeeded(int districtId) async {
    if (!_cachedMunicipalities.containsKey(districtId)) {
      await _masterProvider.fetchMunicipalities(districtId);
      _cachedMunicipalities[districtId] = _masterProvider.municipalities;
    }
  }
  
  /// Fetch town panchayats only if not cached
  Future<void> _fetchTownPanchayatsIfNeeded(int districtId) async {
    if (!_cachedTownPanchayats.containsKey(districtId)) {
      await _masterProvider.fetchTownPanchayats(districtId);
      _cachedTownPanchayats[districtId] = _masterProvider.townPanchayats;
    }
  }
  
  /// Fetch panchayat data only if not cached
  Future<void> _fetchPanchayatDataIfNeeded(int districtId) async {
    if (!_cachedBlocks.containsKey(districtId)) {
      await _masterProvider.fetchBlocks(districtId);
      _cachedBlocks[districtId] = _masterProvider.blocks;
    }
  }
  
  /// Fetch dependent data when a parent selection changes
  Future<void> fetchDependentData<T>({
    required int parentId,
    required Future<void> Function(int) fetchFunction,
    required Map<int, List<T>> cache,
    required List<T> Function() getter,
  }) async {
    if (!cache.containsKey(parentId)) {
      await fetchFunction(parentId);
      cache[parentId] = getter();
    }
  }
  
  /// Clear dependent dropdowns
  void _clearDependentDropdowns() {
    _masterProvider.clearDropdowns();
  }
  
  /// Clear cached data for a specific district
  void _clearCachedData(int districtId) {
    _cachedBlocks.remove(districtId);
    _cachedZones.remove(districtId);
    _cachedMunicipalities.remove(districtId);
    _cachedTownPanchayats.remove(districtId);
  }
  
  /// Clear all cached data
  void clearAllCaches() {
    _cachedBlocks.clear();
    _cachedZones.clear();
    _cachedMunicipalities.clear();
    _cachedTownPanchayats.clear();
  }
  
  /// Reset all selections
  void reset() {
    _selectedDistrict = null;
    _selectedOrganization = null;
    clearAllCaches();
    _clearDependentDropdowns();
    _setError(null);
    notifyListeners();
  }
  
  /// Get available organizations based on district
  List<String> getAvailableOrganizations() {
    if (_selectedDistrict == null) return [];
    
    // All organizations are available for any district
    return ['CORPORATION', 'MUNICIPALITY', 'TOWN PANCHAYAT', 'PANCHAYAT'];
  }
  
  /// Check if data is available for a specific organization
  bool isDataAvailable(String organization) {
    if (_selectedDistrict == null) return false;
    
    final districtId = _selectedDistrict!.id;
    
    switch (organization.toUpperCase()) {
      case 'CORPORATION':
        return _cachedZones.containsKey(districtId);
      case 'MUNICIPALITY':
        return _cachedMunicipalities.containsKey(districtId);
      case 'TOWN PANCHAYAT':
        return _cachedTownPanchayats.containsKey(districtId);
      case 'PANCHAYAT':
        return _cachedBlocks.containsKey(districtId);
      default:
        return false;
    }
  }
  
  /// Get loading state for specific organization
  bool isLoadingForOrganization(String organization) {
    return _isLoading && _selectedOrganization == organization;
  }
  
  // Private setters
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  @override
  void dispose() {
    clearAllCaches();
    super.dispose();
  }
}
