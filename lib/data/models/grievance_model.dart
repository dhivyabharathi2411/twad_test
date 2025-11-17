import 'grievance_status.dart';

class GrievanceModel {
  final int id;
  final DateTime complaintDateTime;
  final String complaintNo;
  final GrievanceStatus complaintStatus;
  final String districtName;
  final String complaintType;
  final String complaintSubType;
  final String grievanceType;
  final String publicName;
  final String? publicWhatsappNo;
  final String publicContactNo;
  final String publicEmailId;
  final String? publicAddress;
  final String complaintTimeFormatted;
  final String originImage;
  final int reopen;
  final String reopenedRefNo;
  final int isReopen;
  final int reopenRefId;
  final String reopenComments;
  final String organisationName;
  final String zoneName;
  final String zoneWardName;
  final String municipalityName;
  final String municipalityWardName;
  final String townPanchayatName;
  final String townPanchayatWardName;
  final String divisionName;
  final String blockName;
  final String villageName;
  final String habitationName;

  GrievanceModel({
    required this.id,
    required this.complaintDateTime,
    required this.complaintNo,
    required this.complaintStatus,
    required this.districtName,
    required this.complaintType,
    required this.complaintSubType,
    required this.grievanceType,
    required this.publicName,
    required this.publicWhatsappNo,
    required this.publicContactNo,
    required this.publicEmailId,
    required this.publicAddress,
    required this.complaintTimeFormatted,
    required this.originImage,
    required this.reopen,
    required this.reopenedRefNo,
    required this.isReopen,
    required this.reopenRefId,
    required this.reopenComments,
    required this.organisationName,
    required this.zoneName,
    required this.zoneWardName,
    required this.municipalityName,
    required this.municipalityWardName,
    required this.townPanchayatName,
    required this.townPanchayatWardName,
    required this.divisionName,
    required this.blockName,
    required this.villageName,
    required this.habitationName,
  });

  factory GrievanceModel.fromJson(Map<String, dynamic> json) {
    String dateOnly = json['complaint_date']?.split('T').first ?? '';
    String timeOnly = json['complaint_time'] ?? '00:00:00';
    DateTime combinedDateTime = DateTime.parse("${dateOnly}T$timeOnly");

    return GrievanceModel(
      id: json['id'],
      complaintDateTime: combinedDateTime,
      complaintNo: json['complaint_no'] ?? '',
      complaintStatus: parseGrievanceStatus(json['complaint_status']),
      districtName: json['district_name'] ?? '',
      complaintType: json['complaint_type'] ?? '',
      complaintSubType: json['complaint_sub_type'] ?? '',
      grievanceType: json['grievance_type'] ?? '',
      publicName: json['public_name'] ?? '',
      publicWhatsappNo: json['public_whatsappno'],
      publicContactNo: json['public_contactno'] ?? '',
      publicEmailId: json['public_emailid'] ?? '',
      publicAddress: json['public_address'],
      complaintTimeFormatted: json['complaint_time_formatted'] ?? '',
      originImage: json['origin_image'] ?? '',
      reopen: json['reopen'] ?? 0,
      reopenedRefNo: json['reopened_ref_no'] ?? '',
      isReopen: json['is_reopen'] ?? 0,
      reopenRefId: json['reopen_ref_id'] ?? 0,
      reopenComments: json['reopen_comments'] ?? '',
      organisationName: json['organisation_name'] ?? '',
      zoneName: json['zone_name'] ?? '',
      zoneWardName: json['zone_ward_name'] ?? '',
      municipalityName: json['municipality_name'] ?? '',
      municipalityWardName: json['municipality_ward_name'] ?? '',
      townPanchayatName: json['town_panchayat_name'] ?? '',
      townPanchayatWardName: json['town_panchayat_ward_name'] ?? '',
      divisionName: json['division_name'] ?? '',
      blockName: json['block_name'] ?? '',
      villageName: json['village_name'] ?? '',
      habitationName: json['habitation_name'] ?? '',
    );
  }
}
