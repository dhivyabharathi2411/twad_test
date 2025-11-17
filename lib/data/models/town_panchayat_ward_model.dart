class TownPanchayatWardModel {
  final int id;
  final int townPanchayatId;
  final String townPanchayatWardName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String districtName;
  final String townPanchayatName;
  final int districtId;

  TownPanchayatWardModel({
    required this.id,
    required this.townPanchayatId,
    required this.townPanchayatWardName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.districtName,
    required this.townPanchayatName,
    required this.districtId,
  });

  factory TownPanchayatWardModel.fromJson(Map<String, dynamic> json) {
    return TownPanchayatWardModel(
      id: json['id'] ?? 0,
      townPanchayatId: json['town_panchayat_id'] ?? 0,
      townPanchayatWardName: json['town_panchayat_ward_name'] ?? '',
      status: json['status'] ?? 0,
      createdDate: DateTime.tryParse(json['created_date'] ?? '') ?? DateTime.now(),
      entryBy: json['entry_by'] ?? 0,
      tamilText: json['tamil_text'] ?? '',
      districtName: json['district_name'] ?? '',
      townPanchayatName: json['town_panchayat_name'] ?? '',
      districtId: json['district_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'town_panchayat_id': townPanchayatId,
      'town_panchayat_ward_name': townPanchayatWardName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'district_name': districtName,
      'town_panchayat_name': townPanchayatName,
      'district_id': districtId,
    };
  }
}
