class BlockModel {
  final int id;
  final int districtId;
  final String blockName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String blockCode;
  final String districtName;

  BlockModel({
    required this.id,
    required this.districtId,
    required this.blockName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.blockCode,
    required this.districtName,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'],
      districtId: json['district_id'],
      blockName: json['block_name'],
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      blockCode: json['block_code'],
      districtName: json['district_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_id': districtId,
      'block_name': blockName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'block_code': blockCode,
      'district_name': districtName,
    };
  }
}
