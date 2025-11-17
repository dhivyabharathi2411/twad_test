class GrievanceTypeModel {
  final int id;
  final String grievanceType;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String assignType; 

  GrievanceTypeModel({
    required this.id,
    required this.grievanceType,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.assignType, 
  });

  factory GrievanceTypeModel.fromJson(Map<String, dynamic> json) {
    return GrievanceTypeModel(
      id: json['id'],
      grievanceType: json['grievance_type'], 
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      assignType: json['assign_type'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_type': grievanceType,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'assign_type': assignType,
    };
  }
}
