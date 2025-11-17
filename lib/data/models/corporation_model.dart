class CorporationModel {
  final int id;
  final int districtId;
  final String corporationName;
  final String tamilText;
  final DateTime updatedDate;
  final int status;
  final int entryBy;
  final String? lgdCode; // Made nullable since API returns null
  final String districtName;


  CorporationModel({
    required this.id,
    required this.districtId,
    required this.corporationName,
    required this.tamilText,
    required this.updatedDate,
    required this.entryBy,
    required this.status,
    this.lgdCode, // Made optional since it can be null
    required this.districtName,
  });

  factory CorporationModel.fromJson(Map<String, dynamic> json) {
    return CorporationModel(
      id: json['id'],
      districtId: json['district_id'],
      corporationName: json['corporation_name'],
      status: json['status'],
      updatedDate: DateTime.parse(json['updated_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      lgdCode: json['lgd_code'],
      districtName: json['district_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_id': districtId,
      'district_name': districtName,
      'status': status,
      'updated_date':updatedDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'lgd_code': lgdCode,
      'corporation_name': corporationName,
    };
  }
}
