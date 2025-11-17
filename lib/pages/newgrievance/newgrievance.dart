import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twad/data/models/complaint_list_model.dart';
import 'package:twad/data/models/corporation_model.dart';
import 'package:twad/data/models/habitation_list.dart';
import 'package:twad/data/models/municipality_ward_model.dart';
import 'package:twad/data/models/sub_complaint_type_list_model.dart';
import 'package:twad/data/models/town_panchayat_model.dart';
import 'package:twad/data/models/village_list_model.dart';
import 'package:twad/extensions/translation_extensions.dart';
import '../../constants/app_constants.dart';
import '../../data/models/block_list_model.dart';
import '../../data/models/district_list_model.dart';
import '../../data/models/grievance_type_model.dart';
import '../../data/models/maintanance_work.dart';
import '../../data/models/maintenance_model.dart';
import '../../data/models/municipality_model.dart';
import '../../data/models/town_panchayat_ward_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/zone_ward_model.dart';
import '../../presentation/providers/contact_provider.dart';
import '../../presentation/providers/file_upload_provider.dart';
import '../../presentation/providers/maintenance_provider.dart';
import '../../presentation/providers/organization_provider.dart';
import '../../pages/profile/profile_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/grievance_formfield.dart';
import '../../presentation/providers/master_list_provider.dart';
import '../../presentation/providers/grievance_provider.dart';

class NewGrievancePage extends StatefulWidget {
  const NewGrievancePage({super.key});

  @override
  State<NewGrievancePage> createState() => _NewGrievancePageState();
}

class _NewGrievancePageState extends State<NewGrievancePage> {
  void _triggerMaintenanceFetchIfReady(BuildContext context) async {
    final orgProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );
    final maintenanceProvider = Provider.of<MaintenanceProvider>(
      context,
      listen: false,
    );

    final Map<String, int> organizationIdMap = {
      'CORPORATION': 1,
      'MUNICIPALITY': 2,
      'TOWN PANCHAYAT': 3,
      'PANCHAYAT': 4,
    };

    final selectedOrg = orgProvider.selectedOrganization?.toUpperCase() ?? '';
    final dynamicOrgId = organizationIdMap[selectedOrg] ?? 0;
    if (_selectedDistrict.value != null) {
      final maintenance = MaintenanceModel(
        organisationId: dynamicOrgId,
        districtId: _selectedDistrict.value?.id.toString() ?? "0",
        blockId: _selectedBlock.value?.id.toString() ?? "0",
        villageId: _selectedVillage.value?.id.toString() ?? "0",
        habitationId: _selectedHabitation.value?.id.toString() ?? "0",
        complaintTypeId: _selectedComplaintType.value?.id.toString() ?? "1",
        complaintSubTypeId:
            _selectedSubComplaintType.value?.id.toString() ?? "0",
        zoneId: _selectedZone.value?.id ?? 0,
        zoneWardId: _selectedZoneWard.value?.id ?? 0,
        municipalityId: _selectedMunicipality.value?.id ?? 0,
        municipalityWardId: _selectedMunicipalityWard.value?.id ?? 0,
        townPanchayatId: _selectedTownPanchayat.value?.id ?? 0,
        townPanchayatWardId: _selectedTownPanchayatWard.value?.id ?? 0,
        divisionId: 0,
      );

      final hasMaintenance = await maintenanceProvider.fetchMaintenanceWorks(
        maintenance,
      );

      _hasMaintenanceWork.value =
          hasMaintenance && maintenanceProvider.maintenanceWorks.isNotEmpty;

      if (_hasMaintenanceWork.value) {
        _showMaintenancePopup(maintenanceProvider.maintenanceWorks);
      }
    } else {
      _hasMaintenanceWork.value = false;
    }
  }

  void _showMaintenancePopup(List<MaintenanceWork> maintenanceWorks) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.construction, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        context.tr.maintenanceActivity,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    context.tr.maintenanceDescription,
                    style: AppConstants.bodyTextStyle,
                  ),
                  SizedBox(height: 16),
                  ...maintenanceWorks
                      .take(1)
                      .map(
                        (work) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${context.tr.description} :",
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontSize: 14,
                                      color: AppConstants.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      context.tr.translate(
                                        work.description ?? '',
                                      ),
                                      style: AppConstants.bodyTextStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "${context.tr.startDate} :",
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontSize: 14,
                                      color: AppConstants.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    work.startDate != null
                                        ? "${work.startDate!.day.toString().padLeft(2, '0')}-${work.startDate!.month.toString().padLeft(2, '0')}-${work.startDate!.year}"
                                        : '-',
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontSize: 13,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "${context.tr.endDate} :",
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontSize: 14,
                                      color: AppConstants.textPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    work.endDate != null
                                        ? "${work.endDate!.day.toString().padLeft(2, '0')}-${work.endDate!.month.toString().padLeft(2, '0')}-${work.endDate!.year}"
                                        : '-',
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontSize: 13,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        context.tr.cancel,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final ValueNotifier<GrievanceTypeModel?> _selectedGrievanceType =
      ValueNotifier<GrievanceTypeModel?>(null);
  final ValueNotifier<DistrictModel?> _selectedDistrict =
      ValueNotifier<DistrictModel?>(null);
  final ValueNotifier<BlockModel?> _selectedBlock = ValueNotifier<BlockModel?>(
    null,
  );
  final ValueNotifier<bool> _hasMaintenanceWork = ValueNotifier<bool>(false);
  final ValueNotifier<VillageModel?> _selectedVillage =
      ValueNotifier<VillageModel?>(null);
  final ValueNotifier<HabitationModel?> _selectedHabitation =
      ValueNotifier<HabitationModel?>(null);
  final ValueNotifier<ComplaintTypeModel?> _selectedComplaintType =
      ValueNotifier<ComplaintTypeModel?>(null);
  final ValueNotifier<ComplaintSubTypeModel?> _selectedSubComplaintType =
      ValueNotifier<ComplaintSubTypeModel?>(null);
  final ValueNotifier<ZoneModel?> _selectedZone = ValueNotifier<ZoneModel?>(
    null,
  );

  final ValueNotifier<CorporationModel?> _selectedCorporation =
      ValueNotifier<CorporationModel?>(null);
  final ValueNotifier<ZoneWardModel?> _selectedZoneWard =
      ValueNotifier<ZoneWardModel?>(null);
  final ValueNotifier<MunicipalityModel?> _selectedMunicipality =
      ValueNotifier<MunicipalityModel?>(null);
  final ValueNotifier<MunicipalityWardModel?> _selectedMunicipalityWard =
      ValueNotifier<MunicipalityWardModel?>(null);
  final ValueNotifier<TownPanchayatModel?> _selectedTownPanchayat =
      ValueNotifier<TownPanchayatModel?>(null);
  final ValueNotifier<TownPanchayatWardModel?> _selectedTownPanchayatWard =
      ValueNotifier<TownPanchayatWardModel?>(null);
  final ValueNotifier<bool> _profileLoaded = ValueNotifier<bool>(false);
  final ValueNotifier<List<String>> _uploadedFileLinks = ValueNotifier([]);

  final ValueNotifier<List<PlatformFile>> _uploadedFiles =
      ValueNotifier<List<PlatformFile>>([]);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final masterProvider = Provider.of<MasterListProvider>(
        context,
        listen: false,
      );
      masterProvider.fetchDistricts();
      masterProvider.fetchGrievanceTypes();
      masterProvider.fetchComplaintTypes();
      masterProvider.fetchSubComplaintTypes();
      if (mounted) {
        loadProfileData(context);
      }
    });
  }

  final ValueNotifier<double?> _selectedLatitude = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _selectedLongitude = ValueNotifier<double?>(
    null,
  );
  final ValueNotifier<bool> _isGettingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<String> _locationAddress = ValueNotifier<String>('');
  final MapController _mapController = MapController();
  Future<void> _getCurrentLocationForDisplay() async {
    _isGettingLocation.value = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled', Colors.orange);
        _isGettingLocation.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions denied', Colors.orange);
          _isGettingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions permanently denied', Colors.orange);
        _isGettingLocation.value = false;
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _selectedLatitude.value = position.latitude;
      _selectedLongitude.value = position.longitude;

      _locationAddress.value =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);

      _showSnackBar(
        'Current GPS location captured. Map updated.',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Error getting location: ${e.toString()}', Colors.red);
    
    } finally {
      _isGettingLocation.value = false;
    }
  }

  void _onMapTap(LatLng point) {
    _selectedLatitude.value = point.latitude;
    _selectedLongitude.value = point.longitude;
    _locationAddress.value =
        '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
    _showSnackBar('Location selected via map tap', Colors.blue);
  }

  void _clearLocation() {
    _selectedLatitude.value = null;
    _selectedLongitude.value = null;
    _locationAddress.value = '';
    _showSnackBar('Location cleared', Colors.blue);
  }

  Future<void> loadProfileData(BuildContext context) async {
    if (!mounted) return;

    final profileProvider = Provider.of<ContactProfileProvider>(
      context,
      listen: false,
    );
    final orgProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );
    final masterProvider = Provider.of<MasterListProvider>(
      context,
      listen: false,
    );

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    _nameController.text = prefs.getString('name') ?? '';
    _contactController.text = prefs.getString('contactno') ?? '';
    _emailController.text = prefs.getString('emailid') ?? '';
    _addressController.text = prefs.getString('address') ?? '0';
    _profileLoaded.value = true;

    final savedSelections = await ProfileProvider.getSavedProfileSelections();
    if (!mounted) return;
    if (savedSelections['organization']?.isNotEmpty == true) {
      orgProvider.selectOrganization(savedSelections['organization']!);
    }

    await profileProvider.fetchUserProfile();
    if (!mounted) return;

    final data = profileProvider.profileData?['data']?[0];
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _contactController.text = data['contactno'] ?? '';
      _emailController.text = data['emailid'] ?? '';
      _addressController.text = data['address'] ?? '';
      await prefs.setString('name', _nameController.text);
      await prefs.setString('contactno', _contactController.text);
      await prefs.setString('emailid', _emailController.text);
      await prefs.setString('address', _addressController.text);
      if (!mounted) return;
      final organizationName = data['organisation_name']
          ?.toString()
          .toUpperCase();
      if (organizationName?.isNotEmpty == true) {
        orgProvider.selectOrganization(organizationName!);
        await prefs.setString('selectedOrganization', organizationName);
        if (!mounted) return;
      }
      if (masterProvider.grievanceTypes.isNotEmpty) {
        if (masterProvider.grievanceTypes.length > 1) {
          _selectedGrievanceType.value = masterProvider.grievanceTypes[1];
        } else {
          _selectedGrievanceType.value = masterProvider.grievanceTypes[0];
        }
      }
      final districtName = data['district_name']?.toString();
      if (districtName?.isNotEmpty == true) {
        final districts = masterProvider.districts;
        final matchingDistrict =
            districts
                .where(
                  (district) =>
                      district.districtName.toUpperCase() ==
                      districtName!.toUpperCase(),
                )
                .isNotEmpty
            ? districts.firstWhere(
                (district) =>
                    district.districtName.toUpperCase() ==
                    districtName!.toUpperCase(),
              )
            : null;

        if (matchingDistrict?.id != null) {
          _selectedDistrict.value = matchingDistrict;
          await Future.wait([
            masterProvider.fetchBlocks(matchingDistrict!.id),
            masterProvider.fetchCorporations(matchingDistrict.id),
            masterProvider.fetchMunicipalities(matchingDistrict.id),
            masterProvider.fetchTownPanchayats(matchingDistrict.id),
          ]);
          if (!mounted) return;
          if (organizationName?.isNotEmpty == true) {
            if (organizationName! == 'CORPORATION') {
              await _setUserProfileCorporationDefaults(masterProvider, data);
              if (!mounted) return;
            } else if (organizationName == 'MUNICIPALITY') {
              await _setUserProfileMunicipalityDefaults(masterProvider, data);
              if (!mounted) return;
            } else if (organizationName == 'TOWN PANCHAYAT') {
              await _setUserProfileTownPanchayatDefaults(masterProvider, data);
              if (!mounted) return;
            } else if (organizationName == 'PANCHAYAT' ||
                organizationName == 'VILLAGE PANCHAYAT') {
              await _setUserProfilePanchayatDefaults(masterProvider, data);
            }
          }
        }
      }
    } else {
      if (savedSelections['district']?.isNotEmpty == true) {
        final districts = masterProvider.districts;
        final matchingDistrict =
            districts
                .where(
                  (district) =>
                      district.districtName == savedSelections['district'],
                )
                .isNotEmpty
            ? districts.firstWhere(
                (district) =>
                    district.districtName == savedSelections['district'],
              )
            : null;

        if (matchingDistrict?.id != null) {
          _selectedDistrict.value = matchingDistrict;
          await Future.wait([
            masterProvider.fetchBlocks(matchingDistrict!.id),
            masterProvider.fetchMunicipalities(matchingDistrict.id),
            masterProvider.fetchTownPanchayats(matchingDistrict.id),
            masterProvider.fetchCorporations(matchingDistrict.id),
          ]);
          if (!mounted) return;
          final selectedOrg = savedSelections['organization'];
          if (selectedOrg?.isNotEmpty == true) {
            if (selectedOrg!.toUpperCase() == 'CORPORATION') {
              await _setCorporationDefaults(masterProvider, savedSelections);
            } else if (selectedOrg.toUpperCase() == 'MUNICIPALITY') {
              _setMunicipalityDefaults(masterProvider, savedSelections);
            } else if (selectedOrg.toUpperCase() == 'TOWN PANCHAYAT') {
              _setTownPanchayatDefaults(masterProvider, savedSelections);
            } else if (selectedOrg.toUpperCase() == 'PANCHAYAT') {
              _setBlockDefaults(masterProvider, savedSelections);
            }
          }
        }
      }
    }
  }

  Future<void> _setCorporationDefaults(
    MasterListProvider masterProvider,
    Map<String, String> savedSelections,
  ) async {
    if (savedSelections['corporation']?.isNotEmpty == true &&
        _selectedDistrict.value != null) {
      final corporations = masterProvider.corporations;
      final matchingCorporations = corporations.where(
        (corp) => corp.corporationName == savedSelections['corporation'],
      );

      if (matchingCorporations.isNotEmpty) {
        final matchingCorporation = matchingCorporations.first;
        _selectedCorporation.value = matchingCorporation;
        await masterProvider.fetchZones(
          _selectedDistrict.value!.id,
          matchingCorporation.id,
        );
        if (!mounted) return;
        await _setZoneDefaults(masterProvider, savedSelections);
      }
    }
  }

  Future<void> _setZoneDefaults(
    MasterListProvider masterProvider,
    Map<String, String> savedSelections,
  ) async {
    if (savedSelections['zone']?.isNotEmpty == true) {
      final zones = masterProvider.zones;
      final matchingZones = zones.where(
        (zone) => zone.zoneName == savedSelections['zone'],
      );

      if (matchingZones.isNotEmpty) {
        final matchingZone = matchingZones.first;
        _selectedZone.value = matchingZone;
        await masterProvider.fetchZoneWards(
          matchingZone.id,
          _selectedDistrict.value!.id,
          _selectedCorporation.value!.id,
        );
        if (!mounted) return;

        if (savedSelections['zoneward']?.isNotEmpty == true) {
          final zoneWards = masterProvider.zoneWards;
          final matchingWards = zoneWards.where(
            (ward) => ward.zoneWardName == savedSelections['zoneward'],
          );
          if (matchingWards.isNotEmpty) {
            _selectedZoneWard.value = matchingWards.first;
          }
        }
      }
    }
  }

  Future<void> _setMunicipalityDefaults(
    MasterListProvider masterProvider,
    Map<String, String> savedSelections,
  ) async {
    if (savedSelections['municipality']?.isNotEmpty == true) {
      final municipalities = masterProvider.municipalities;
      final matchingMunicipalities = municipalities.where(
        (municipality) =>
            municipality.municipalityName == savedSelections['municipality'],
      );

      if (matchingMunicipalities.isNotEmpty) {
        final matchingMunicipality = matchingMunicipalities.first;
        _selectedMunicipality.value = matchingMunicipality;
        await masterProvider.fetchMunicipalityWards(matchingMunicipality.id);
        if (!mounted) return;

        if (savedSelections['municipalityward']?.isNotEmpty == true) {
          final municipalityWards = masterProvider.municipalityWards;
          final matchingWards = municipalityWards.where(
            (ward) =>
                ward.municipalityWardName ==
                savedSelections['municipalityward'],
          );
          if (matchingWards.isNotEmpty) {
            _selectedMunicipalityWard.value = matchingWards.first;
          }
        }
      }
    }
  }

  Future<void> _setTownPanchayatDefaults(
    MasterListProvider masterProvider,
    Map<String, String> savedSelections,
  ) async {
    if (savedSelections['townpanchayat']?.isNotEmpty == true) {
      final townPanchayats = masterProvider.townPanchayats;
      final matchingTownPanchayats = townPanchayats.where(
        (townPanchayat) =>
            townPanchayat.townPanchayatName == savedSelections['townpanchayat'],
      );

      if (matchingTownPanchayats.isNotEmpty) {
        final matchingTownPanchayat = matchingTownPanchayats.first;
        _selectedTownPanchayat.value = matchingTownPanchayat;
        await masterProvider.fetchTownPanchayatWards(matchingTownPanchayat.id);

        if (savedSelections['townpanchayatward']?.isNotEmpty == true) {
          final townPanchayatWards = masterProvider.townPanchayatWards;
          final matchingWards = townPanchayatWards.where(
            (ward) =>
                ward.townPanchayatWardName ==
                savedSelections['townpanchayatward'],
          );
          if (matchingWards.isNotEmpty) {
            _selectedTownPanchayatWard.value = matchingWards.first;
          }
        }
      }
    }
  }

  Future<void> _setBlockDefaults(
    MasterListProvider masterProvider,
    Map<String, String> savedSelections,
  ) async {
    if (savedSelections['block']?.isNotEmpty == true) {
      final blocks = masterProvider.blocks;
      final matchingBlocks = blocks.where(
        (block) => block.blockName == savedSelections['block'],
      );

      if (matchingBlocks.isNotEmpty) {
        final matchingBlock = matchingBlocks.first;
        _selectedBlock.value = matchingBlock;
        await masterProvider.fetchVillages(matchingBlock.id);

        if (savedSelections['village']?.isNotEmpty == true) {
          final villages = masterProvider.villages;
          final matchingVillages = villages.where(
            (village) => village.villageName == savedSelections['village'],
          );

          if (matchingVillages.isNotEmpty) {
            final matchingVillage = matchingVillages.first;
            _selectedVillage.value = matchingVillage;
            await masterProvider.fetchHabitations(matchingVillage.id);

            if (savedSelections['habitation']?.isNotEmpty == true) {
              final habitations = masterProvider.habitations;
              final matchingHabitations = habitations.where(
                (habitation) =>
                    habitation.habitationName == savedSelections['habitation'],
              );
              if (matchingHabitations.isNotEmpty) {
                _selectedHabitation.value = matchingHabitations.first;
              }
            }
          }
        }
      }
    }
  }

  Future<void> _setUserProfileCorporationDefaults(
    MasterListProvider masterProvider,
    Map<String, dynamic> profileData,
  ) async {
    final corporationId =
        profileData['corporation_id']?.toString() ??
        profileData['corporationId']?.toString();

    final corporationName =
        profileData['corporation_name']?.toString() ??
        profileData['corporationName']?.toString();

    if (_selectedDistrict.value != null) {
      await masterProvider.fetchCorporations(_selectedDistrict.value!.id);

      final corporations = masterProvider.corporations;
      CorporationModel? matchingCorporation;

      if (corporationId != null &&
          corporationId.isNotEmpty &&
          corporationId != '0') {
        final corpIdInt = int.tryParse(corporationId);
        if (corpIdInt != null) {
          matchingCorporation = corporations
              .where((corp) => corp.id == corpIdInt)
              .firstOrNull;
        }
      }

      if (matchingCorporation == null &&
          corporationName != null &&
          corporationName.isNotEmpty) {
        matchingCorporation = corporations
            .where(
              (corp) =>
                  corp.corporationName.toUpperCase() ==
                  corporationName.toUpperCase(),
            )
            .firstOrNull;
      }

      if (matchingCorporation != null) {
        _selectedCorporation.value = matchingCorporation;
        await masterProvider.fetchZones(
          _selectedDistrict.value!.id,
          matchingCorporation.id,
        );
      } else {}
    }

    final zoneName = profileData['zone_name']?.toString();
    final zoneId = profileData['zone_id']?.toString();

    if ((zoneName?.isNotEmpty == true || zoneId?.isNotEmpty == true) &&
        masterProvider.zones.isNotEmpty) {
      ZoneModel? matchingZone;
      if (zoneId != null && zoneId.isNotEmpty && zoneId != '0') {
        final zoneIdInt = int.tryParse(zoneId);
        if (zoneIdInt != null) {
          matchingZone = masterProvider.zones
              .where((z) => z.id == zoneIdInt)
              .firstOrNull;
        }
      }
      if (matchingZone == null && zoneName != null && zoneName.isNotEmpty) {
        matchingZone = masterProvider.zones
            .where(
              (zone) => zone.zoneName.toUpperCase() == zoneName.toUpperCase(),
            )
            .firstOrNull;
      }

      if (matchingZone != null) {
        _selectedZone.value = matchingZone;
        await masterProvider.fetchZoneWards(
          matchingZone.id,
          _selectedDistrict.value!.id,
          _selectedCorporation.value!.id,
        );

        final zoneWardName = profileData['zone_ward_name']?.toString();
        final zoneWardId = profileData['zone_ward_id']?.toString();

        if ((zoneWardName?.isNotEmpty == true ||
                zoneWardId?.isNotEmpty == true) &&
            masterProvider.zoneWards.isNotEmpty) {
          ZoneWardModel? matchingZoneWard;

          if (zoneWardId != null &&
              zoneWardId.isNotEmpty &&
              zoneWardId != '0') {
            final zoneWardIdInt = int.tryParse(zoneWardId);
            if (zoneWardIdInt != null) {
              matchingZoneWard = masterProvider.zoneWards
                  .where((w) => w.id == zoneWardIdInt)
                  .firstOrNull;
            }
          }
          if (matchingZoneWard == null &&
              zoneWardName != null &&
              zoneWardName.isNotEmpty) {
            matchingZoneWard = masterProvider.zoneWards
                .where(
                  (ward) =>
                      ward.zoneWardName.toUpperCase() ==
                      zoneWardName.toUpperCase(),
                )
                .firstOrNull;
          }

          if (matchingZoneWard != null) {
            _selectedZoneWard.value = matchingZoneWard;
          }
        }
      }
    }
  }

  Future<void> _setUserProfileMunicipalityDefaults(
    MasterListProvider masterProvider,
    Map<String, dynamic> profileData,
  ) async {
    final municipalityName = profileData['municipality_name']?.toString();
    if (municipalityName?.isNotEmpty == true) {
      final municipalities = masterProvider.municipalities;
      final matchingMunicipalities = municipalities.where(
        (municipality) =>
            municipality.municipalityName.toUpperCase() ==
            municipalityName!.toUpperCase(),
      );

      if (matchingMunicipalities.isNotEmpty) {
        final matchingMunicipality = matchingMunicipalities.first;
        _selectedMunicipality.value = matchingMunicipality;
        await masterProvider.fetchMunicipalityWards(matchingMunicipality.id);

        final municipalityWardName = profileData['municipality_ward_name']
            ?.toString();
        if (municipalityWardName?.isNotEmpty == true) {
          final municipalityWards = masterProvider.municipalityWards;
          final matchingWards = municipalityWards.where(
            (ward) =>
                ward.municipalityWardName.toUpperCase() ==
                municipalityWardName!.toUpperCase(),
          );
          if (matchingWards.isNotEmpty) {
            _selectedMunicipalityWard.value = matchingWards.first;
          }
        }
      }
    }
  }

  Future<void> _setUserProfileTownPanchayatDefaults(
    MasterListProvider masterProvider,
    Map<String, dynamic> profileData,
  ) async {
    final townPanchayatName = profileData['town_panchayat_name']?.toString();
    if (townPanchayatName?.isNotEmpty == true) {
      final townPanchayats = masterProvider.townPanchayats;
      final matchingTownPanchayats = townPanchayats.where(
        (townPanchayat) =>
            townPanchayat.townPanchayatName.toUpperCase() ==
            townPanchayatName!.toUpperCase(),
      );

      if (matchingTownPanchayats.isNotEmpty) {
        final matchingTownPanchayat = matchingTownPanchayats.first;
        _selectedTownPanchayat.value = matchingTownPanchayat;
        await masterProvider.fetchTownPanchayatWards(matchingTownPanchayat.id);

        final townPanchayatWardName = profileData['town_panchayat_ward_name']
            ?.toString();
        if (townPanchayatWardName?.isNotEmpty == true) {
          final townPanchayatWards = masterProvider.townPanchayatWards;
          final matchingWards = townPanchayatWards.where(
            (ward) =>
                ward.townPanchayatWardName.toUpperCase() ==
                townPanchayatWardName!.toUpperCase(),
          );
          if (matchingWards.isNotEmpty) {
            _selectedTownPanchayatWard.value = matchingWards.first;
          }
        }
      }
    }
  }

  Future<void> _setUserProfilePanchayatDefaults(
    MasterListProvider masterProvider,
    Map<String, dynamic> profileData,
  ) async {
    final blockName = profileData['block_name']?.toString();
    if (blockName?.isNotEmpty == true) {
      final blocks = masterProvider.blocks;
      final matchingBlocks = blocks.where(
        (block) => block.blockName.toUpperCase() == blockName!.toUpperCase(),
      );

      if (matchingBlocks.isNotEmpty) {
        final matchingBlock = matchingBlocks.first;
        _selectedBlock.value = matchingBlock;
        await masterProvider.fetchVillages(matchingBlock.id);

        final villageName = profileData['village_name']?.toString();
        if (villageName?.isNotEmpty == true) {
          final villages = masterProvider.villages;
          final matchingVillages = villages.where(
            (village) =>
                village.villageName.toUpperCase() == villageName!.toUpperCase(),
          );

          if (matchingVillages.isNotEmpty) {
            final matchingVillage = matchingVillages.first;
            _selectedVillage.value = matchingVillage;
            await masterProvider.fetchHabitations(matchingVillage.id);

            final habitationName = profileData['habitation_name']?.toString();
            if (habitationName?.isNotEmpty == true) {
              final habitations = masterProvider.habitations;
              final matchingHabitations = habitations.where(
                (habitation) =>
                    habitation.habitationName.toUpperCase() ==
                    habitationName!.toUpperCase(),
              );
              if (matchingHabitations.isNotEmpty) {
                _selectedHabitation.value = matchingHabitations.first;
              }
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _complaintController.dispose();
    final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
    _uploadedFiles.dispose();
    uploadProvider.fileLinks.clear();
    uploadProvider.relativePaths.clear();
    _mapController.dispose();
    _selectedLatitude.dispose();
    _selectedLongitude.dispose();
    _isGettingLocation.dispose();
    _locationAddress.dispose();

    for (final relativePath in uploadProvider.relativePaths) {
      uploadProvider.deleteFile(relativePath);
    }

    super.dispose();
  }

  Future<void> _showFilePickerOptions(BuildContext context) async {
    if (_uploadedFiles.value.length >= 5) {
      _showSnackBar("Files limit Reached", Colors.orange);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text('Select Documents'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFiles();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {    
    try {
      final ImagePicker picker = ImagePicker();      
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
     final imageSize = await image.length();

        
        final file = PlatformFile(
          path: image.path,
          name: image.name,
          size: imageSize,
          bytes: await image.readAsBytes(),
        );
        await _processSelectedFile([file]);
      }
    } catch (e) {
      _showSnackBar('Error capturing image: ${e.toString()}', Colors.red);
    }
  }



  Future<void> _processSelectedFile(List<PlatformFile> files) async {
    
    try {
      final currentFileCount = _uploadedFiles.value.length;
      const maxFiles = 5;
      final remainingSlots = maxFiles - currentFileCount;
    

      if (files.length > remainingSlots) {
        _showSnackBar(
          'You can only upload $remainingSlots more files',
          Colors.orange,
        );
        return;
      }

      const maxFileSize = 5 * 1024 * 1024;
      final oversizedFiles = files
          .where((file) => file.size > maxFileSize)
          .map((file) => file.name)
          .toList();

      if (oversizedFiles.isNotEmpty) {
        _showSnackBar(
          'Files exceeding 5MB: ${oversizedFiles.join(", ")}',
          Colors.orange,
        );
        return;
      }

      final totalSize = files.fold<int>(0, (sum, file) => sum + file.size);
      const maxTotalSize = 50 * 1024 * 1024;

      if (totalSize > maxTotalSize) {
        _showSnackBar('Total file size exceeds 50MB limit', Colors.orange);
        return;
      }

      _showSnackBar(context.tr.fileupdating, Colors.blue);
      final uploadProvider = Provider.of<UploadProvider>(
        context,
        listen: false,
      );

      final validFiles = <PlatformFile>[];
      for (final file in files) {
        try {
          if (file.path != null || file.bytes != null) {
            if (file.bytes != null && file.bytes!.isNotEmpty) {
              validFiles.add(file);
            } else if (file.path != null && file.path!.isNotEmpty) {
              // Check if file exists for mobile
              final fileExists = await File(file.path!).exists();
              if (fileExists) {
                validFiles.add(file);
              } else {
              }
            }
          }
        } catch (e) {
          _showSnackBar('Error $e.', Colors.red);
        }
      }


      if (validFiles.isEmpty) {
        _showSnackBar('No valid files selected. Please try again.', Colors.red);
        return;
      }

      try {
        await uploadProvider
            .uploadFiles(validFiles)
            .timeout(
              Duration(seconds: 60),
              onTimeout: () {
                throw TimeoutException('Upload timeout', Duration(seconds: 60));
              },
            );
      } on TimeoutException catch (e) {
        _showSnackBar(
          'Upload timeout. Please check your connection and try again.$e',
          Colors.red,
        );
        return;
      }
      if (!mounted) return;
      
      if (uploadProvider.uploadedFiles.isNotEmpty) {
        final currentFiles = _uploadedFiles.value;
        _uploadedFiles.value = [...currentFiles, ...validFiles];
        _uploadedFileLinks.value = List.from(uploadProvider.fileLinks);
        _showSnackBar(context.tr.filesUploaded, Colors.green);
      } else {
        final errorMsg =
            uploadProvider.message ?? context.tr.errorUploadingFiles;
        _showSnackBar('Upload failed: $errorMsg', Colors.red);
      }
    } catch (e) {

      String errorMessage;
      if (e.toString().contains('Permission denied')) {
        errorMessage =
            'Permission denied. Please check file access permissions.';
      } else if (e.toString().contains('No space left')) {
        errorMessage =
            'Insufficient storage space. Please free up space and try again.';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Upload timeout. Please try again with a better connection.';
      } else {
        errorMessage = 'Error processing files: ${e.toString()}';
      }

      _showSnackBar(errorMessage, Colors.red);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final currentFileCount = _uploadedFiles.value.length;
      const maxFiles = 5;

      if (currentFileCount >= maxFiles) {
        _showSnackBar(
          'Maximum $maxFiles files allowed. Please remove some files first.',
          Colors.orange,
        );
        return;
      }

      final remainingSlots = maxFiles - currentFileCount;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.length > remainingSlots) {
          _showSnackBar(
            'You can only upload $remainingSlots more files (maximum $maxFiles total)',
            Colors.orange,
          );
          return;
        }

        const maxFileSize = 5 * 1024 * 1024;
        final oversizedFiles = result.files
            .where((file) => file.size > maxFileSize)
            .toList();

        if (oversizedFiles.isNotEmpty) {
          final fileNames = oversizedFiles.map((f) => f.name).join(', ');
          _showSnackBar('Files too large (max 5MB): $fileNames', Colors.red);
          return;
        }
        final totalSize = result.files.fold<int>(
          0,
          (sum, file) => sum + file.size,
        );
        const maxTotalSize = 50 * 1024 * 1024;

        if (totalSize > maxTotalSize) {
          _showSnackBar(
            'Total file size too large (max 50MB). Current: ${(totalSize / 1024 / 1024).toStringAsFixed(2)}MB',
            Colors.red,
          );
          return;
        }

        _showSnackBar(context.tr.fileupdating, Colors.blue);

        final uploadProvider = Provider.of<UploadProvider>(
          context,
          listen: false,
        );

        // Add timeout and better error handling for mobile
        try {
          await uploadProvider
              .uploadFiles(result.files)
              .timeout(
                Duration(seconds: 60),
                onTimeout: () {
                  throw TimeoutException(
                    'Upload timeout',
                    Duration(seconds: 60),
                  );
                },
              );
        } on TimeoutException {
          _showSnackBar(
            'Upload timeout. Please check your internet connection and try again.',
            Colors.red,
          );
          return;
        } catch (uploadError) {
          _showSnackBar('Upload failed: ${uploadError.toString()}', Colors.red);
          return;
        }

        if (uploadProvider.uploadedFiles.isNotEmpty) {
          _uploadedFiles.value = [
            ..._uploadedFiles.value,
            ...uploadProvider.uploadedFiles,
          ];
          _uploadedFileLinks.value = [
            ..._uploadedFileLinks.value,
            ...uploadProvider.fileLinks,
          ];

          final successCount = uploadProvider.uploadedFiles.length;
          final totalCount = result.files.length;

          if (mounted) {
            if (successCount == totalCount) {
              _showSnackBar(context.tr.fileuploadedsuccess, Colors.green);
            } else {
              _showSnackBar(
                ' $successCount/$totalCount files uploaded. ${uploadProvider.message ?? "Some uploads failed."}',
                Colors.orange,
              );
            }
          }
        } else {
          final errorMessage = uploadProvider.message ?? 'Upload failed';
          _showSnackBar('❌ Upload failed: $errorMessage', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('❌ Error selecting files: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIconForColor(color), color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: color == Colors.red ? 5 : 3),
        action: color == Colors.red
            ? SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }

  IconData _getIconForColor(Color color) {
    if (color == Colors.green) return Icons.check_circle;
    if (color == Colors.red) return Icons.error;
    if (color == Colors.orange) return Icons.warning;
    if (color == Colors.blue) return Icons.info;
    return Icons.notifications;
  }

  void _clearForm() {
    _complaintController.clear();
    _selectedGrievanceType.value = null;
    _selectedComplaintType.value = null;
    _selectedSubComplaintType.value = null;
    _uploadedFiles.value = [];

    final uploadProvider = Provider.of<UploadProvider>(context, listen: false);
    for (final relativePath in uploadProvider.relativePaths) {
      uploadProvider.deleteFile(relativePath);
    }
    uploadProvider.uploadedFiles.clear();
    uploadProvider.fileLinks.clear();
    uploadProvider.relativePaths.clear();
    _locationAddress.value = '';
    _isGettingLocation.value = false;
    _selectedLongitude.value = null;
    _selectedLatitude.value = null;
    _showSnackBar(context.tr.formCleared, Colors.blue);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final orgProvider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );
      final selectedOrg = orgProvider.selectedOrganization;
      if (_selectedLatitude.value == null || _selectedLongitude.value == null) {
        _showSnackBar(
          'Please select a location on the map first',
          Colors.orange,
        );
        return;
      }
      if (_selectedGrievanceType.value == null) {
        _showSnackBar(context.tr.selectGrievanceType, Colors.orange);
        return;
      }
      if (_selectedDistrict.value == null) {
        _showSnackBar(context.tr.selectDistrict, Colors.orange);
        return;
      }
      if (selectedOrg == null || selectedOrg.isEmpty) {
        _showSnackBar('Please select an organization', Colors.orange);
        return;
      }

      if (selectedOrg.toUpperCase() == 'CORPORATION') {
        if (_selectedZone.value == null) {
          _showSnackBar(context.tr.warningSelectZone, Colors.orange);
          return;
        }
        if (_selectedZoneWard.value == null) {
          _showSnackBar(context.tr.warningSelectZoneWard, Colors.orange);
          return;
        }
      } else if (selectedOrg.toUpperCase() == 'MUNICIPALITY') {
        if (_selectedMunicipality.value == null) {
          _showSnackBar(context.tr.wariningSelectMunicipality, Colors.orange);
          return;
        }
        if (_selectedMunicipalityWard.value == null) {
          _showSnackBar(
            context.tr.waringingSelectMunicipalityWard,
            Colors.orange,
          );
          return;
        }
      } else if (selectedOrg.toUpperCase() == 'TOWN PANCHAYAT') {
        if (_selectedTownPanchayat.value == null) {
          _showSnackBar(context.tr.warningSelectTownPanchayat, Colors.orange);
          return;
        }
        if (_selectedTownPanchayatWard.value == null) {
          _showSnackBar(
            context.tr.warningSelectTownPanchayatWard,
            Colors.orange,
          );
          return;
        }
      } else if (selectedOrg.toUpperCase() == 'PANCHAYAT') {
        if (_selectedBlock.value == null) {
          _showSnackBar(context.tr.selectBlock, Colors.orange);
          return;
        }
        if (_selectedVillage.value == null) {
          _showSnackBar(context.tr.selectVillage, Colors.orange);
          return;
        }
        if (_selectedHabitation.value == null) {
          _showSnackBar(context.tr.selectHabitation, Colors.orange);
          return;
        }
      }

      if (_selectedSubComplaintType.value == null) {
        _showSnackBar(context.tr.selectComplaintType, Colors.orange);
        return;
      }

      try {
        int organizationId = 1;
        switch (selectedOrg.toUpperCase()) {
          case 'CORPORATION':
            organizationId = 1;
            break;
          case 'MUNICIPALITY':
            organizationId = 2;
            break;
          case 'TOWN PANCHAYAT':
            organizationId = 3;
            break;
          case 'PANCHAYAT':
            organizationId = 4;
            break;
        }

        final grievanceData = {
          "operator_id": 0,
          "is_edit_public_details": 1,
          "public_name": _nameController.text.trim(),
          "public_contactno": _contactController.text.trim(),
          "public_emailid": _emailController.text.trim(),
          "public_address": _addressController.text.trim(),
          "origin": "Mobile",
          "priority": "High",
          "type_id": _selectedGrievanceType.value?.id ?? 0,
          "district_id": _selectedDistrict.value?.id ?? 0,
          "address": _addressController.text.trim(),
          "complaint_type_id": _selectedComplaintType.value?.id ?? 1,
          "complaint_subtype_id": _selectedSubComplaintType.value?.id ?? 0,
          "description": _complaintController.text.trim(),
          "entry_by": 1,
          "entry_by_type": "public",
          "document_list": _uploadedFileLinks.value.isNotEmpty
              ? _uploadedFileLinks.value
                    .map((link) => {"file_link": link})
                    .toList()
              : [],
          "organisation_id": organizationId,
          "lat": _selectedLatitude.value,
          "lng": _selectedLongitude.value,
        };
        if (selectedOrg.toUpperCase() == 'CORPORATION') {
          grievanceData.addAll({
            "zone_id": _selectedZone.value?.id ?? 0,
            "zone_ward_id": _selectedZoneWard.value?.id ?? 0,
            "block_id": 0,
            "village_id": 0,
            "habitation_id": 0,
            "municipality_id": 0,
            "municipality_ward_id": 0,
            "town_panchayat_id": 0,
            "town_panchayat_ward_id": 0,
            "division_id": 0,
            "street_id": 0,
          });
        } else if (selectedOrg.toUpperCase() == 'MUNICIPALITY') {
          grievanceData.addAll({
            "municipality_id": _selectedMunicipality.value?.id ?? 0,
            "municipality_ward_id": _selectedMunicipalityWard.value?.id ?? 0,
            "zone_id": 0,
            "zone_ward_id": 0,
            "block_id": 0,
            "village_id": 0,
            "habitation_id": 0,
            "town_panchayat_id": 0,
            "town_panchayat_ward_id": 0,
            "division_id": 0,
            "street_id": 0,
          });
        } else if (selectedOrg.toUpperCase() == 'TOWN PANCHAYAT') {
          grievanceData.addAll({
            "town_panchayat_id": _selectedTownPanchayat.value?.id ?? 0,
            "town_panchayat_ward_id": _selectedTownPanchayatWard.value?.id ?? 0,
            "zone_id": 0,
            "zone_ward_id": 0,
            "block_id": 0,
            "village_id": 0,
            "habitation_id": 0,
            "municipality_id": 0,
            "municipality_ward_id": 0,
            "division_id": 0,
            "street_id": 0,
          });
        } else if (selectedOrg.toUpperCase() == 'PANCHAYAT') {
          grievanceData.addAll({
            "block_id": _selectedBlock.value?.id ?? 0,
            "village_id": _selectedVillage.value?.id ?? 0,
            "habitation_id": _selectedHabitation.value?.id ?? 0,
            "zone_id": 0,
            "zone_ward_id": 0,
            "municipality_id": 0,
            "municipality_ward_id": 0,
            "town_panchayat_id": 0,
            "town_panchayat_ward_id": 0,
            "division_id": 0,
            "street_id": 0,
          });
        }
        final grievanceProvider = Provider.of<GrievanceProvider>(
          context,
          listen: false,
        );
        await grievanceProvider.submitGrievance(grievanceData);

        if (!mounted) return;

        if (grievanceProvider.submitSuccessMessage != null) {
          grievanceProvider.fetchGrievanceCount();
          grievanceProvider.fetchRecentGrievances();
          _uploadedFiles.value = [];
          _uploadedFileLinks.value = [];
          final uploadProvider = Provider.of<UploadProvider>(
            context,
            listen: false,
          );
          uploadProvider.uploadedFiles.clear();
          uploadProvider.fileLinks.clear();
          uploadProvider.relativePaths.clear();

          _showSnackBar(context.tr.newGrievanceSubmitted, Colors.green);
          Navigator.of(context).pop();
        } else if (grievanceProvider.submitError != null) {
          _showSnackBar(grievanceProvider.submitError!, Colors.red);
        } else {
          _showSnackBar(context.tr.unknownError, Colors.red);
        }
      } catch (e) {
        _showSnackBar(
          'Error submitting grievance: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 24),
              _buildSectionHeader(context.tr.contactdetails, Icons.person),
              const SizedBox(height: 16),
              _buildContactDetailsSection(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                context.tr.complaintdetails,
                Icons.report_problem,
                trailing: _buildWhatsAppIcon(),
              ),
              const SizedBox(height: 16),
              _buildComplaintDetailsSection(),
              const SizedBox(height: 32),
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Text(
              context.tr.newgrievance,
              style: AppConstants.titleStyle.copyWith(fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              context.tr.grievance,
              style: AppConstants.bodyTextStyle.copyWith(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              context.tr.newgrievance,
              style: AppConstants.bodyTextStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppConstants.buttonTextStyle.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildWhatsAppIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.safety_check, color: Colors.white, size: 20),
    );
  }

  Widget _buildContactDetailsSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _profileLoaded,
      builder: (context, loaded, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GrievanceFormfield(
                  label: context.tr.phnoLable,
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.contactNumberRequired;
                    }
                    if (value.length < 10) {
                      return context.tr.validContactNumber;
                    }
                    return null;
                  },
                  isEnabled: false,
                  items: [],
                  hint: context.tr.hintcontact,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                GrievanceFormfield(
                  label: context.tr.nameLabel,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.nameRequired;
                    }
                    return null;
                  },
                  isEnabled: false,
                  items: [],
                  hint: context.tr.hintname,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                GrievanceFormfield(
                  label: context.tr.mailIdLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return context.tr.validEmail;
                      }
                    }
                    return null;
                  },
                  isEnabled: false,
                  items: [],
                  hint: context.tr.hintEmail,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                GrievanceFormfield(
                  label: context.tr.addressLabel,
                  controller: _addressController,
                  isEnabled: false,
                  items: [],
                  hint: context.tr.hintAddress,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Consumer2<MasterListProvider, OrganizationProvider>(
              builder: (context, masterProvider, organizationprovider, child) {
                final districtItems = masterProvider.districts;
                return ValueListenableBuilder<DistrictModel?>(
                  valueListenable: _selectedDistrict,
                  builder: (context, selected, _) {
                    return CustomDropdownField<DistrictModel>(
                      label: context.tr.gistrictLabel,
                      value: selected,
                      items: districtItems,
                      hint: districtItems.isEmpty
                          ? context.tr.loadingData
                          : context.tr.select,
                      itemLabelBuilder: (district) =>
                          context.tr.translate(district.districtName),
                      onChanged: districtItems.isEmpty
                          ? null
                          : (value) async {
                              _selectedDistrict.value = value;
                              organizationprovider.selectOrganization(null);
                              _selectedBlock.value = null;
                              _selectedVillage.value = null;
                              _selectedHabitation.value = null;
                              _selectedZone.value = null;
                              _selectedZoneWard.value = null;
                              _selectedMunicipality.value = null;
                              _selectedMunicipalityWard.value = null;
                              _selectedTownPanchayat.value = null;
                              _selectedTownPanchayatWard.value = null;
                              _selectedCorporation.value = null;
                              masterProvider.clearDropdowns();
                              if (value != null) {
                                await Future.wait([
                                  masterProvider.fetchCorporations(value.id),
                                  masterProvider.fetchBlocks(value.id),
                                  masterProvider.fetchMunicipalities(value.id),
                                  masterProvider.fetchTownPanchayats(value.id),
                                ]);
                                if (!mounted) return;
                              }
                            },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),
            Consumer<OrganizationProvider>(
              builder: (context, orgProvider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final districtName = _selectedDistrict.value?.districtName;
                  orgProvider.setSelectedDistrictName(districtName);
                });
                return CustomDropdownField<String>(
                  label: context.tr.beneficiaryLabel,
                  value: orgProvider.selectedOrganization,
                  items: orgProvider.organizationItems,
                  hint: orgProvider.organizationItems.isEmpty
                      ? context.tr.loadingData
                      : context.tr.select,
                  itemLabelBuilder: (org) => context.tr.translate(org),
                  onChanged: orgProvider.organizationItems.isEmpty
                      ? null
                      : (value) {
                          orgProvider.selectOrganization(value);
                          _selectedZone.value = null;
                          _selectedZoneWard.value = null;
                          _selectedMunicipality.value = null;
                          _selectedMunicipalityWard.value = null;
                          _selectedTownPanchayat.value = null;
                          _selectedTownPanchayatWard.value = null;
                          _selectedBlock.value = null;
                          _selectedVillage.value = null;
                          _selectedHabitation.value = null;
                          _triggerMaintenanceFetchIfReady(context);
                        },
                );
              },
            ),

            Consumer<OrganizationProvider>(
              builder: (context, orgProvider, _) {
                final selectedOrg = orgProvider.selectedOrganization;

                if (selectedOrg == null || selectedOrg.isEmpty) {
                  return const SizedBox.shrink();
                }
                if (selectedOrg.toUpperCase() == 'CORPORATION') {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final corporationItems = masterProvider.corporations;
                          if (corporationItems.isNotEmpty) {
                          } else {}
                          return ValueListenableBuilder<CorporationModel?>(
                            valueListenable: _selectedCorporation,
                            builder: (context, selected, _) {
                              return CustomDropdownField<CorporationModel>(
                                label: context.tr.organizationCorporation,
                                value: selected,
                                items: corporationItems,
                                hint: corporationItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (corporation) => context.tr
                                    .translate(corporation.corporationName),
                                onChanged: corporationItems.isEmpty
                                    ? null
                                    : (value) async {
                                        _selectedCorporation.value = value;
                                        _selectedZone.value = null;
                                        _selectedZoneWard.value = null;
                                        if (value != null &&
                                            _selectedDistrict.value != null) {
                                          await masterProvider.fetchZones(
                                            _selectedDistrict.value!.id,
                                            value.id,
                                          );
                                        }
                                      },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final zoneItems = masterProvider.zones;
                          return ValueListenableBuilder<ZoneModel?>(
                            valueListenable: _selectedZone,
                            builder: (context, selected, _) {
                              return CustomDropdownField<ZoneModel>(
                                label: context.tr.zoneLabel,
                                value: selected,
                                items: zoneItems,
                                hint: zoneItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (zone) =>
                                    context.tr.translate(zone.zoneName),
                                onChanged: zoneItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedZone.value = value;
                                        _selectedZoneWard.value = null;
                                        if (value != null) {
                                          masterProvider.fetchZoneWards(
                                            value.id,
                                            _selectedDistrict.value!.id,
                                            _selectedCorporation.value!.id,
                                          );
                                          _triggerMaintenanceFetchIfReady(
                                            context,
                                          );
                                        }
                                      },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final zoneWardItems = masterProvider.zoneWards;
                          return ValueListenableBuilder<ZoneWardModel?>(
                            valueListenable: _selectedZoneWard,
                            builder: (context, selected, _) {
                              return CustomDropdownField<ZoneWardModel>(
                                label: context.tr.wardLabel,
                                value: selected,
                                items: zoneWardItems,
                                hint: zoneWardItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (zoneWard) =>
                                    context.tr.translate(zoneWard.zoneWardName),
                                onChanged: zoneWardItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedZoneWard.value = value;
                                        _triggerMaintenanceFetchIfReady(
                                          context,
                                        );
                                      },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
                if (selectedOrg.toUpperCase() == 'MUNICIPALITY') {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final municipalityItems =
                              masterProvider.municipalities;
                          return ValueListenableBuilder<MunicipalityModel?>(
                            valueListenable: _selectedMunicipality,
                            builder: (context, selected, _) {
                              return CustomDropdownField<MunicipalityModel>(
                                label: context.tr.municipalityLabel,
                                value: selected,
                                items: municipalityItems,
                                hint: municipalityItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (municipality) => context.tr
                                    .translate(municipality.municipalityName),
                                onChanged: municipalityItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedMunicipality.value = value;
                                        _selectedMunicipalityWard.value = null;
                                        if (value != null) {
                                          masterProvider.fetchMunicipalityWards(
                                            value.id,
                                          );
                                          _triggerMaintenanceFetchIfReady(
                                            context,
                                          );
                                        }
                                      },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final municipalityWardItems =
                              masterProvider.municipalityWards;
                          return ValueListenableBuilder<MunicipalityWardModel?>(
                            valueListenable: _selectedMunicipalityWard,
                            builder: (context, selected, _) {
                              return CustomDropdownField<MunicipalityWardModel>(
                                label: context.tr.wardLabel,
                                value: selected,
                                items: municipalityWardItems,
                                hint: municipalityWardItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (municipalityWard) =>
                                    context.tr.translate(
                                      municipalityWard.municipalityWardName,
                                    ),
                                onChanged: municipalityWardItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedMunicipalityWard.value = value;
                                        _triggerMaintenanceFetchIfReady(
                                          context,
                                        );
                                      },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
                if (selectedOrg.toUpperCase() == 'TOWN PANCHAYAT') {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final townPanchayatItems =
                              masterProvider.townPanchayats;
                          return ValueListenableBuilder<TownPanchayatModel?>(
                            valueListenable: _selectedTownPanchayat,
                            builder: (context, selected, _) {
                              return CustomDropdownField<TownPanchayatModel>(
                                label: context.tr.townpanchayatLabel,
                                value: selected,
                                items: townPanchayatItems,
                                hint: townPanchayatItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (townPanchayat) => context.tr
                                    .translate(townPanchayat.townPanchayatName),
                                onChanged: townPanchayatItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedTownPanchayat.value = value;
                                        _selectedTownPanchayatWard.value = null;
                                        if (value != null) {
                                          masterProvider
                                              .fetchTownPanchayatWards(
                                                value.id,
                                              );
                                          _triggerMaintenanceFetchIfReady(
                                            context,
                                          );
                                        }
                                      },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final townPanchayatWardItems =
                              masterProvider.townPanchayatWards;
                          return ValueListenableBuilder<
                            TownPanchayatWardModel?
                          >(
                            valueListenable: _selectedTownPanchayatWard,
                            builder: (context, selected, _) {
                              return CustomDropdownField<
                                TownPanchayatWardModel
                              >(
                                label: context.tr.wardLabel,
                                value: selected,
                                items: townPanchayatWardItems,
                                hint: townPanchayatWardItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (townPanchayatWard) =>
                                    context.tr.translate(
                                      townPanchayatWard.townPanchayatWardName,
                                    ),
                                onChanged: townPanchayatWardItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedTownPanchayatWard.value =
                                            value;
                                        _triggerMaintenanceFetchIfReady(
                                          context,
                                        );
                                      },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
                if (selectedOrg.toUpperCase() == 'PANCHAYAT' ||
                    selectedOrg.toUpperCase() == 'VILLAGE PANCHAYAT') {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final blockItems = masterProvider.blocks;
                          return ValueListenableBuilder<BlockModel?>(
                            valueListenable: _selectedBlock,
                            builder: (context, selected, _) {
                              return CustomDropdownField<BlockModel>(
                                label: context.tr.blockLabel,
                                value: selected,
                                items: blockItems,
                                hint: blockItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (block) =>
                                    context.tr.translate(block.blockName),
                                onChanged: blockItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedBlock.value = value;
                                        _selectedVillage.value = null;
                                        _selectedHabitation.value = null;
                                        if (value != null) {
                                          masterProvider.fetchVillages(
                                            value.id,
                                          );
                                        }
                                        _triggerMaintenanceFetchIfReady(
                                          context,
                                        );
                                      },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final villageItems = masterProvider.villages;
                          return ValueListenableBuilder<VillageModel?>(
                            valueListenable: _selectedVillage,
                            builder: (context, selected, _) {
                              return CustomDropdownField<VillageModel>(
                                label: context.tr.villageLabel,
                                value: selected,
                                items: villageItems,
                                hint: villageItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (village) =>
                                    context.tr.translate(village.villageName),
                                onChanged: villageItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedVillage.value = value;
                                        _selectedHabitation.value = null;
                                        if (value != null) {
                                          masterProvider.fetchHabitations(
                                            value.id,
                                          );
                                        }
                                        _triggerMaintenanceFetchIfReady(
                                          context,
                                        );
                                      },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<MasterListProvider>(
                        builder: (context, masterProvider, child) {
                          final habitationItems = masterProvider.habitations;
                          return ValueListenableBuilder<HabitationModel?>(
                            valueListenable: _selectedHabitation,
                            builder: (context, selected, _) {
                              return CustomDropdownField<HabitationModel>(
                                label: context.tr.habbinationLabel,
                                value: selected,
                                items: habitationItems,
                                hint: habitationItems.isEmpty
                                    ? context.tr.loadingData
                                    : context.tr.select,
                                itemLabelBuilder: (habitation) => context.tr
                                    .translate(habitation.habitationName),
                                onChanged: habitationItems.isEmpty
                                    ? null
                                    : (value) {
                                        _selectedHabitation.value = value;
                                        _triggerMaintenanceFetchIfReady(
                                          context,
                                        );
                                      },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            Consumer2<MasterListProvider, MaintenanceProvider>(
              builder: (context, masterProvider, maintenanceProvider, child) {
                final subComplaintItems = masterProvider.subComplaintTypes;

                return ValueListenableBuilder<ComplaintSubTypeModel?>(
                  valueListenable: _selectedSubComplaintType,
                  builder: (context, selected, _) {
                    return CustomDropdownField<ComplaintSubTypeModel>(
                      label: context.tr.complaintCategoryLabel,
                      value: selected,
                      items: subComplaintItems,
                      hint: subComplaintItems.isEmpty
                          ? context.tr.noDataFound
                          : context.tr.select,
                      itemLabelBuilder: (subComplaint) =>
                          context.tr.translate(subComplaint.complaintSubType),
                      onChanged: subComplaintItems.isEmpty
                          ? null
                          : (value) {
                              _selectedSubComplaintType.value = value;
                              _triggerMaintenanceFetchIfReady(context);
                              if (value != null) {
                                final masterProvider =
                                    Provider.of<MasterListProvider>(
                                      context,
                                      listen: false,
                                    );
                               
                                String assignType = value.assignType
                                    .toLowerCase()
                                    .trim();
                                GrievanceTypeModel? matchingGrievanceType;

                                if (assignType == 'single') {
                                  matchingGrievanceType = masterProvider
                                      .grievanceTypes
                                      .where(
                                        (gt) => gt.grievanceType
                                            .toLowerCase()
                                            .contains('individual complaint'),
                                      )
                                      .firstOrNull;
                                } else if (assignType == 'multiple') {
                                  matchingGrievanceType = masterProvider
                                      .grievanceTypes
                                      .where(
                                        (gt) => gt.grievanceType
                                            .toLowerCase()
                                            .contains('public complaint'),
                                      )
                                      .firstOrNull;
                                }

                                if (matchingGrievanceType != null) {
                                  _selectedGrievanceType.value =
                                      matchingGrievanceType;
                                } else {}
                              }
                            },
                    );
                  },
                );
              },
            ),
            SizedBox(height: 16),
            Consumer<MasterListProvider>(
              builder: (context, masterProvider, child) {
                final grievanceTypeItems = masterProvider.grievanceTypes;
                return ValueListenableBuilder<GrievanceTypeModel?>(
                  valueListenable: _selectedGrievanceType,
                  builder: (context, selected, _) {
                    return CustomDropdownField<GrievanceTypeModel>(
                      label: context.tr.grievanceTypeLabel,
                      value: selected,
                      items: grievanceTypeItems,
                      hint: grievanceTypeItems.isEmpty
                          ? context.tr.noDataFound
                          : context.tr.select,
                      itemLabelBuilder: (grievanceType) =>
                          context.tr.translate(grievanceType.grievanceType),
                      onChanged: grievanceTypeItems.isEmpty
                          ? null
                          : (value) {
                              _selectedGrievanceType.value = value;
                              _selectedBlock.value = null;
                              _selectedVillage.value = null;
                              _selectedHabitation.value = null;
                            },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFormField(
              label: context.tr.grievance,
              controller: _complaintController,
              maxLines: 5,
              hintText: context.tr.descriptionhint,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr.complaintisrequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildFileUploadButton(),
            ValueListenableBuilder<List<PlatformFile>>(
              valueListenable: _uploadedFiles,
              builder: (context, files, _) {
                if (files.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      context.tr.uploadedFiles,
                      style: AppConstants.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...List.generate(files.length, (index) {
                      final file = files[index];
                      final uploadProvider = Provider.of<UploadProvider>(
                        context,
                        listen: false,
                      );
                      final relativePath =
                          uploadProvider.relativePaths.length > index
                          ? uploadProvider.relativePaths[index]
                          : null;

                      final isImage = (file.extension?.toLowerCase() ?? "")
                          .contains(RegExp(r'jpg|jpeg|png|gif'));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: isImage && file.bytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        file.bytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      _getFileIcon(file.extension),
                                      size: 30,
                                      color: _getFileColor(file.extension),
                                    ),
                            ),

                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getFileColor(
                                            file.extension,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          (file.extension ?? 'FILE')
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: _getFileColor(
                                              file.extension,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatFileSize(file.size),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Provider.of<UploadProvider>(
                                      context,
                                      listen: false,
                                    ).viewFile(context, file);
                                  },
                                  tooltip: 'View file',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (relativePath != null) {
                                      Provider.of<UploadProvider>(
                                        context,
                                        listen: false,
                                      ).deleteFile(relativePath);
                                    }
                                    final currentFiles =
                                        List<PlatformFile>.from(
                                          _uploadedFiles.value,
                                        );
                                    currentFiles.removeAt(index);
                                    _uploadedFiles.value = currentFiles;

                                    final currentLinks = List<String>.from(
                                      _uploadedFileLinks.value,
                                    );
                                    if (index < currentLinks.length) {
                                      currentLinks.removeAt(index);
                                      _uploadedFileLinks.value = currentLinks;
                                    }

                                    _showSnackBar(
                                      context.tr.filedeletedsuccess,
                                      Colors.green,
                                    );
                                  },
                                  tooltip: 'Delete file',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.tr.locationDetail, Icons.location_on),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.mapSentence,
                  style: AppConstants.bodyTextStyle.copyWith(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isGettingLocation,
                        builder: (context, isGettingLocation, _) {
                          return ElevatedButton.icon(
                            onPressed: isGettingLocation
                                ? null
                                : _getCurrentLocationForDisplay,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                            ),
                            icon: isGettingLocation
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isGettingLocation
                                    ? context.tr.getLocation
                                    : context.tr.currentLocation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<double?>(
                        valueListenable: _selectedLatitude,
                        builder: (context, lat, _) {
                          return ValueListenableBuilder<double?>(
                            valueListenable: _selectedLongitude,
                            builder: (context, lng, _) {
                              return ElevatedButton.icon(
                                onPressed: (lat == null || lng == null)
                                    ? null
                                    : _clearLocation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                ),
                                icon: const Icon(Icons.clear, size: 18),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    context.tr.clearLocation,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<double?>(
                  valueListenable: _selectedLatitude,
                  builder: (context, lat, _) {
                    return ValueListenableBuilder<double?>(
                      valueListenable: _selectedLongitude,
                      builder: (context, lng, _) {
                        if (lat != null && lng != null) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            width:double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.tr.locationSelect,
                                        style: AppConstants.bodyTextStyle
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[800],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 160,
                                  child: FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${context.tr.latitude}: ${lat.toStringAsFixed(6)}',
                                      style: AppConstants.bodyTextStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 160,
                                  child: FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${context.tr.longitude}: ${lng.toStringAsFixed(6)}',
                                      style: AppConstants.bodyTextStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    context.tr.noLocation,
                                    style: AppConstants.bodyTextStyle.copyWith(
                                      fontSize: 14,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr.selectLocation,
                  style: AppConstants.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildOpenStreetMap(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 ${context.tr.locationMap}',
                  style: AppConstants.bodyTextStyle.copyWith(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenStreetMap() {
    return ValueListenableBuilder<double?>(
      valueListenable: _selectedLatitude,
      builder: (context, lat, _) {
        return ValueListenableBuilder<double?>(
          valueListenable: _selectedLongitude,
          builder: (context, lng, _) {
            final defaultLocation = LatLng(13.0827, 80.2707);
            final currentLocation = lat != null && lng != null
                ? LatLng(lat, lng)
                : defaultLocation;

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: currentLocation,
                zoom: lat != null && lng != null ? 15.0 : 10.0,
                onTap: (tapPosition, point) {
                  _onMapTap(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.twad',
                ),
                MarkerLayer(markers: _buildOpenStreetMarkers(lat, lng)),
              ],
            );
          },
        );
      },
    );
  }

  List<Marker> _buildOpenStreetMarkers(double? lat, double? lng) {
    if (lat == null || lng == null) return [];

    return [
      Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(lat, lng),
        builder: (ctx) =>
            const Icon(Icons.location_pin, color: Colors.red, size: 40.0),
      ),
    ];
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppConstants.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: AppConstants.inputDecoration.copyWith(hintText: hintText),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFileUploadButton() {
    return ValueListenableBuilder<List<PlatformFile>>(
      valueListenable: _uploadedFiles,
      builder: (context, files, _) {
        const maxFiles = 5;
        final currentCount = files.length;
        final isMaxReached = currentCount >= maxFiles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isMaxReached
                    ? null
                    : () {
                        _showFilePickerOptions(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMaxReached
                      ? Colors.grey
                      : AppConstants.submitbuttoncolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  isMaxReached
                      ? 'Maximum Files Reached'
                      : context.tr.chooseFileButton,
                  style: AppConstants.buttonTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String? extension) {
    if (extension == null) return Colors.grey;

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'txt':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _clearForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              context.tr.clearButton,
              style: AppConstants.buttonTextStyle.copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer2<GrievanceProvider, MaintenanceProvider>(
            builder: (context, grievanceProvider, maintenanceProvider, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: _hasMaintenanceWork,
                builder: (context, hasMaintenance, _) {
                  final isDisabled =
                      grievanceProvider.isSubmitting || hasMaintenance;

                  return ElevatedButton(
                    onPressed: isDisabled ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDisabled
                          ? Colors.grey
                          : AppConstants.submitbuttoncolor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: grievanceProvider.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                context.tr.submitButton,
                                style: AppConstants.buttonTextStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
