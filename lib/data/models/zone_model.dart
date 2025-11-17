class ZoneModel {
  final int id;
  final int districtId;
  final String zoneName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String districtName;

  ZoneModel({
    required this.id,
    required this.districtId,
    required this.zoneName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.districtName,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] ?? 0,
      districtId: json['district_id'] ?? 0,
      zoneName: json['zone_name'] ?? '',
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
      'zone_name': zoneName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'district_name': districtName,
    };
  }
}
