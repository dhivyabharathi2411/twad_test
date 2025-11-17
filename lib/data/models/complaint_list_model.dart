class ComplaintTypeModel {
  final int id;
  final String complaintType;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String durationType;

  ComplaintTypeModel({
    required this.id,
    required this.complaintType,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.durationType,
  });

  factory ComplaintTypeModel.fromJson(Map<String, dynamic> json) {
    return ComplaintTypeModel(
      id: json['id'],
      complaintType: json['complaint_type'],
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      durationType: json['duration_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_type': complaintType,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'duration_type': durationType,
    };
  }
}
