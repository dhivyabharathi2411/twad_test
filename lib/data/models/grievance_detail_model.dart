class GrievanceDetail {
  final int id;
  final DateTime complaintDateTime;

  /// List of process history items (typed model)
  final List<ProcessHistory> processHistory;
  final String complaintNo;
  final String complaintStatus;
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
  final String? publicFinalDescription;
  final String? holdReason;
  final String address;
  final String description;
  final String origin;
  final int reopen;
  final String reopenedRefNo;
  final int isReopen;
  final int reopenRefId;
  final String reopenComments;
  final DateTime? closedDate;
  final String isEligibleReopen;
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
  final int organisationId;
  final String? assignedToName;
  final String? originImage;
  final int resolutionOrganisationId;
  final bool isFwdTwad;
  final String twadEmployeeFileLink;
  final String? notes;

  final List<GrievanceDocument> documents;
  final List<String> fileLinks;

  GrievanceDetail({
    required this.id,
    required this.complaintDateTime,
    required this.complaintNo,
    required this.complaintStatus,
    required this.districtName,
    required this.complaintType,
    required this.complaintSubType,
    required this.grievanceType,
    required this.publicName,
    this.publicWhatsappNo,
    required this.publicContactNo,
    required this.publicEmailId,
    this.publicAddress,
    required this.complaintTimeFormatted,
    this.publicFinalDescription,
    this.holdReason,
    required this.address,
    required this.description,
    required this.origin,
    required this.reopen,
    required this.reopenedRefNo,
    required this.isReopen,
    required this.reopenRefId,
    required this.reopenComments,
    this.closedDate,
    required this.isEligibleReopen,
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
    required this.organisationId,
    required this.assignedToName,
    required this.documents,
    required this.fileLinks,
    this.originImage,
    this.notes,
    this.resolutionOrganisationId = 0,
    this.isFwdTwad = false,
    this.twadEmployeeFileLink = '',
    required this.processHistory,
  });

  factory GrievanceDetail.fromJson(Map<String, dynamic> json) {
    String dateOnly = (json['complaint_date'] ?? '')
        .toString()
        .split('T')
        .first;
    String timeOnly = (json['complaint_time'] ?? '00:00:00')
        .toString()
        .split('.')
        .first;
    DateTime combinedDateTime = DateTime.parse('$dateOnly $timeOnly');

    DateTime? parsedClosedDate;
    if (json['closed_date'] != null &&
        json['closed_date'].toString().isNotEmpty) {
      parsedClosedDate = DateTime.tryParse(json['closed_date']);
    }

    var documentsJson =
        (json['grievance_document_list'] as List<dynamic>? ?? []);

    // Parse grievance_process_history as List<ProcessHistory>
    List<ProcessHistory> processHistoryList = [];
    if (json['grievance_process_history'] != null &&
        json['grievance_process_history'] is List) {
      processHistoryList = (json['grievance_process_history'] as List)
          .where((e) => e is Map<String, dynamic>)
          .map((e) => ProcessHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // parse resolution organisation id safely
    int parsedResolutionOrgId = 0;
    if (json['resolution_organisation_id'] != null) {
      parsedResolutionOrgId =
          int.tryParse(json['resolution_organisation_id'].toString()) ?? 0;
    }

    // parse is_fwd_twad safely
    bool parsedIsFwdTwad = false;
    final rawIsFwd = json['is_fwd_twad'];
    if (rawIsFwd is bool) {
      parsedIsFwdTwad = rawIsFwd;
    } else if (rawIsFwd != null) {
      parsedIsFwdTwad = rawIsFwd.toString().toLowerCase() == 'true';
    }

    final parsedTwadEmployeeFileLink = (json['twad_employee_file_link'] ?? '')
        .toString();

    return GrievanceDetail(
      id: json['id'],
      complaintDateTime: combinedDateTime,
      complaintNo: json['complaint_no'],
      complaintStatus: json['complaint_status'],
      districtName: json['district_name'],
      complaintType: json['complaint_type'],
      complaintSubType: json['complaint_sub_type'],
      grievanceType: json['grievance_type'],
      publicName: json['public_name'],
      publicWhatsappNo: json['public_whatsappno'],
      publicContactNo: json['public_contactno'],
      publicEmailId: json['public_emailid'],
      publicAddress: json['public_address'],
      complaintTimeFormatted: json['complaint_time_formatted'],
      publicFinalDescription: json['public_final_description'],
      holdReason: json['hold_reason'],
      address: json['address'],
      description: json['description'],
      origin: json['origin'],
      reopen: json['reopen'],
      reopenedRefNo: json['reopened_ref_no'],
      isReopen: json['is_reopen'],
      reopenRefId: json['reopen_ref_id'],
      reopenComments: json['reopen_comments'],
      closedDate: parsedClosedDate,
      isEligibleReopen: json['is_eligible_reopen'],
      organisationName: json['organisation_name'],
      zoneName: json['zone_name'],
      zoneWardName: json['zone_ward_name'],
      municipalityName: json['municipality_name'],
      municipalityWardName: json['municipality_ward_name'],
      townPanchayatName: json['town_panchayat_name'],
      townPanchayatWardName: json['town_panchayat_ward_name'],
      divisionName: json['division_name'],
      blockName: json['block_name'],
      villageName: json['village_name'],
      habitationName: json['habitation_name'],
      organisationId: json['organisation_id'],
      assignedToName: json['assigned_to_name'],
      notes: json['notes'],
      resolutionOrganisationId: parsedResolutionOrgId,
      isFwdTwad: parsedIsFwdTwad,
      twadEmployeeFileLink: parsedTwadEmployeeFileLink,
      documents: documentsJson
          .map((doc) => GrievanceDocument.fromJson(doc))
          .toList(),
      fileLinks: documentsJson
          .map(
            (doc) => (doc['file_link'] ?? doc['employee_file_link'] ?? '')
                .toString(),
          )
          .toList(),
      originImage: json['employee_file_link'],
      processHistory: processHistoryList,
    );
  }
}

// Model for grievance_process_history
class ProcessHistory {
  final int id;
  final int grievanceId;
  final String? date;
  final String? description;
  final String? createdDate;
  final int? entryBy;
  final String? entryByType;
  final String? viewBy;
  final String? type;
  final String? notes;
  final String? updatedBy;
  final String? officialDetails;
  final String? officialDesignation;
  final String? dueDate;
  final String? fileName;

  ProcessHistory({
    required this.id,
    required this.grievanceId,
    this.date,
    this.description,
    this.createdDate,
    this.entryBy,
    this.entryByType,
    this.viewBy,
    this.type,
    this.notes,
    this.updatedBy,
    this.officialDetails,
    this.officialDesignation,
    this.dueDate,
    this.fileName,
  });

  factory ProcessHistory.fromJson(Map<String, dynamic> json) {
    return ProcessHistory(
      id: json['id'],
      grievanceId: json['grievance_id'],
      date: json['date'],
      description: json['description'],
      createdDate: json['created_date'],
      entryBy: json['entry_by'],
      entryByType: json['entry_by_type'],
      viewBy: json['view_by'],
      type: json['type'],
      notes: json['notes'],
      updatedBy: json['updated_by'],
      officialDetails: json['official_details'],
      officialDesignation: json['official_designation'],
      dueDate: json['due_date'],
      fileName: json['file_name'],
    );
  }
}

class GrievanceDocument {
  final int id;
  final int grievanceId;
  final String fileLink;
  final DateTime createdDate;

  GrievanceDocument({
    required this.id,
    required this.grievanceId,
    required this.fileLink,
    required this.createdDate,
  });

  factory GrievanceDocument.fromJson(Map<String, dynamic> json) {
    return GrievanceDocument(
      id: json['id'],
      grievanceId: json['grievance_id'],
      fileLink: (json['employee_file_link'] ?? json['file_link'] ?? '')
          .toString(),
      createdDate:
          json['created_date'] != null &&
              json['created_date'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
