import 'grievance_status.dart';

class RecentGrievanceModel {
  final int id;
  final String complaintNo;
  final GrievanceStatus status;
  final String title;
  final DateTime complaintDate;
  final DateTime complaintTime;
  final String complaintTimeFormatted;
  final String districtName;
  final String complaintType;

  RecentGrievanceModel({
    required this.id,
    required this.complaintNo,
    required this.status,
    required this.title,
    required this.complaintDate,
    required this.complaintTime,
    required this.complaintTimeFormatted,
    required this.districtName,
    required this.complaintType,
  });

factory RecentGrievanceModel.fromJson(Map<String, dynamic> json) {
  String dateOnly = json['complaint_date'].split('T').first;

  return RecentGrievanceModel(
    id: json['id'],
    complaintNo: json['complaint_no'],
    status: parseGrievanceStatus(json['complaint_status']),
    title: json['complaint_sub_type'] ?? json['complaint_type'],
    complaintDate: DateTime.parse(json['complaint_date']),
    complaintTime: DateTime.parse("$dateOnly" "T${json['complaint_time']}"),
    complaintTimeFormatted: json['complaint_time_formatted'],
    districtName: json['district_name'],
    complaintType: json['complaint_type'],
  );
}

}
