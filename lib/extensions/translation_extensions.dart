import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/translation/translation_manager.dart';
import '../presentation/providers/translation_provider.dart';
import '../presentation/providers/locale_provider.dart';

/// Master-level Translation Extensions for Clean Architecture
/// Provides unified context.tr.xyz API for all localizations
extension BuildContextTranslation on BuildContext {
  /// Get translation instance
  AppTranslations get tr => AppTranslations.of(this);
}

/// Comprehensive translation getters for all app localizations
class AppTranslations {
  /// Loading text for dropdowns
  String get loadingData => _manager.translate('loadingData');
  final BuildContext _context;
  final TranslationManager _manager = TranslationManager.instance;

  AppTranslations._(this._context);

  static AppTranslations of(BuildContext context) {
    return AppTranslations._(context);
  }

  /// Core translation method with space trimming
  /// Uses TranslationManager's current language and reacts to LocaleProvider + TranslationProvider changes
  String translate(String key) {
    try {
      _context.watch<LocaleProvider>();
    } catch (e) {
      //
    }

    // Listen to TranslationProvider for reactive updates when dynamic translations load
    TranslationProvider? translationProvider;
    try {
      translationProvider = _context.watch<TranslationProvider>();
    } catch (e) {
      // If TranslationProvider is not available, continue with static translations
    }

    final translation = _manager.translate(key);
    if (translationProvider != null &&
        key.length > 20 &&
        translation == key.trim()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        translationProvider?.ensureTranslationsLoaded();
      });
    }

    return translation;
  }

  // ======================== Dashboard & Cards ========================
  String get recentCardstitle => _manager.translate('recentCardstitle');
  String get welcome => _manager.translate('welcome');
  String get dashboard => _manager.translate('dashboard');
  String get totalGrievances => _manager.translate('totalGrievances');
  String get grievancesInProgress => _manager.translate('grievancesInProgress');
  String get grievancesClosed => _manager.translate('grievancesClosed');
  String get addGrievance => _manager.translate('addGrievance');
  String get noRecentGrievances => _manager.translate('noRecentGrievances');
  String get unableToLoadStatistics =>
      _manager.translate('unableToLoadStatistics');
  String get pleaseTryAgainLater => _manager.translate('pleaseTryAgainLater');
  String get retry => _manager.translate('retry');
  String get featureComingSoon => _manager.translate('featureComingSoon');
  String get loading => _manager.translate('loading');
  String get error => _manager.translate('error');
  String get success => _manager.translate('success');
  String get grievanceCardComplaintno =>
      _manager.translate('grievanceCardComplaintno');
  String get dashboardCardtext1 => _manager.translate('dashboardCardtext1');
  String get dashboardCardtext2 => _manager.translate('dashboardCardtext2');
  String get dashboardCardtext3 => _manager.translate('dashboardCardtext3');
  String get addGreivance => _manager.translate('addGreivance');
  String get noGrievance => _manager.translate('noGrievance');

  /// New translation: Complaint description required
  String get complaintDescriptionRequired =>
      _manager.translate('complaintDescriptionRequired');
  String get youcannotcreatecomplaintnowafter1houryoucancreate =>
      _manager.translate('youcannotcreatecomplaintnowafter1houryoucancreate');

  String get filesUploadedSuccessfully =>
      _manager.translate('filesUploadedSuccessfully');
  String get errorUploadingFiles => _manager.translate('errorUploadingFiles');
  String get warningOrganization => _manager.translate('warningOrganization');
  String get warningSelectZone => _manager.translate('warningSelectZone');
  String get warningSelectZoneWard =>
      _manager.translate('warningSelectZoneWard');
  String get wariningSelectMunicipality =>
      _manager.translate('warningSelectMunicipality');
  String get waringingSelectMunicipalityWard =>
      _manager.translate('warningSelectMunicipalityWard');
  String get warningSelectTownPanchayat =>
      _manager.translate('warningSelectTownPanchayat');
  String get warningSelectTownPanchayatWard =>
      _manager.translate('warningSelectTownPanchayatWard');

  // ======================== Grievance Card ========================
  String get grievanceCardTitle => _manager.translate('grievanceCardTitle');
  String get grievanceCardStatus => _manager.translate('grievanceCardStatus');
  String get grievanceView => _manager.translate('grievanceView');
  String get individualcomplaint => _manager.translate('individualcomplaint');
  String get publiccomplaint => _manager.translate('publiccomplaint');
  String get complaintisrequired => _manager.translate('complaintrequired');
  // ======================== Form Fields ========================
  String get grievanceType => _manager.translate('grievanceType');
  String get complaintCategoryLabel =>
      _manager.translate('complaintCategoryLabel');
  String get complaintSubCategoryLabel =>
      _manager.translate('complaintSubCategoryLabel');
  String get descriptionLabel => _manager.translate('descriptionLabel');
  String get documentLabel => _manager.translate('documentLabel');
  String get chooseFileButton => _manager.translate('chooseFileButton');
  String get filechosen => _manager.translate('filechosen');
  String get allowedDocumenttypes => _manager.translate('allowedDocumenttypes');
  String get declaratin => _manager.translate('declaratin');
  String get submitButton => _manager.translate('submitButton');
  String get uploadedFiles => _manager.translate('UploadedFiles');
  String get grievanceTypeLabel => _manager.translate('grievanceTypeLabel');
  String get filedeletedsuccess => _manager.translate('filedeletedsuccess');
  String get fileuploadedsuccess => _manager.translate('fileuploadedsuccess');
  String get fileupdating => _manager.translate('fileupdating');

  // ======================== Location Fields ========================
  String get gistrictLabel => _manager.translate('gistrictLabel');
  String get organizationLabel => _manager.translate('organizationLabel');
  String get beneficiaryLabel => _manager.translate('beneficiaryLabel');
  String get organizationCorporation =>
      _manager.translate('organizationCorporation');
  String get organizationMunicipality =>
      _manager.translate('organizationMunicipality');
  String get organizationTownpanchayat =>
      _manager.translate('organizationTownpanchayat');
  String get organizationPanchayat =>
      _manager.translate('organizationPanchayat');
  String get organizationTwad => _manager.translate('organizationTwad');
  String get zoneLabel => _manager.translate('zoneLabel');
  String get zonewardLabel => _manager.translate('zonewardLabel');
  String get wardLabel => _manager.translate('wardLabel');
  String get municipalityLabel => _manager.translate('municipalityLabel');
  String get municipalitywardLabel =>
      _manager.translate('municipalitywardLabel');
  String get townpanchayatLabel => _manager.translate('townpanchayatLabel');
  String get townpanchayatwardLabel =>
      _manager.translate('townpanchayatwardLabel');
  String get blockLabel => _manager.translate('blockLabel');
  String get villageLabel => _manager.translate('villageLabel');
  String get habbinationLabel => _manager.translate('habbinationLabel');
  String get addressLabel => _manager.translate('addressLabel');
  String get profilerequirdfields =>
      _manager.translate('profilerequiredfields');
  String get documents => _manager.translate('documents');
  String get comments => _manager.translate('comments');
  String get entercomments => _manager.translate('entercomments');

  // ======================== Profile & Authentication ========================
  String get profilePageTitle => _manager.translate('profilePageTitle');
  String get editProfile => _manager.translate('editProfile');
  String get logout => _manager.translate('logout');
  String get cancel => _manager.translate('cancel');
  String get description => _manager.translate('description');
  String get maintenanceActivity => _manager.translate('maintenanceActivity');
  String get startDate => _manager.translate('startDate');
  String get endDate => _manager.translate('endDate');
  String get maintenanceWorkInprogress =>
      _manager.translate('maintenanceWorkInprogress');
  String get maintenanceDescription =>
      _manager.translate('maintenanceDescription');

  String get logoutTitle => _manager.translate('logoutTitle');
  String get logoutQuestion => _manager.translate('logoutQuestion');
  String get nameLabel => _manager.translate('nameLabel');
  String get mailIdLabel => _manager.translate('mailIdLabel');
  String get phnoLable => _manager.translate('phnoLable');
  String get pincodeLabel => _manager.translate('pincodeLabel');
  String get createaccount => _manager.translate('createaccount');
  String get signninwithotp => _manager.translate('signninwithotp');
  String get alreadyhaveanaccount => _manager.translate('alreadyhaveanaccount');
  String get register => _manager.translate('register');
  String get noaccount => _manager.translate('noaccount');

  // ======================== Hints ========================
  String get hintcontact => _manager.translate('hintcontact');
  String get errorcontact => _manager.translate('errorcontact');
  String get hintname => _manager.translate('hintname');
  String get hintEmail => _manager.translate('hintEmail');
  String get hintAddress => _manager.translate('hintAddress');
  String get hintPincode => _manager.translate('hintPincode');
  String get descriptionhint => _manager.translate('descriptionhint');

  // ======================== Status & Feedback ========================
  String get acknowledgement => _manager.translate('acknowledgement');
  String get closure => _manager.translate('closure');
  String get closeddate => _manager.translate('closeddate');
  String get feedback => _manager.translate('feedback');
  String get attachment => _manager.translate('attachment');
  String get newgrievance => _manager.translate('newgrievance');
  String get contactdetails => _manager.translate('contactdetails');
  String get complaintdetails => _manager.translate('complaintdetails');
  String get clearButton => _manager.translate('clearButton');
  String get feedbacksubmittedcard =>
      _manager.translate('feedbacksubmittedcard');
  String get date => _manager.translate('date');
  String get complaintinformation => _manager.translate('complaintinformation');
  String get complaint => _manager.translate('complaint');
  String get assignedTo => _manager.translate('assignedTo');
  String get submittedStatus => _manager.translate('submittedStatus');
  String get statusPageTitle => _manager.translate('statusPageTitle');

  // ======================== Profile & Settings ========================
  String get profileInformation => _manager.translate('profileInformation');
  String get setting => _manager.translate('setting');
  String get profileSettings => _manager.translate('profileSettings');
  String get signin => _manager.translate('signin');
  String get back => _manager.translate('back');
  String get enterOTP => _manager.translate('enterOTP');
  String get grievance => _manager.translate('grievance');
  String get grievanceStatus => _manager.translate('grievanceStatus');
  String get detailsview => _manager.translate('detailsview');
  String get search => _manager.translate('search');

  // ======================== Status Types ========================
  String get inProgress => _manager.translate('inProgress');
  String get resolved => _manager.translate('resolved');
  String get closed => _manager.translate('closed');
  String get open =>
      _manager.translate('open'); // New translation for open status
  String get openGrievance =>
      _manager.translate('openGrievance'); // Popup title
  String get openGrievanceReason =>
      _manager.translate('openGrievanceReason'); // Reason prompt
  String get openGrievanceHint =>
      _manager.translate('openGrievanceHint'); // Textbox hint
  String get openGrievanceSuccess =>
      _manager.translate('openGrievanceSuccess'); // Success message
  String get openGrievanceError =>
      _manager.translate('openGrievanceError'); // Error message
  String get reopeningGrievance => _manager.translate('reopeningGrievance');
  String get rejected => _manager.translate('rejected');
  String get draft => _manager.translate('draft');
  String get processing => _manager.translate('processing');
  String get from => _manager.translate('from');
  String get to => _manager.translate('to');

  // ======================== Downloads & File Operations ========================
  String get downloadComplete => _manager.translate('downloadComplete');
  String get downloading => _manager.translate('downloading');
  String get downloadingAcknowledgement =>
      _manager.translate('downloadingAcknowledgement');
  String get downloadFailed => _manager.translate('downloadFailed');
  String get fileNotAvailable => _manager.translate('fileNotAvailable');
  String get filesUploaded => _manager.translate('filesUploaded');
  String get uploadFailed => _manager.translate('uploadFailed');
  String get viewAttachments => _manager.translate('viewAttachments');
  String get viewFile => _manager.translate('viewFile');
  String get loadingFile => _manager.translate('loadingFile');
  String get fileLoaded => _manager.translate('fileLoaded');
  String get fileLoadFailed => _manager.translate('fileLoadFailed');
  String get fileOpenFailed => _manager.translate('fileOpenFailed');
  String get download => _manager.translate('download');
  String get close => _manager.translate('close');
  String get tapToView => _manager.translate('tapToView');

  // ======================== Error & Status Messages ========================
  String get complaintNotFound => _manager.translate('complaintNotFound');
  String get loadingGrievances => _manager.translate('loadingGrievances');
  String get noResultsFound => _manager.translate('noResultsFound');
  String get noGrievances => _manager.translate('noGrievances');
  String get tryAdjustingSearch => _manager.translate('tryAdjustingSearch');
  String get noGrievancesSubmitted =>
      _manager.translate('noGrievancesSubmitted');
  String get formCleared => _manager.translate('formCleared');

  // ======================== Selection Prompts ========================
  String get selectGrievanceType => _manager.translate('selectGrievanceType');
  String get selectDistrict => _manager.translate('selectDistrict');
  String get selectBlock => _manager.translate('selectBlock');
  String get selectVillage => _manager.translate('selectVillage');
  String get selectHabitation => _manager.translate('selectHabitation');
  String get selectComplaintType => _manager.translate('selectComplaintType');
  String get selectSubComplaintType =>
      _manager.translate('selectSubComplaintType');
  String get select => _manager.translate('select');

  // ======================== Success & Error Messages ========================
  String get newGrievanceSubmitted =>
      _manager.translate('newGrievanceSubmitted');
  String get unknownError => _manager.translate('unknownError');
  String get contactNumberRequired =>
      _manager.translate('contactNumberRequired');
  String get validContactNumber => _manager.translate('validContactNumber');
  String get nameRequired => _manager.translate('nameRequired');
  String get validEmail => _manager.translate('validEmail');
  String get addressRequired => _manager.translate('addressRequired');
  String get pincodeRequired => _manager.translate('pincodeRequired');
  String get noDataFound => _manager.translate('noDataFound');

  // ======================== OTP & Authentication ========================
  String get resendOtp => _manager.translate('resendOtp');
  String get validOtp => _manager.translate('validOtp');
  String get loginSuccessful => _manager.translate('loginSuccessful');
  String get loginFailed => _manager.translate('loginFailed');
  String get sendingOtp => _manager.translate('sendingOtp');
  String get registrationFailed => _manager.translate('registrationFailed');
  String get registrationSuccessful =>
      _manager.translate('registrationSuccessful');
  String get loggingOut => _manager.translate('loggingOut');
  String get save => _manager.translate('save');
  String get loggedOut => _manager.translate('loggedOut');
  String get profileUpdated => _manager.translate('profileUpdated');
  String get enterOtpVerifyMobile => _manager.translate('enterOtpVerifyMobile');
  String get textOtpTesting => _manager.translate('textOtpTesting');
  String get confirm => _manager.translate('confirm');
  String get otpValidationFailed => _manager.translate('otpValidationFailed');
  String get failedToSendOtp => _manager.translate('failedToSendOtp');
  String get errorMessage => _manager.translate('errorMessage');
  String get otpExpiresIn => _manager.translate('otpExpiresIn');
  String get notes => _manager.translate('notes');

  //========location=====

  String get locationDetail => _manager.translate('locationDetail');
  String get noLocation => _manager.translate('noLocation');
  String get mapSentence => _manager.translate('mapSentence');
  String get selectLocation => _manager.translate('selectLocation');
  String get clearLocation => _manager.translate('clearLocation');
  String get currentLocation => _manager.translate('currentLocation');
  String get locationMap => _manager.translate('locationMap');
  String get getLocation => _manager.translate('getLocation');
  String get locationSelect => _manager.translate('locationSelect');
  String get latitude => _manager.translate('latitude');
  String get longitude => _manager.translate('longitude');
  String get locationClear => _manager.translate('locationClear');
  String get mapTap => _manager.translate('mapTap');
  String get gpsLocation => _manager.translate('gpsLocation');
  String get permenantlyDenied => _manager.translate('permenantlyDenied');
  String get permissionDenied => _manager.translate('permissionDenied');
  String get serviceDisable => _manager.translate('serviceDisable');
}
