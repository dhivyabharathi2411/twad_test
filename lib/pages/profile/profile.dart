import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:twad/data/models/block_list_model.dart';
import 'package:twad/data/models/corporation_model.dart';
import 'package:twad/data/models/district_list_model.dart';
import 'package:twad/data/models/habitation_list.dart';
import 'package:twad/data/models/municipality_model.dart';
import 'package:twad/data/models/municipality_ward_model.dart';
import 'package:twad/data/models/town_panchayat_model.dart';
import 'package:twad/data/models/town_panchayat_ward_model.dart';
import 'package:twad/data/models/user_model.dart';
import 'package:twad/data/models/village_list_model.dart';
import 'package:twad/data/models/zone_model.dart';
import 'package:twad/data/models/zone_ward_model.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/pages/home_screen.dart';
import 'package:twad/pages/newgrievance/newgrievance.dart';
import 'package:twad/presentation/providers/locale_provider.dart';
import 'package:twad/pages/profile/widgets/formfield.dart';
import 'package:twad/pages/profile/widgets/dropdownfield.dart';
import 'package:twad/presentation/providers/organization_provider.dart';
import 'package:twad/services/user_profile_service.dart';
import '../../constants/app_constants.dart';
import '../../presentation/providers/master_list_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/app_utils.dart';
import '../../utils/simple_encryption.dart';
import 'profile_provider.dart';

class ProfilePage extends StatefulWidget {
  final UserModel? user;
  final ValueNotifier<String> displayedUserName;
  const ProfilePage({super.key, this.user, required this.displayedUserName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSavingProfile = false;

  late UserModel _currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final UserProfileService _userProfileService;
  final ValueNotifier<bool> _isLoggingOut = ValueNotifier<bool>(false);
  Future<UserModel>? _profileFuture;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _pincodeController;

  bool _isFormInitialized = false;
  UserModel? _fetchedUserData;

  bool _hasUserEditedData = false;
  bool _isDropdownsPrefilled = false;
  final ValueNotifier<bool> _isLoadingProfile = ValueNotifier<bool>(false);
  final ValueNotifier<DistrictModel?> _selectedDistrict =
      ValueNotifier<DistrictModel?>(null);
  final ValueNotifier<CorporationModel?> _selectedCorporation =
      ValueNotifier<CorporationModel?>(null);
  final ValueNotifier<BlockModel?> _selectedBlock = ValueNotifier<BlockModel?>(
    null,
  );
  final ValueNotifier<VillageModel?> _selectedVillage =
      ValueNotifier<VillageModel?>(null);
  final ValueNotifier<HabitationModel?> _selectedHabitation =
      ValueNotifier<HabitationModel?>(null);
  final ValueNotifier<ZoneModel?> _selectedZone = ValueNotifier<ZoneModel?>(
    null,
  );
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
  List<String> get _organizations {
    final districtName =
        _selectedDistrict.value?.districtName.toUpperCase() ?? '';
    final allowedCorporationDistricts = [
      "CHENNAI",
      "COIMBATORE",
      "MADURAI",
      "TIRUCHIRAPPALLI",
      "SALEM",
      "TIRUPPUR",
      "ERODE",
      "TIRUNELVELI",
      "VELLORE",
      "THOOTHUKUDI",
      "DINDIGUL",
      "THANJAVUR",
      "HOSUR",
      "NAGERCOIL",
      "AVADI",
      "TAMBARAM",
      "KANCHIPURAM",
      "CUDDALORE",
      "KARUR",
      "KUMBAKONAM",
      "SIVAKASI",
      "PUDUKOTTAI",
      "KARAIKUDI",
      "TIRUVANNAMALAI",
      "NAMAKKAL",
      "TIRUVALLUR",
    ];

    final orgs = <String>[];
    if (allowedCorporationDistricts.contains(districtName)) {
      orgs.add('CORPORATION');
    }
    orgs.addAll(['MUNICIPALITY', 'TOWN PANCHAYAT', 'PANCHAYAT']);
    return orgs;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final masterProvider = Provider.of<MasterListProvider>(
        context,
        listen: false,
      );

      if (masterProvider.districts.isEmpty) {
        masterProvider.fetchDistricts();
      }

      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      await Future.delayed(Duration(milliseconds: 100));
      if (!profileProvider.isprofileUpated) {
        profileProvider.setEditing(true);
      }
    });
    _selectedDistrict.addListener(_onDistrictChanged);

    _initializeUser();
    _initializeControllers();
    _addControllerListeners();
    _initializeServices();
    _loadUserName();

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    _isLoadingProfile.value = true;
    _profileFuture = profileProvider.loadUserProfileIfNeeded(_fetchUserProfile);
    _profileFuture!.then((user) {
      _fetchedUserData = user;
      _isLoadingProfile.value = false;
    });
  }

  void _onDistrictChanged() {
    final organizationProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final districtName = _selectedDistrict.value?.districtName;
    organizationProvider.setSelectedDistrictName(districtName);
  }

  Future<void> _loadUserName() async {
    final userData = await SimpleUsage.getCurrentUser();
    if (userData != null && userData['name'] != null) {}
  }

  void _initializeUser() {
    _currentUser =
        widget.user ??
        const UserModel(
          id: '21',
          name: 'King',
          contactno: '8148471303',
          emailid: 'boo7@gmail.com',
          districtName: 'Coimbatore',
          organisationName: '',
          isActive: true,
        );
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _contactController = TextEditingController();
    _addressController = TextEditingController();
    _pincodeController = TextEditingController();
  }

  void _addControllerListeners() {
    _nameController.addListener(_onFormFieldChanged);
    _emailController.addListener(_onFormFieldChanged);
    _contactController.addListener(_onFormFieldChanged);
    _addressController.addListener(_onFormFieldChanged);
    _pincodeController.addListener(_onFormFieldChanged);
  }

  void _setControllersFromUser(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.emailid;
    _contactController.text = user.contactno;
    _addressController.text = user.address ?? '';
    _pincodeController.text = user.pincode ?? '';
  }

  void _onFormFieldChanged() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    if (profileProvider.isEditing) {
      _hasUserEditedData = true;
    }
  }

  void _initializeServices() {
    try {
      _userProfileService = UserProfileService();
    } catch (e) {
      _userProfileService = UserProfileService();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _isLoggingOut.dispose();
    _isLoadingProfile.dispose();
    _selectedDistrict.dispose();
    _selectedBlock.dispose();
    _selectedVillage.dispose();
    _selectedHabitation.dispose();
    _selectedZone.dispose();
    _selectedZoneWard.dispose();
    _selectedMunicipality.dispose();
    _selectedMunicipalityWard.dispose();
    _selectedTownPanchayat.dispose();
    _selectedTownPanchayatWard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(),
                        SizedBox(height: 16),
                        Consumer<ProfileProvider>(
                          builder: (context, profileProvider, _) {
                            return _buildProfileInformationSection(
                              profileProvider,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr.profilePageTitle,
                style: AppConstants.titleStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    context.tr.setting,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    context.tr.profileSettings,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInformationSection(ProfileProvider profileProvider) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingProfile,
      builder: (context, isLoading, _) {
        if (isLoading && _fetchedUserData == null) {
          return _buildProfileShimmer();
        }
        if (_fetchedUserData != null && !isLoading) {
          return _buildProfileForm(profileProvider, _fetchedUserData!);
        }
        return FutureBuilder<UserModel>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildProfileShimmer();
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: AppConstants.bodyTextStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error.toString()}',
                      style: AppConstants.bodyTextStyle.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        profileProvider.refresh();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            UserModel user = snapshot.data ?? _currentUser;
            _fetchedUserData = user;

            return _buildProfileForm(profileProvider, user);
          },
        );
      },
    );
  }

  Widget _buildProfileForm(ProfileProvider profileProvider, UserModel user) {
    _handleUserDataInitialization(profileProvider, user);
    return Column(
      children: [
        Consumer<LocaleProvider>(
          builder: (context, localeProvider, _) {
            return _buildFormContent(profileProvider, user);
          },
        ),
      ],
    );
  }

  Widget _buildProfileShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerSection("Basic Information"),
          const SizedBox(height: 16),
          _buildShimmerFormField(),
          const SizedBox(height: 16),
          _buildShimmerFormField(),
          const SizedBox(height: 16),
          _buildShimmerFormField(),
          const SizedBox(height: 24),

          _buildShimmerSection("Contact Information"),
          const SizedBox(height: 16),
          _buildShimmerFormField(),
          const SizedBox(height: 16),
          _buildShimmerFormField(),
          const SizedBox(height: 24),

          _buildShimmerSection("Location Information"),
          const SizedBox(height: 16),
          _buildShimmerDropdown(),
          const SizedBox(height: 16),
          _buildShimmerDropdown(),
          const SizedBox(height: 16),
          _buildShimmerDropdown(),
          const SizedBox(height: 16),
          _buildShimmerDropdown(),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSection(String title) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 24,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildShimmerFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 16,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(ProfileProvider profileProvider, UserModel user) {
    return TWADCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr.profileInformation,
                    style: AppConstants.titleStyle.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!profileProvider.isEditing &&
                    profileProvider.isprofileUpated)
                  GestureDetector(
                    onTap: () => profileProvider.toggleEditMode(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.editBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        context.tr.editProfile,
                        style: AppConstants.bodyTextStyle.copyWith(
                          color: AppConstants.grievanceText,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ProfileFormField(
                  label: context.tr.phnoLable,
                  controller: _contactController,
                  isEnabled: false,
                  inputFormatters: [],
                  hintText: context.tr.hintcontact,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.contactNumberRequired;
                    }
                    if (!AppUtils.isValidPhone(value)) {
                      return context.tr.validContactNumber;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                ProfileFormField(
                  label: context.tr.nameLabel,
                  controller: _nameController,
                  inputFormatters: [],
                  isEnabled: profileProvider.isEditing,
                  hintText: context.tr.hintname,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ProfileFormField(
                  label: context.tr.mailIdLabel,
                  controller: _emailController,
                  isEnabled: profileProvider.isEditing,
                  inputFormatters: [],
                  hintText: context.tr.hintEmail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.hintEmail;
                    }
                    if (!AppUtils.isValidEmail(value)) {
                      return context.tr.validEmail;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Consumer2<MasterListProvider, OrganizationProvider>(
                  builder: (context, masterProvider, organizationprovider, child) {
                    final districtItems = masterProvider.districts;
                    return ValueListenableBuilder<DistrictModel?>(
                      valueListenable: _selectedDistrict,
                      builder: (context, selected, _) {
                        return ProfileDropdownField<DistrictModel>(
                          label: context.tr.gistrictLabel,
                          value: selected,
                          items: districtItems,
                          hint: districtItems.isEmpty
                              ? (_isLoadingProfile.value
                                    ? context.tr.loadingData
                                    : context.tr.noDataFound)
                              : context.tr.select,
                          itemLabelBuilder: (district) =>
                              context.tr.translate(district.districtName),
                          isEnabled: profileProvider.isEditing,
                          onChanged: districtItems.isEmpty
                              ? null
                              : (value) async {
                                  _selectedDistrict.value = value;
                                  _selectedCorporation.value = null;
                                  _selectedBlock.value = null;
                                  _selectedVillage.value = null;
                                  _selectedHabitation.value = null;
                                  _selectedZone.value = null;
                                  _selectedZoneWard.value = null;
                                  _selectedMunicipality.value = null;
                                  _selectedMunicipalityWard.value = null;
                                  _selectedTownPanchayat.value = null;
                                  _selectedTownPanchayatWard.value = null;
                                    profileProvider.setSelectedOrganization('');

                                  if (value != null) {
                                    await Future.wait([
                                      masterProvider.fetchBlocks(value.id),
                                      masterProvider.fetchCorporations(
                                        value.id,
                                      ),
                                      masterProvider.fetchMunicipalities(
                                        value.id,
                                      ),
                                      masterProvider.fetchTownPanchayats(
                                        value.id,
                                      ),
                                    ]);
                                  }
                                },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                ValueListenableBuilder<DistrictModel?>(
                  valueListenable: _selectedDistrict,
                  builder: (context, selectedDistrict, _) {
                    final orgItems = [
                      ..._organizations,
                    ].map((org) => context.tr.translate(org)).toList();
                    final selectedOrganization =
                        profileProvider.selectedOrganization;
                    final SafeOrganization = selectedOrganization.isNotEmpty
                        ? context.tr.translate(selectedOrganization)
                        : null;
                    return ProfileDropdownField(
                      label: context.tr.beneficiaryLabel,
                      value: SafeOrganization,
                      hint: context.tr.warningOrganization,
                      items: orgItems,
                      isEnabled: profileProvider.isEditing,
                      onChanged: (value) {
                        if (value != null &&
                            value != context.tr.warningOrganization) {
                          final originalValue = _organizations.firstWhere(
                            (org) => context.tr.translate(org) == value,
                            orElse: () => value,
                          );
                          profileProvider.setSelectedOrganization(
                            originalValue,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (profileProvider.selectedOrganization == 'CORPORATION') ...[
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final corporationItems = masterProvider.corporations;
                      return ValueListenableBuilder<CorporationModel?>(
                        valueListenable: _selectedCorporation,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<CorporationModel>(
                            label: context.tr.organizationCorporation,
                            value: selected,
                            items: corporationItems,
                            hint: corporationItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (corporation) => context.tr
                                .translate(corporation.corporationName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: corporationItems.isEmpty
                                ? null
                                : (value) async {
                                    _selectedCorporation.value = value;
                                    _selectedZone.value = null;
                                    _selectedZoneWard.value = null;
                                    await _saveCorporationSelection();
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
                  const SizedBox(height: 20),
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final zoneItems = masterProvider.zones;
                      return ValueListenableBuilder<ZoneModel?>(
                        valueListenable: _selectedZone,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<ZoneModel>(
                            label: context.tr.zoneLabel,
                            value: selected,
                            items: zoneItems,
                            hint: zoneItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (zone) =>
                                context.tr.translate(zone.zoneName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: zoneItems.isEmpty
                                ? null
                                : (value) async {
                                    _selectedZone.value = value;
                                    _selectedZoneWard.value = null;
                                    if (value != null) {
                                      await masterProvider.fetchZoneWards(
                                        value.id,
                                        _selectedDistrict.value!.id,
                                        _selectedCorporation.value!.id,
                                      );
                                    }
                                  },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final zoneWardItems = masterProvider.zoneWards;
                      return ValueListenableBuilder<ZoneWardModel?>(
                        valueListenable: _selectedZoneWard,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<ZoneWardModel>(
                            label: context.tr.wardLabel,
                            value: selected,
                            items: zoneWardItems,
                            hint: zoneWardItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (ward) =>
                                context.tr.translate(ward.zoneWardName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: zoneWardItems.isEmpty
                                ? null
                                : (value) {
                                    _selectedZoneWard.value = value;
                                  },
                          );
                        },
                      );
                    },
                  ),
                ] else if (profileProvider.selectedOrganization ==
                    'MUNICIPALITY') ...[
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final municipalityItems = masterProvider.municipalities;
                      return ValueListenableBuilder<MunicipalityModel?>(
                        valueListenable: _selectedMunicipality,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<MunicipalityModel>(
                            label: context.tr.municipalityLabel,
                            value: selected,
                            items: municipalityItems,
                            hint: municipalityItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (municipality) => context.tr
                                .translate(municipality.municipalityName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: municipalityItems.isEmpty
                                ? null
                                : (value) async {
                                    _selectedMunicipality.value = value;
                                    _selectedMunicipalityWard.value = null;
                                    if (value != null) {
                                      await masterProvider
                                          .fetchMunicipalityWards(value.id);
                                    }
                                  },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final municipalityWardItems =
                          masterProvider.municipalityWards;
                      return ValueListenableBuilder<MunicipalityWardModel?>(
                        valueListenable: _selectedMunicipalityWard,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<MunicipalityWardModel>(
                            label: context.tr.wardLabel,
                            value: selected,
                            items: municipalityWardItems,
                            hint: municipalityWardItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (ward) =>
                                context.tr.translate(ward.municipalityWardName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: municipalityWardItems.isEmpty
                                ? null
                                : (value) {
                                    _selectedMunicipalityWard.value = value;
                                  },
                          );
                        },
                      );
                    },
                  ),
                ] else if (profileProvider.selectedOrganization ==
                    'TOWN PANCHAYAT') ...[
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final townPanchayatItems = masterProvider.townPanchayats;
                      return ValueListenableBuilder<TownPanchayatModel?>(
                        valueListenable: _selectedTownPanchayat,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<TownPanchayatModel>(
                            label: context.tr.townpanchayatLabel,
                            value: selected,
                            items: townPanchayatItems,
                            hint: townPanchayatItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (townPanchayat) => context.tr
                                .translate(townPanchayat.townPanchayatName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: townPanchayatItems.isEmpty
                                ? null
                                : (value) async {
                                    _selectedTownPanchayat.value = value;
                                    _selectedTownPanchayatWard.value = null;
                                    if (value != null) {
                                      await masterProvider
                                          .fetchTownPanchayatWards(value.id);
                                    }
                                  },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final townPanchayatWardItems =
                          masterProvider.townPanchayatWards;
                      return ValueListenableBuilder<TownPanchayatWardModel?>(
                        valueListenable: _selectedTownPanchayatWard,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<TownPanchayatWardModel>(
                            label: context.tr.wardLabel,
                            value: selected,
                            items: townPanchayatWardItems,
                            hint: townPanchayatWardItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (ward) => context.tr.translate(
                              ward.townPanchayatWardName,
                            ),
                            isEnabled: profileProvider.isEditing,
                            onChanged: townPanchayatWardItems.isEmpty
                                ? null
                                : (value) {
                                    _selectedTownPanchayatWard.value = value;
                                  },
                          );
                        },
                      );
                    },
                  ),
                ] else if (profileProvider.selectedOrganization ==
                        'PANCHAYAT' ||
                    profileProvider.selectedOrganization ==
                        'VILLAGE PANCHAYAT') ...[
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final blockItems = masterProvider.blocks;
                      return ValueListenableBuilder<BlockModel?>(
                        valueListenable: _selectedBlock,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<BlockModel>(
                            label: context.tr.blockLabel,
                            value: selected,
                            items: blockItems,
                            hint: blockItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (block) =>
                                context.tr.translate(block.blockName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: blockItems.isEmpty
                                ? null
                                : (value) {
                                    _selectedBlock.value = value;
                                    _selectedVillage.value = null;
                                    _selectedHabitation.value = null;
                                    if (value != null) {
                                      masterProvider.fetchVillages(value.id);
                                    }
                                  },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final villageItems = masterProvider.villages;
                      return ValueListenableBuilder<VillageModel?>(
                        valueListenable: _selectedVillage,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<VillageModel>(
                            label: context.tr.villageLabel,
                            value: selected,
                            items: villageItems,
                            hint: villageItems.isEmpty
                                ? (_isLoadingProfile.value
                                      ? context.tr.loadingData
                                      : context.tr.noDataFound)
                                : context.tr.select,
                            itemLabelBuilder: (village) =>
                                context.tr.translate(village.villageName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: villageItems.isEmpty
                                ? null
                                : (value) {
                                    _selectedVillage.value = value;
                                    _selectedHabitation.value = null;

                                    if (value != null) {
                                      masterProvider.fetchHabitations(value.id);
                                    }
                                  },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterListProvider>(
                    builder: (context, masterProvider, child) {
                      final habitationItems = masterProvider.habitations;
                      return ValueListenableBuilder<HabitationModel?>(
                        valueListenable: _selectedHabitation,
                        builder: (context, selected, _) {
                          return ProfileDropdownField<HabitationModel>(
                            label: context.tr.habbinationLabel,
                            value: selected,
                            items: habitationItems,
                            hint: habitationItems.isEmpty
                                ? context.tr.noDataFound
                                : context.tr.select,
                            itemLabelBuilder: (habitation) =>
                                context.tr.translate(habitation.habitationName),
                            isEnabled: profileProvider.isEditing,
                            onChanged: habitationItems.isEmpty
                                ? null
                                : (value) {
                                    _selectedHabitation.value = value;
                                  },
                          );
                        },
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ProfileFormField(
                  label: context.tr.addressLabel,
                  controller: _addressController,
                  isEnabled: profileProvider.isEditing,
                  inputFormatters: [],
                  hintText: context.tr.hintAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.addressRequired;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20),
                ProfileFormField(
                  label: context.tr.pincodeLabel,
                  controller: _pincodeController,
                  isEnabled: profileProvider.isEditing,
                  hintText: context.tr.hintPincode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr.pincodeRequired;
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'Pincode must be exactly 6 digits';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                if (profileProvider.isEditing) ...[
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSavingProfile
                              ? null
                              : () => _cancelEdit(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(context.tr.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSavingProfile
                              ? null
                              : () => _saveProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSavingProfile
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.tr.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleUserDataInitialization(
    ProfileProvider profileProvider,
    UserModel user,
  ) {
    if ((!profileProvider.isEditing && !_isFormInitialized) ||
        (!_hasUserEditedData && _fetchedUserData != null)) {
      _isFormInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setControllersFromUser(user);
        _updateDropdownsFromUserData(user);
      });
    }
  }

  void _updateDropdownsFromUserData(UserModel user) {
    if (!_isDropdownsPrefilled) {
      _isDropdownsPrefilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final masterProvider = Provider.of<MasterListProvider>(
          context,
          listen: false,
        );
        final profileProvider = Provider.of<ProfileProvider>(
          context,
          listen: false,
        );
        if (user.organisationName?.isNotEmpty == true) {
          profileProvider.setSelectedOrganization(
            user.organisationName!.toUpperCase(),
          );
        }

        if (user.districtId != null && user.districtId!.isNotEmpty) {
          final districtId = int.tryParse(user.districtId!);
          if (districtId != null) {
            final matchingDistrict = masterProvider.districts
                .where((d) => d.id == districtId)
                .firstOrNull;
            if (matchingDistrict != null) {
              _selectedDistrict.value = matchingDistrict;
              _fetchAllOrganizationDataForDistrict(
                masterProvider,
                districtId,
                user,
              );
              _prefillBlockAndCascade(masterProvider, user);
            }
          }
        }
      });
    }
  }
  Future<UserModel> _fetchUserProfile() async {
    _isLoadingProfile.value = true;

    try {
      final isLoggedIn = await SimpleUsage.checkLogin();

      if (!isLoggedIn) {
        _isLoadingProfile.value = false;
        return _currentUser;
      }
      final responsedata = await _userProfileService.fetchUserProfile();
      if (responsedata != null) {
        _isLoadingProfile.value = false;
        return responsedata;
      }
    } catch (e) {
      return _currentUser;
    }
    _isLoadingProfile.value = false;
    return _currentUser;
  }

  void _cancelEdit() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final masterProvider = Provider.of<MasterListProvider>(
      context,
      listen: false,
    );

    final userData = _fetchedUserData ?? _currentUser;

    _nameController.text = userData.name;
    _emailController.text = userData.emailid;
    _contactController.text = userData.contactno;
    _addressController.text = userData.address ?? '';
    _pincodeController.text = userData.pincode ?? '';

    _selectedDistrict.value = null;
    _selectedBlock.value = null;
    _selectedVillage.value = null;
    _selectedHabitation.value = null;
    _selectedZone.value = null;
    _selectedCorporation.value = null;
    _selectedZoneWard.value = null;
    _selectedMunicipality.value = null;
    _selectedMunicipalityWard.value = null;
    _selectedTownPanchayat.value = null;
    _selectedTownPanchayatWard.value = null;


    profileProvider.setSelectedOrganization('');

  
    if (userData.districtId != null && userData.districtId!.isNotEmpty) {
      final districtId = int.tryParse(userData.districtId!);
      if (districtId != null) {
        final matchingDistrict = masterProvider.districts
            .where((d) => d.id == districtId)
            .firstOrNull;
        if (matchingDistrict != null) {
          _selectedDistrict.value = matchingDistrict;
        }
      }
    }

    if (userData.organisationName?.isNotEmpty == true) {
      profileProvider.setSelectedOrganization(
        userData.organisationName!.toUpperCase(),
      );
    }

    _isFormInitialized = false;
    _hasUserEditedData = false;
    _isDropdownsPrefilled = false; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreOriginalDropdownValues(userData);
    });

    profileProvider.toggleEditMode();
    profileProvider.setProfileUpdatedTrue();
  }

  void _restoreOriginalDropdownValues(UserModel userData) async {
    final masterProvider = Provider.of<MasterListProvider>(
      context,
      listen: false,
    );
    if (userData.blockId != null && userData.blockId!.isNotEmpty) {
      final blockId = int.tryParse(userData.blockId!);
      if (blockId != null) {
        final matchingBlock = masterProvider.blocks
            .where((b) => b.id == blockId)
            .firstOrNull;
        if (matchingBlock != null) {
          _selectedBlock.value = matchingBlock;
        }
      }
    }
    if (userData.villageId != null && userData.villageId!.isNotEmpty) {
      final villageId = int.tryParse(userData.villageId!);
      if (villageId != null) {
        final matchingVillage = masterProvider.villages
            .where((v) => v.id == villageId)
            .firstOrNull;
        if (matchingVillage != null) {
          _selectedVillage.value = matchingVillage;
        }
      }
    }

    if (userData.habitationId != null && userData.habitationId!.isNotEmpty) {
      final habitationId = int.tryParse(userData.habitationId!);
      if (habitationId != null) {
        final matchingHabitation = masterProvider.habitations
            .where((h) => h.id == habitationId)
            .firstOrNull;
        if (matchingHabitation != null) {
          _selectedHabitation.value = matchingHabitation;
        }
      }
    }
    if (userData.corporationId != null && userData.corporationId!.isNotEmpty) {
      final corporationId = int.tryParse(userData.corporationId!);
      if (corporationId != null) {
        final matchingCorporation = masterProvider.corporations
            .where((c) => c.id == corporationId)
            .firstOrNull;
        if (matchingCorporation != null) {
          _selectedCorporation.value = matchingCorporation;
        }
      }
    }

    if (userData.zoneId != null && userData.zoneId!.isNotEmpty) {
      final zoneId = int.tryParse(userData.zoneId!);
      if (zoneId != null) {
        final matchingZone = masterProvider.zones
            .where((z) => z.id == zoneId)
            .firstOrNull;
        if (matchingZone != null) {
          _selectedZone.value = matchingZone;
        }
      }
    }

    if (userData.zoneWardId != null && userData.zoneWardId!.isNotEmpty) {
      final zoneWardId = int.tryParse(userData.zoneWardId!);
      if (zoneWardId != null) {
        final matchingZoneWard = masterProvider.zoneWards
            .where((zw) => zw.id == zoneWardId)
            .firstOrNull;
        if (matchingZoneWard != null) {
          _selectedZoneWard.value = matchingZoneWard;
        }
      }
    }

    if (userData.municipalityId != null &&
        userData.municipalityId!.isNotEmpty) {
      final municipalityId = int.tryParse(userData.municipalityId!);
      if (municipalityId != null) {
        final matchingMunicipality = masterProvider.municipalities
            .where((m) => m.id == municipalityId)
            .firstOrNull;
        if (matchingMunicipality != null) {
          _selectedMunicipality.value = matchingMunicipality;
        }
      }
    }
    if (userData.municipalityWardId != null &&
        userData.municipalityWardId!.isNotEmpty) {
      final municipalityWardId = int.tryParse(userData.municipalityWardId!);
      if (municipalityWardId != null) {
        final matchingMunicipalityWard = masterProvider.municipalityWards
            .where((mw) => mw.id == municipalityWardId)
            .firstOrNull;
        if (matchingMunicipalityWard != null) {
          _selectedMunicipalityWard.value = matchingMunicipalityWard;
        }
      }
    }

    if (userData.townPanchayatId != null &&
        userData.townPanchayatId!.isNotEmpty) {
      final townPanchayatId = int.tryParse(userData.townPanchayatId!);
      if (townPanchayatId != null) {
        final matchingTownPanchayat = masterProvider.townPanchayats
            .where((tp) => tp.id == townPanchayatId)
            .firstOrNull;
        if (matchingTownPanchayat != null) {
          _selectedTownPanchayat.value = matchingTownPanchayat;
        }
      }
    }

    if (userData.townPanchayatWardId != null &&
        userData.townPanchayatWardId!.isNotEmpty) {
      final townPanchayatWardId = int.tryParse(userData.townPanchayatWardId!);
      if (townPanchayatWardId != null) {
        final matchingTownPanchayatWard = masterProvider.townPanchayatWards
            .where((tpw) => tpw.id == townPanchayatWardId)
            .firstOrNull;
        if (matchingTownPanchayatWard != null) {
          _selectedTownPanchayatWard.value = matchingTownPanchayatWard;
        }
      }
    }
  }

  void _saveProfile() async {
  if (_formKey.currentState!.validate()) {
    if (!_areAllDropdownsSelected()) {
      AppUtils.showSnackBar(
        context,
        context.tr.profilerequirdfields,
        type: SnackBarType.error,
      );
      return; 
    }

    try {
      setState(() {
        _isSavingProfile = true;
      });

      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      final districtId = _selectedDistrict.value?.id;
      final blockId = _selectedBlock.value?.id;
      final villageId = _selectedVillage.value?.id;
      final habitationId = _selectedHabitation.value?.id;
      final address = _addressController.text;
      final pincode = _pincodeController.text;

      final orgName = profileProvider.selectedOrganization.toUpperCase();
      final organizationIdMap = {
        'CORPORATION': 1,
        'MUNICIPALITY': 2,
        'TOWN PANCHAYAT': 3,
        'PANCHAYAT': 4,
      };
      final organisationId = organizationIdMap[orgName] ?? 0;

      int? zoneId, zoneWardId, corporationId, municipalityId, municipalityWardId,
          townPanchayatId, townPanchayatWardId, divisionId;
      int? finalBlockId = blockId, finalVillageId = villageId, finalHabitationId = habitationId;
      if (orgName == 'CORPORATION') {
        corporationId = _selectedCorporation.value?.id ?? 0;
        zoneId = _selectedZone.value?.id ?? 0;
        zoneWardId = _selectedZoneWard.value?.id ?? 0;
        municipalityId = municipalityWardId = townPanchayatId = townPanchayatWardId = divisionId = 0;
        finalBlockId = finalVillageId = finalHabitationId = 0;
      } else if (orgName == 'MUNICIPALITY') {
        municipalityId = _selectedMunicipality.value?.id ?? 0;
        municipalityWardId = _selectedMunicipalityWard.value?.id ?? 0;
        zoneId = zoneWardId = townPanchayatId = townPanchayatWardId = divisionId = 0;
        finalBlockId = finalVillageId = finalHabitationId = 0;
      } else if (orgName == 'TOWN PANCHAYAT') {
        townPanchayatId = _selectedTownPanchayat.value?.id ?? 0;
        townPanchayatWardId = _selectedTownPanchayatWard.value?.id ?? 0;
        zoneId = zoneWardId = municipalityId = municipalityWardId = divisionId = 0;
        finalBlockId = finalVillageId = finalHabitationId = 0;
      } else if (orgName == 'PANCHAYAT') {
        zoneId = zoneWardId = municipalityId = municipalityWardId =
            townPanchayatId = townPanchayatWardId = divisionId = 0;
      } else {
        zoneId = zoneWardId = municipalityId = municipalityWardId =
            townPanchayatId = townPanchayatWardId = divisionId = 0;
        finalBlockId = finalVillageId = finalHabitationId = 0;
      }
      await _userProfileService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _contactController.text,
        address: address,
        pincode: pincode,
        districtId: districtId,
        blockId: finalBlockId,
        villageId: finalVillageId,
        habitationId: finalHabitationId,
        organisationId: organisationId,
        zoneId: zoneId,
        corporationId: corporationId,
        zoneWardId: zoneWardId,
        municipalityId: municipalityId,
        municipalityWardId: municipalityWardId,
        townPanchayatId: townPanchayatId,
        townPanchayatWardId: townPanchayatWardId,
        divisionId: divisionId,
      );
      final updatedUser = await _fetchUserProfile();
      _nameController.text = updatedUser.name;
      _emailController.text = updatedUser.emailid;
      _contactController.text = updatedUser.contactno;
      _addressController.text = updatedUser.address ?? '';
      _pincodeController.text = updatedUser.pincode ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', updatedUser.name);
      await prefs.setString('emailid', updatedUser.emailid);
      await prefs.setString('contactno', updatedUser.contactno);
      await prefs.setString('address', updatedUser.address ?? '');
      await prefs.setString('pincode', updatedUser.pincode ?? '');

      await profileProvider.updateUser(updatedUser);
      await profileProvider.setProfileUpdatedTrue();

      _setControllersFromUser(updatedUser);
      _fetchedUserData = updatedUser;
      _updateDropdownsFromUserData(updatedUser);
      _profileFuture = Future.value(updatedUser);
      _isFormInitialized = false;
      _hasUserEditedData = false;
      profileProvider.setEditing(false);
      widget.displayedUserName.value = updatedUser.name;

      AppUtils.showSnackBar(
        context,
        context.tr.profileUpdated,
        type: SnackBarType.success,
      );

     final userId = updatedUser.id;
      final isFirstTime = prefs.getBool('isProfileSaved_$userId') ?? false;
      if (!isFirstTime) {
        await prefs.setBool('isProfileSaved_$userId', true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewGrievancePage()),
        );
      }
      } catch (e) {
            AppUtils.showSnackBar(
              context,
              'Error updating profile: $e',
              type: SnackBarType.error,
            );
          } finally {
            setState(() {
              _isSavingProfile = false;
            });
          }
        }
      }

  Future<void> _fetchAllOrganizationDataForDistrict(
    MasterListProvider masterProvider,
    int districtId,
    UserModel user,
  ) async {
    try {
      await Future.wait([
        masterProvider.fetchCorporations(districtId),
        masterProvider.fetchMunicipalities(districtId),
        masterProvider.fetchTownPanchayats(districtId),
      ]);
      final orgName = user.organisationName?.toUpperCase();

      if (orgName == 'CORPORATION') {
        _setProfileCorporationData(masterProvider, user);
      } else if (orgName == 'MUNICIPALITY') {
        _setProfileMunicipalityData(masterProvider, user);
      } else if (orgName == 'TOWN PANCHAYAT') {
        _setProfileTownPanchayatData(masterProvider, user);
      } else if (orgName == 'PANCHAYAT') {
        _prefillBlockAndCascade(masterProvider, user);
      }
    } catch (e) {}
  }

  void _setProfileCorporationData(
    MasterListProvider masterProvider,
    UserModel user,
  ) async {
    await _restoreCorporationSelection(masterProvider);
    if (_selectedCorporation.value == null &&
        masterProvider.corporations.isNotEmpty &&
        _selectedDistrict.value != null) {
      CorporationModel? corporationToSet;
      if (user.zoneId != null &&
          user.zoneId!.isNotEmpty &&
          user.zoneId != '0') {
        final zoneIdInt = int.tryParse(user.zoneId!);
        if (zoneIdInt != null) {
          for (final corp in masterProvider.corporations) {
            await masterProvider.fetchZones(
              _selectedDistrict.value!.id,
              corp.id,
            );
            final matchingZone = masterProvider.zones
                .where((z) => z.id == zoneIdInt)
                .firstOrNull;
            if (matchingZone != null) {
              corporationToSet = corp;
              break;
            }
          }
        }
      }

      corporationToSet ??= masterProvider.corporations.first;

      _selectedCorporation.value = corporationToSet;
      await _saveCorporationSelection();
    }

    if (_selectedCorporation.value != null && _selectedDistrict.value != null) {
      await masterProvider.fetchZones(
        _selectedDistrict.value!.id,
        _selectedCorporation.value!.id,
      );

      if (user.zoneId != null &&
          user.zoneId!.isNotEmpty &&
          user.zoneId != '0' &&
          masterProvider.zones.isNotEmpty) {
        final zoneIdInt = int.tryParse(user.zoneId!);
        if (zoneIdInt != null) {
          final matchingZone = masterProvider.zones
              .where((z) => z.id == zoneIdInt)
              .firstOrNull;
          if (matchingZone != null) {
            _selectedZone.value = matchingZone;
            await masterProvider.fetchZoneWards(
              matchingZone.id,
              _selectedDistrict.value!.id,
              _selectedCorporation.value!.id,
            );
            if (user.zoneWardId != null &&
                user.zoneWardId!.isNotEmpty &&
                user.zoneWardId != '0' &&
                masterProvider.zoneWards.isNotEmpty) {
              final zoneWardIdInt = int.tryParse(user.zoneWardId!);
              if (zoneWardIdInt != null) {
                final matchingZoneWard = masterProvider.zoneWards
                    .where((w) => w.id == zoneWardIdInt)
                    .firstOrNull;
                if (matchingZoneWard != null) {
                  _selectedZoneWard.value = matchingZoneWard;
                }
              }
            }
          }
        }
      }
    }
  }

  void _setProfileMunicipalityData(
    MasterListProvider masterProvider,
    UserModel user,
  ) async {
    if (user.municipalityId != null &&
        user.municipalityId!.isNotEmpty &&
        user.municipalityId != '0' &&
        masterProvider.municipalities.isNotEmpty) {
      final municipalityIdInt = int.tryParse(user.municipalityId!);
      if (municipalityIdInt != null) {
        final matchingMunicipality = masterProvider.municipalities.firstWhere(
          (m) => m.id == municipalityIdInt,
          orElse: () => masterProvider.municipalities.first,
        );
        _selectedMunicipality.value = matchingMunicipality;
        await masterProvider.fetchMunicipalityWards(matchingMunicipality.id);
        if (user.municipalityWardId != null &&
            user.municipalityWardId!.isNotEmpty &&
            user.municipalityWardId != '0' &&
            masterProvider.municipalityWards.isNotEmpty) {
          final municipalityWardIdInt = int.tryParse(user.municipalityWardId!);
          if (municipalityWardIdInt != null) {
            final matchingMunicipalityWard = masterProvider.municipalityWards
                .firstWhere(
                  (mw) => mw.id == municipalityWardIdInt,
                  orElse: () => masterProvider.municipalityWards.first,
                );
            _selectedMunicipalityWard.value = matchingMunicipalityWard;
          }
        }
      }
    }
  }

  void _setProfileTownPanchayatData(
    MasterListProvider masterProvider,
    UserModel user,
  ) async {
    if (user.townPanchayatId != null &&
        user.townPanchayatId!.isNotEmpty &&
        user.townPanchayatId != '0' &&
        masterProvider.townPanchayats.isNotEmpty) {
      final townPanchayatIdInt = int.tryParse(user.townPanchayatId!);
      if (townPanchayatIdInt != null) {
        final matchingTownPanchayat = masterProvider.townPanchayats.firstWhere(
          (tp) => tp.id == townPanchayatIdInt,
          orElse: () => masterProvider.townPanchayats.first,
        );
        _selectedTownPanchayat.value = matchingTownPanchayat;
        await masterProvider.fetchTownPanchayatWards(matchingTownPanchayat.id);
        if (user.townPanchayatWardId != null &&
            user.townPanchayatWardId!.isNotEmpty &&
            user.townPanchayatWardId != '0' &&
            masterProvider.townPanchayatWards.isNotEmpty) {
          final townPanchayatWardIdInt = int.tryParse(
            user.townPanchayatWardId!,
          );
          if (townPanchayatWardIdInt != null) {
            final matchingTownPanchayatWard = masterProvider.townPanchayatWards
                .firstWhere(
                  (tpw) => tpw.id == townPanchayatWardIdInt,
                  orElse: () => masterProvider.townPanchayatWards.first,
                );
            _selectedTownPanchayatWard.value = matchingTownPanchayatWard;
          }
        }
      }
    }
  }
  void _prefillBlockAndCascade(
    MasterListProvider masterProvider,
    UserModel user,
  ) async {
    if (_selectedBlock.value != null) return;
    await masterProvider.fetchBlocks(_selectedDistrict.value!.id);

    if (user.blockId != null && user.blockId!.isNotEmpty) {
      final blockId = int.tryParse(user.blockId!);
      if (blockId != null) {
        await Future.delayed(Duration(milliseconds: 100));
        final matchingBlock = masterProvider.blocks
            .where((b) => b.id == blockId)
            .firstOrNull;
        if (matchingBlock != null) {
          _selectedBlock.value = matchingBlock;
          _prefillVillageAndCascade(masterProvider, user);
        }
      }
    }
  }
  void _prefillVillageAndCascade(
    MasterListProvider masterProvider,
    UserModel user,
  ) async {
    if (_selectedVillage.value != null) return; 
    await masterProvider.fetchVillages(_selectedBlock.value!.id);
    if (user.villageId != null && user.villageId!.isNotEmpty) {
      final villageId = int.tryParse(user.villageId!);
      if (villageId != null) {
        await Future.delayed(Duration(milliseconds: 100));
        final matchingVillage = masterProvider.villages
            .where((v) => v.id == villageId)
            .firstOrNull;
        if (matchingVillage != null) {
          _selectedVillage.value = matchingVillage;
          _prefillHabitation(masterProvider, user);
        }
      }
    }
  }
  void _prefillHabitation(
    MasterListProvider masterProvider,
    UserModel user,
  ) async {
    if (_selectedHabitation.value != null) return;

    await masterProvider.fetchHabitations(_selectedVillage.value!.id);
    if (user.habitationId != null && user.habitationId!.isNotEmpty) {
      final habitationId = int.tryParse(user.habitationId!);
      if (habitationId != null) {
        await Future.delayed(Duration(milliseconds: 100));
        final matchingHabitation = masterProvider.habitations
            .where((h) => h.id == habitationId)
            .firstOrNull;
        if (matchingHabitation != null) {
          _selectedHabitation.value = matchingHabitation;
        }
      }
    }
  }
  Future<void> _saveCorporationSelection() async {
    if (_selectedCorporation.value != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'selected_corporation_id',
        _selectedCorporation.value!.id,
      );
      await prefs.setString(
        'selected_corporation_name',
        _selectedCorporation.value!.corporationName,
      );
    }
  }

  Future<void> _restoreCorporationSelection(
    MasterListProvider masterProvider,
  ) async {
    if (masterProvider.corporations.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final savedCorporationId = prefs.getInt('selected_corporation_id');

      if (savedCorporationId != null) {
        final matchingCorporation = masterProvider.corporations
            .where((corp) => corp.id == savedCorporationId)
            .firstOrNull;

        if (matchingCorporation != null) {
          _selectedCorporation.value = matchingCorporation;
          if (_selectedDistrict.value != null) {
            await masterProvider.fetchZones(
              _selectedDistrict.value!.id,
              matchingCorporation.id,
            );
          }
        }
      }
    }
  }

  bool _areAllDropdownsSelected() {
    final org = context
        .read<ProfileProvider>()
        .selectedOrganization
        .toUpperCase();
    if (_selectedDistrict.value == null) return false;
    if (org == 'CORPORATION') {
      return _selectedCorporation.value != null &&
          _selectedZone.value != null &&
          _selectedZoneWard.value != null;
    } else if (org == 'MUNICIPALITY') {
      return _selectedMunicipality.value != null &&
          _selectedMunicipalityWard.value != null;
    } else if (org == 'TOWN PANCHAYAT') {
      return _selectedTownPanchayat.value != null &&
          _selectedTownPanchayatWard.value != null;
    } else if (org == 'PANCHAYAT' || org == 'VILLAGE PANCHAYAT') {
      return _selectedBlock.value != null &&
          _selectedVillage.value != null &&
          _selectedHabitation.value != null;
    }
    return false;
  }
}
