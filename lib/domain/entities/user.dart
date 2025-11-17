import 'package:equatable/equatable.dart';

/// User entity representing the core business object
class User extends Equatable {
  final String id;
  final String name;
  final String contactno;
  final String? address;
  final String emailid;
  final String? districtId;
  final String? blockId;
  final String? villageId;
  final String? habitationId;
  final String? pincode;
  final String? whatsappno;
  final String? districtName;
  final String? organisationName;
  final String? zoneName;
  final String? zoneWardName;
  final String? municipalityName;
  final String? municipalityWardName;
  final String? townPanchayatName;
  final String? townPanchayatWardName;
  final String? zoneWardId;
  final String? zoneId;
  final String? municipalityId;
  final String? municipalityWardId;
  final String? townPanchayatId;
  final String? corporationId;
  final String? townPanchayatWardId;
  final String? divisionId;
  final DateTime? lastLoginAt;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.contactno,
    this.address,
    required this.emailid,
    this.districtId,
    this.blockId,
    this.villageId,
    this.habitationId,
    this.pincode,
    this.whatsappno,
    this.districtName,
    this.organisationName,
    this.zoneName,
    this.zoneWardName,
    this.municipalityName,
    this.municipalityWardName,
    this.townPanchayatName,
    this.townPanchayatWardName,
    this.zoneWardId,
    this.zoneId,
    this.municipalityId,
    this.municipalityWardId,
    this.townPanchayatId,
    this.townPanchayatWardId,
    this.corporationId,
    this.divisionId,
    this.lastLoginAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        contactno,
        address,
        emailid,
        districtId,
        blockId,
        villageId,
        habitationId,
        pincode,
        whatsappno,
        districtName,
        organisationName,
        zoneName,
        zoneWardName,
        municipalityName,
        municipalityWardName,
        townPanchayatName,
        townPanchayatWardName,
        zoneWardId,
        zoneId,
        municipalityId,
        municipalityWardId,
        townPanchayatId,
        townPanchayatWardId,
        divisionId,
        corporationId,
        lastLoginAt,
        isActive,
      ];

  /// Create a copy of this user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? contactno,
    String? address,
    String? emailid,
    String? districtId,
    String? blockId,
    String? villageId,
    String? habitationId,
    String? pincode,
    String? whatsappno,
    String? districtName,
    String? organisationName,
    String? zoneName,
    String? zoneWardName,
    String? municipalityName,
    String? municipalityWardName,
    String? townPanchayatName,
    String? townPanchayatWardName,
    String? zoneWardId,
    String? zoneId,
    String? municipalityId,
    String? municipalityWardId,
    String? townPanchayatId,
    String? corporationId,
    String? townPanchayatWardId,
    String? divisionId,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      contactno: contactno ?? this.contactno,
      address: address ?? this.address,
      emailid: emailid ?? this.emailid,
      districtId: districtId ?? this.districtId,
      blockId: blockId ?? this.blockId,
      villageId: villageId ?? this.villageId,
      habitationId: habitationId ?? this.habitationId,
      pincode: pincode ?? this.pincode,
      whatsappno: whatsappno ?? this.whatsappno,
      districtName: districtName ?? this.districtName,
      organisationName: organisationName ?? this.organisationName,
      zoneName: zoneName ?? this.zoneName,
      zoneWardName: zoneWardName ?? this.zoneWardName,
      municipalityName: municipalityName ?? this.municipalityName,
      municipalityWardName: municipalityWardName ?? this.municipalityWardName,
      townPanchayatName: townPanchayatName ?? this.townPanchayatName,
      townPanchayatWardName: townPanchayatWardName ?? this.townPanchayatWardName,
      zoneWardId: zoneWardId ?? this.zoneWardId,
      zoneId: zoneId ?? this.zoneId,
      municipalityId: municipalityId ?? this.municipalityId,
      municipalityWardId: municipalityWardId ?? this.municipalityWardId,
      townPanchayatId: townPanchayatId ?? this.townPanchayatId,
      townPanchayatWardId: townPanchayatWardId ?? this.townPanchayatWardId,
      corporationId: corporationId ?? this.corporationId,
      divisionId: divisionId ?? this.divisionId,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if user has a specific role (using organisation name)
  bool hasRole(String role) {
    return organisationName?.toLowerCase().contains(role.toLowerCase()) ?? false;
  }

  /// Get user's display name
  String get displayName => name.isNotEmpty ? name : contactno;

  /// Check if user profile is complete
  bool get isProfileComplete => 
      name.isNotEmpty && emailid.isNotEmpty && contactno.isNotEmpty;
}
