class MunicipalityWardModel {
  final int id;
  final int municipalityId;
  final String municipalityWardName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String districtName;
  final String municipalityName;
  final int districtId;

  MunicipalityWardModel({
    required this.id,
    required this.municipalityId,
    required this.municipalityWardName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.districtName,
    required this.municipalityName,
    required this.districtId,
  });

  factory MunicipalityWardModel.fromJson(Map<String, dynamic> json) {
    return MunicipalityWardModel(
      id: json['id'] ?? 0,
      municipalityId: json['municipality_id'] ?? 0,
      municipalityWardName: json['municipality_ward_name'] ?? '',
      status: json['status'] ?? 0,
      createdDate: DateTime.tryParse(json['created_date'] ?? '') ?? DateTime.now(),
      entryBy: json['entry_by'] ?? 0,
      tamilText: json['tamil_text'] ?? '',
      districtName: json['district_name'] ?? '',
      municipalityName: json['municipality_name'] ?? '',
      districtId: json['district_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'municipality_id': municipalityId,
      'municipality_ward_name': municipalityWardName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'district_name': districtName,
      'municipality_name': municipalityName,
      'district_id': districtId,
    };
  }
}
