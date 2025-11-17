class TownPanchayatModel {
  final int id;
  final int districtId;
  final String townPanchayatName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String districtName;

  TownPanchayatModel({
    required this.id,
    required this.districtId,
    required this.townPanchayatName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.districtName,
  });

  factory TownPanchayatModel.fromJson(Map<String, dynamic> json) {
    return TownPanchayatModel(
      id: json['id'] ?? 0,
      districtId: json['district_id'] ?? 0,
      townPanchayatName: json['town_panchayat_name'] ?? '',
      status: json['status'] ?? 0,
      createdDate: DateTime.tryParse(json['created_date'] ?? '') ?? DateTime.now(),
      entryBy: json['entry_by'] ?? 0,
      tamilText: json['tamil_text'] ?? '',
      districtName: json['district_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_id': districtId,
      'town_panchayat_name': townPanchayatName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'district_name': districtName,
    };
  }
}
