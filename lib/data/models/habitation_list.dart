class HabitationModel {
  final int id;
  final int villageId;
  final String habitationName;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String dCode;
  final String vCode;
  final String bCode;
  final String habitationCode;
  final String villageName;
  final String blockName;
  final String districtName;
  final int districtId;
  final int blockId;

  HabitationModel({
    required this.id,
    required this.villageId,
    required this.habitationName,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.dCode,
    required this.vCode,
    required this.bCode,
    required this.habitationCode,
    required this.villageName,
    required this.blockName,
    required this.districtName,
    required this.districtId,
    required this.blockId,
  });

  factory HabitationModel.fromJson(Map<String, dynamic> json) {
    return HabitationModel(
      id: json['id'],
      villageId: json['village_id'],
      habitationName: json['habitation_name'],
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      dCode: json['d_code'],
      vCode: json['v_code'],
      bCode: json['b_code'],
      habitationCode: json['habitation_code'],
      villageName: json['village_name'],
      blockName: json['block_name'],
      districtName: json['district_name'],
      districtId: json['district_id'],
      blockId: json['block_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_id': villageId,
      'habitation_name': habitationName,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'd_code': dCode,
      'v_code': vCode,
      'b_code': bCode,
      'habitation_code': habitationCode,
      'village_name': villageName,
      'block_name': blockName,
      'district_name': districtName,
      'district_id': districtId,
      'block_id': blockId,
    };
  }
}
