class ZoneWardModel {
  final int id;
  final int zoneId;
  final String zoneWardName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String districtName;
  final String zoneName;
  final int districtId;

  ZoneWardModel({
    required this.id,
    required this.zoneId,
    required this.zoneWardName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.districtName,
    required this.zoneName,
    required this.districtId,
  });

  factory ZoneWardModel.fromJson(Map<String, dynamic> json) {
    return ZoneWardModel(
      id: json['id'] ?? 0,
      zoneId: json['zone_id'] ?? 0,
      zoneWardName: json['zone_ward_name'] ?? '',
      status: json['status'] ?? 0,
      createdDate: DateTime.tryParse(json['created_date'] ?? '') ?? DateTime.now(),
      entryBy: json['entry_by'] ?? 0,
      tamilText: json['tamil_text'] ?? '',
      districtName: json['district_name'] ?? '',
      zoneName: json['zone_name'] ?? '',
      districtId: json['district_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zone_id': zoneId,
      'zone_ward_name': zoneWardName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'district_name': districtName,
      'zone_name': zoneName,
      'district_id': districtId,
    };
  }
}
