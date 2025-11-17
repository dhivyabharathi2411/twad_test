class DistrictModel {
  final int id;
  final String districtName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final bool? isCorporation;
  final String? corporationName;
  final String? corporationNameTamil;
  final String? districtCode;

  DistrictModel({
    required this.id,
    required this.districtName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    this.isCorporation,
    this.corporationName,
    this.corporationNameTamil,
    this.districtCode,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'],
      districtName: json['district_name'],
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      isCorporation: json['is_corporation'] == null
          ? null
          : json['is_corporation'] == 1,
      corporationName: json['corporation_name'],
      corporationNameTamil: json['corporation_name_tamil'],
      districtCode: json['district_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_name': districtName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'is_corporation': isCorporation == null
          ? null
          : (isCorporation! ? 1 : 0),
      'corporation_name': corporationName,
      'corporation_name_tamil': corporationNameTamil,
      'district_code': districtCode,
    };
  }
}
