class VillageModel {
  final int id;
  final int blockId;
  final String villageName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String villageCode;
  final String districtName;
  final String blockName;
  final int districtId;

  VillageModel({
    required this.id,
    required this.blockId,
    required this.villageName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.villageCode,
    required this.districtName,
    required this.blockName,
    required this.districtId,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'],
      blockId: json['block_id'],
      villageName: json['village_name'],
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      villageCode: json['village_code'],
      districtName: json['district_name'],
      blockName: json['block_name'],
      districtId: json['district_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block_id': blockId,
      'village_name': villageName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'village_code': villageCode,
      'district_name': districtName,
      'block_name': blockName,
      'district_id': districtId,
    };
  }
}
