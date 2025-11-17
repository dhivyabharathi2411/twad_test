class NewGrievanceRequest {
  final int operatorId;
  final int isEditPublicDetails;
  final int publicId;
  final String publicName;
  final String publicContactNo;
  final String publicEmailId;
  final String publicAddress;
  final String origin;
  final String priority;
  final String typeId;
  final int districtId;
  final int blockId;
  final int villageId;
  final int habitationId;
  final int streetId;
  final String address;
  final int complaintTypeId;
  final int complaintSubtypeId;
  final String description;
  final int entryBy;
  final String entryByType;
  final List<Document> documentList;
  final int organisationId;
  final int zoneId;
  final int zoneWardId;
  final int municipalityId;
  final int municipalityWardId;
  final int townPanchayatId;
  final int townPanchayatWardId;
  final int divisionId;

  NewGrievanceRequest({
    required this.operatorId,
    required this.isEditPublicDetails,
    required this.publicId,
    required this.publicName,
    required this.publicContactNo,
    required this.publicEmailId,
    required this.publicAddress,
    required this.origin,
    required this.priority,
    required this.typeId,
    required this.districtId,
    required this.blockId,
    required this.villageId,
    required this.habitationId,
    required this.streetId,
    required this.address,
    required this.complaintTypeId,
    required this.complaintSubtypeId,
    required this.description,
    required this.entryBy,
    required this.entryByType,
    required this.documentList,
    required this.organisationId,
    required this.zoneId,
    required this.zoneWardId,
    required this.municipalityId,
    required this.municipalityWardId,
    required this.townPanchayatId,
    required this.townPanchayatWardId,
    required this.divisionId,
  });

  Map<String, dynamic> toJson() => {
        "operator_id": operatorId,
        "is_edit_public_details": isEditPublicDetails,
        "public_id": publicId,
        "public_name": publicName,
        "public_contactno": publicContactNo,
        "public_emailid": publicEmailId,
        "public_address": publicAddress,
        "origin": origin,
        "priority": priority,
        "type_id": typeId,
        "district_id": districtId,
        "block_id": blockId,
        "village_id": villageId,
        "habitation_id": habitationId,
        "street_id": streetId,
        "address": address,
        "complaint_type_id": complaintTypeId,
        "complaint_subtype_id": complaintSubtypeId,
        "description": description,
        "entry_by": entryBy,
        "entry_by_type": entryByType,
        "document_list": documentList.map((doc) => doc.toJson()).toList(),
        "organisation_id": organisationId,
        "zone_id": zoneId,
        "zone_ward_id": zoneWardId,
        "municipality_id": municipalityId,
        "municipality_ward_id": municipalityWardId,
        "town_panchayat_id": townPanchayatId,
        "town_panchayat_ward_id": townPanchayatWardId,
        "division_id": divisionId,
      };
}

class Document {
  final String fileLink;

  Document({required this.fileLink});

  Map<String, dynamic> toJson() => {
        "file_link": fileLink,
      };
}
