class MaintenanceModel {
  final int organisationId;
  final String districtId;
  final String blockId;
  final String villageId;
  final String habitationId;
  final String complaintTypeId;
  final String complaintSubTypeId;
  final int zoneId;
  final int zoneWardId;
  final int municipalityId;
  final int municipalityWardId;
  final int townPanchayatId;
  final int townPanchayatWardId;
  final int divisionId;

  MaintenanceModel({
    required this.organisationId,
    required this.districtId,
    required this.blockId,
    required this.villageId,
    required this.habitationId,
    required this.complaintTypeId,
    required this.complaintSubTypeId,
    required this.zoneId,
    required this.zoneWardId,
    required this.municipalityId,
    required this.municipalityWardId,
    required this.townPanchayatId,
    required this.townPanchayatWardId,
    required this.divisionId,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      organisationId: json['organisation_id'],
      districtId: json['district_id'].toString(),
      blockId: json['block_id'].toString(),
      villageId: json['village_id'].toString(),
      habitationId: json['habitation_id'].toString(),
      complaintTypeId: json['complaint_type_id'].toString(),
      complaintSubTypeId: json['complaint_sub_type_id'].toString(),
      zoneId: json['zone_id'],
      zoneWardId: json['zone_ward_id'],
      municipalityId: json['municipality_id'],
      municipalityWardId: json['municipality_ward_id'],
      townPanchayatId: json['town_panchayat_id'],
      townPanchayatWardId: json['town_panchayat_ward_id'],
      divisionId: json['division_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organisation_id": organisationId,
      "district_id": districtId,
      "block_id": blockId,
      "village_id": villageId,
      "habitation_id": habitationId,
      "complaint_type_id": complaintTypeId,
      "complaint_sub_type_id": complaintSubTypeId,
      "zone_id": zoneId,
      "zone_ward_id": zoneWardId,
      "municipality_id": municipalityId,
      "municipality_ward_id": municipalityWardId,
      "town_panchayat_id": townPanchayatId,
      "town_panchayat_ward_id": townPanchayatWardId,
      "division_id": divisionId,
    };
  }
}
