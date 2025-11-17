import 'package:flutter/material.dart';
import 'package:twad/data/models/corporation_model.dart';
import '../../data/models/block_list_model.dart';
import '../../data/models/complaint_list_model.dart';
import '../../data/models/district_list_model.dart';
import '../../data/models/grievance_type_model.dart';
import '../../data/models/habitation_list.dart';
import '../../data/models/municipality_model.dart';
import '../../data/models/municipality_ward_model.dart';
import '../../data/models/sub_complaint_type_list_model.dart';
import '../../data/models/town_panchayat_model.dart';
import '../../data/models/town_panchayat_ward_model.dart';
import '../../data/models/village_list_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/zone_ward_model.dart';
import '../../services/grievance_service.dart';

class MasterListProvider extends ChangeNotifier {
  final GrievanceService _service = GrievanceService();

  List<GrievanceTypeModel> _grievanceTypes = [];
  List<DistrictModel> _districts = [];
  List<BlockModel> _blocks = [];
  List<VillageModel> _villages = [];
  List<HabitationModel> _habitations = [];
  List<ComplaintTypeModel> _complaintTypes = [];
  List<ComplaintSubTypeModel> _subComplaintTypes = [];
  List<ZoneModel> _zones = [];
  List<ZoneWardModel> _zoneWards = [];
  List<MunicipalityModel> _municipalities = [];
  List<MunicipalityWardModel> _municipalityWards = [];
  List<TownPanchayatModel> _townPanchayats = [];
  List<TownPanchayatWardModel> _townPanchayatWards = [];
  List<CorporationModel> _corporations = [];

  List<GrievanceTypeModel> get grievanceTypes => _grievanceTypes;
  List<DistrictModel> get districts => _districts;
  List<BlockModel> get blocks => _blocks;
  List<VillageModel> get villages => _villages;
  List<HabitationModel> get habitations => _habitations;
  List<ComplaintTypeModel> get complaintTypes => _complaintTypes;
  List<ComplaintSubTypeModel> get subComplaintTypes => _subComplaintTypes;
  List<ZoneModel> get zones => _zones;
  List<ZoneWardModel> get zoneWards => _zoneWards;
  List<MunicipalityModel> get municipalities => _municipalities;
  List<MunicipalityWardModel> get municipalityWards => _municipalityWards;
  List<TownPanchayatModel> get townPanchayats => _townPanchayats;
  List<TownPanchayatWardModel> get townPanchayatWards => _townPanchayatWards;
  List<CorporationModel> get corporations => _corporations;

  Future<void> fetchGrievanceTypes() async {
    try {
      final data = await _service.getGrievanceTypes();
      _grievanceTypes = data.map<GrievanceTypeModel>((e) => GrievanceTypeModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _grievanceTypes = [];
      notifyListeners();
    }
  }

  Future<void> fetchDistricts() async {
    try {
      final data = await _service.getDistrictList();
      _districts = data.map<DistrictModel>((e) => DistrictModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _districts = [];
      notifyListeners();
    }
  }

  Future<void> fetchBlocks(int districtId) async {
    try {
      final data = await _service.getBlockByDistrict(districtId);
      _blocks = data.map<BlockModel>((e) => BlockModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _blocks = [];
      notifyListeners();
    }
  }

  Future<void> fetchVillages(int blockId) async {
    try {
      final data = await _service.getVillageByBlock(blockId);
      _villages = data.map<VillageModel>((e) => VillageModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _villages = [];
      notifyListeners();
    }
  }

  Future<void> fetchHabitations(int villageId) async {
    try {
      final data = await _service.getHabitationByVillage(villageId);
      _habitations = data.map<HabitationModel>((e) => HabitationModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _habitations = [];
      notifyListeners();
    }
  }

  Future<void> fetchComplaintTypes() async {
    try {
      final data = await _service.getComplaintTypeList();
      _complaintTypes = data.map<ComplaintTypeModel>((e) => ComplaintTypeModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _complaintTypes = [];
      notifyListeners();
    }
  }

  Future<void> fetchSubComplaintTypes() async {
    try {
      final data = await _service.getSubComplaintTypeByComplaint();
      _subComplaintTypes = data.map<ComplaintSubTypeModel>((e) => ComplaintSubTypeModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _subComplaintTypes = [];
      notifyListeners();
    }
  }
  Future<void> fetchZones(int districtId,int corporationId) async {
    try {
      final data = await _service.getZoneByDistrict(districtId,corporationId);
      _zones = data.map<ZoneModel>((e) => ZoneModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _zones = [];
      notifyListeners();
    }
  }

  Future<void> fetchZoneWards(int zoneId,int districtId,int corporationId) async {
    try {
      final data = await _service.getWardByZone(zoneId,districtId,corporationId);
      _zoneWards = data.map<ZoneWardModel>((e) => ZoneWardModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _zoneWards = [];
      notifyListeners();
    }
  }

  Future<void> fetchMunicipalities(int districtId) async {
    try {
      final data = await _service.getMunicipalityByDistrict(districtId);
      _municipalities = data.map<MunicipalityModel>((e) => MunicipalityModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _municipalities = [];
      notifyListeners();
    }
  }

  Future<void> fetchMunicipalityWards(int municipalityId) async {
    try {
      final data = await _service.getWardByMunicipality(municipalityId);
      _municipalityWards = data.map<MunicipalityWardModel>((e) => MunicipalityWardModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _municipalityWards = [];
      notifyListeners();
    }
  }

  Future<void> fetchTownPanchayats(int districtId) async {
    try {
      final data = await _service.getTownPanchayatByDistrict(districtId);
      _townPanchayats = data.map<TownPanchayatModel>((e) => TownPanchayatModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _townPanchayats = [];
      notifyListeners();
    }
  }

  Future<void> fetchTownPanchayatWards(int townPanchayatId) async {
    try {
      final data = await _service.getWardByTownPanchayat(townPanchayatId);
      _townPanchayatWards = data.map<TownPanchayatWardModel>((e) => TownPanchayatWardModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _townPanchayatWards = [];
      notifyListeners();
    }
  }
  Future<void> fetchCorporations(int districtId) async {
    try {
      final response = await _service.getCorporationByDistrict(districtId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List;
        _corporations = data.map<CorporationModel>((e) => CorporationModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _corporations = [];
      }
      notifyListeners();
    } catch (e) {
      _corporations = [];
      notifyListeners();
    }
  }


  void clearDropdowns() {
    _blocks = [];
    _villages = [];
    _habitations = [];
    _zones = [];
    _zoneWards = [];
    _municipalities = [];
    _municipalityWards = [];
    _townPanchayats = [];
    _townPanchayatWards = [];
    _corporations = [];
    notifyListeners();
  }
}
