import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twad/data/models/block_list_model.dart';
import 'package:twad/data/models/district_list_model.dart';
import 'package:twad/data/models/grievance_type_model.dart';
import 'package:twad/data/models/village_list_model.dart';
import 'package:twad/data/models/habitation_list.dart';
import 'package:twad/data/models/sub_complaint_type_list_model.dart';

import '../../data/models/complaint_list_model.dart';

class NewGrievanceFormProvider extends ChangeNotifier {
  DistrictModel? selectedDistrict;
  GrievanceTypeModel? selectedGrievanceType;
  BlockModel? selectedBlock;
  VillageModel? selectedVillage;
  HabitationModel? selectedHabitation;
  ComplaintTypeModel? selectedComplaintType;
  ComplaintSubTypeModel? selectedSubComplaintType;
  String selectedOrganization = 'CORPORATION';
  String selectedZone = 'NORTH ZONE';
  List<PlatformFile> uploadedFiles = [];

  void setGrievanceType(GrievanceTypeModel? value) {
    selectedGrievanceType = value;
    selectedBlock = null;
    selectedVillage = null;
    selectedHabitation = null;
    notifyListeners();
  }

  void setDistrict(DistrictModel? value) {
    selectedDistrict = value;
    selectedBlock = null;
    selectedVillage = null;
    selectedHabitation = null;
    notifyListeners();
  }

  void setBlock(BlockModel? value) {
    selectedBlock = value;
    selectedVillage = null;
    selectedHabitation = null;
    notifyListeners();
  }

  void setVillage(VillageModel? value) {
    selectedVillage = value;
    selectedHabitation = null;
    notifyListeners();
  }

  void setHabitation(HabitationModel? value) {
    selectedHabitation = value;
    notifyListeners();
  }

  void setComplaintType(ComplaintTypeModel? value) {
    selectedComplaintType = value;
    notifyListeners();
  }

  void setSubComplaintType(ComplaintSubTypeModel? value) {
    selectedSubComplaintType = value;
    notifyListeners();
  }

  void setOrganization(String value) {
    selectedOrganization = value;
    notifyListeners();
  }

  void setZone(String value) {
    selectedZone = value;
    notifyListeners();
  }

  void addFiles(List<PlatformFile> files) {
    uploadedFiles.addAll(files);
    notifyListeners();
  }

  void removeFile(PlatformFile file) {
    uploadedFiles.remove(file);
    notifyListeners();
  }

  void clearForm() {
    selectedGrievanceType = null;
    selectedDistrict = null;
    selectedBlock = null;
    selectedVillage = null;
    selectedHabitation = null;
    selectedComplaintType = null;
    selectedSubComplaintType = null;
    selectedOrganization = 'CORPORATION';
    selectedZone = 'NORTH ZONE';
    uploadedFiles.clear();
    notifyListeners();
  }
}
