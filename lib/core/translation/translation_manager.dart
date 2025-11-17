/// Master-level Translation Manager with Clean Architecture and Space Trimming
class TranslationManager {
  static TranslationManager? _instance;
  static TranslationManager get instance =>
      _instance ??= TranslationManager._();
  TranslationManager._();

  // 🎯 Static translations (your existing) - Always available
  static const Map<String, Map<String, String>> _staticTranslations = {
    'en': {
      'loadingData': 'Loading...',
      'recentCardstitle': 'Recent Complaints',
      'welcome': 'Welcome',
      'dashboard': 'Dashboard',
      'totalGrievances': 'Total Grievances',
      'grievancesInProgress': 'Grievances In Progress',
      'grievancesClosed': 'Grievances Closed',
      'addGrievance': 'Add Grievance',
      'noRecentGrievances': 'No recent grievances',
      'unableToLoadStatistics': 'Unable to load statistics',
      'pleaseTryAgainLater': 'Please try again later',
      'retry': 'Retry',
      'featureComingSoon': 'Feature coming soon!',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'grievanceCardComplaintno': 'Complaint No:',
      // Dashboard and cards
      'dashboardCardtext1': 'Total Grievances',
      'dashboardCardtext2': 'In Progress',
      'dashboardCardtext3': 'Resolved',
      'addGreivance': 'Add Grievance',
      'noGrievance': 'No Grievances',
      // Grievance card
      'grievanceCardTitle': 'Title',
      'grievanceCardStatus': 'Status',
      'grievanceView': 'View Details',
      // Form fields
      'grievanceType': 'Grievance Type',
      'complaintCategoryLabel': 'Complaint Category',
      'complaintSubCategoryLabel': 'Sub Category',
      'assignedTo': 'Assigned To',
      'descriptionLabel': 'Description',
      'documentLabel': 'Document',
      'chooseFileButton': 'Choose File',
      'filechosen': 'File Chosen',
      'allowedDocumenttypes': 'Allowed: PDF, JPG, PNG',
      'declaratin': 'Declaration',
      'submitButton': 'Submit',
      'grievanceTypeLabel': 'Grievance Type',
      // Location fields
      'gistrictLabel': 'District',
      'organizationLabel': 'Organization',
      'beneficiaryLabel': 'Beneficiary Type',
      'organizationCorporation': 'Corporation',
      'organizationMunicipality': 'Municipality',
      'organizationTownpanchayat': 'Town Panchayat',
      'organizationPanchayat': 'Panchayat',
      'organizationTwad': 'TWAD',
      'zoneLabel': 'Zone',
      'zonewardLabel': 'Zone Ward',
      'wardLabel': 'Ward',
      'municipalityLabel': 'Municipality',
      'municipalitywardLabel': 'Municipality Ward',
      'townpanchayatLabel': 'Town Panchayat',
      'townpanchayatwardLabel': 'Town Panchayat Ward',
      'blockLabel': 'Block',
      'villageLabel': 'Village',
      'habbinationLabel': 'Habitation',
      'addressLabel': 'Address',
      // Profile and authentication
      'profilePageTitle': 'Profile',
      'editProfile': 'Edit Profile',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'logoutTitle': 'Logout',
      'logoutQuestion': 'Are you sure you want to logout?',
      'description': "Work",
      'maintenanceActivity': "Maintenance Activity",
      'startDate': "Start Date",
      'endDate': "End Date",
      'maintenanceDescription':
          "There are maintenance activities in this area. Submitting a grievance may not be processed until maintenance is complete.",
      'nameLabel': 'Name',
      'mailIdLabel': 'Email ID',
      'phnoLable': 'Phone Number',
      'pincodeLabel': 'Pincode',
      'createaccount': 'Create Account',
      'signninwithotp': 'Sign in with OTP',
      'alreadyhaveanaccount': 'Already have an account?',
      'register': 'Register',
      'noaccount': 'No account? Create one',
      // Hints
      'hintcontact': 'Enter contact number',
      'hintname': 'Enter your name',
      'hintEmail': 'Enter email address',
      'hintAddress': 'Enter your address',
      'hintPincode': 'Enter pincode',
      'descriptionhint': 'Enter description',
      // Status and feedback
      'processing': 'Processing',
      'acknowledgement': 'Acknowledgement',
      'closure': 'Closure',
      'closeddate': 'Closed Date',
      'feedback': 'Feedback',
      'newgrievance': 'New Grievance',
      'contactdetails': 'Contact Details',
      'complaintdetails': 'Complaint Details',
      'clearButton': 'Clear',
      'feedbacksubmittedcard': 'Feedback Submitted',
      'date': 'Date',
      'complaintinformation': 'Complaint Information',
      'complaint': 'Complaint',
      'submittedStatus': 'Submitted',
      'statusPageTitle': 'Grievance Status',
      // Profile and settings
      'profileInformation': 'Profile Information',
      'setting': 'Settings',
      'profileSettings': 'Profile Settings',
      'signin': 'Sign In',
      'back': 'Back',
      'enterOTP': 'Enter OTP',
      'grievance': 'Grievance',
      'grievanceStatus': 'Grievance Status',
      'detailsview': 'Details View',
      'search': 'Search',
      'errorcontact': 'Please enter a valid 10-digit phone number',
      // Status types
      'inProgress': 'In Progress',
      'resolved': 'Resolved',
      'closed': 'Closed',
      'rejected': 'Rejected',
      'draft': 'Draft',
      // Download and file operations
      'downloadComplete': 'Download Complete',
      'downloadingAcknowledgement': 'Downloading Acknowledgement',
      'downloadFailed': 'Download Failed',
      'fileNotAvailable': 'File Not Available',
      'filesUploaded': 'Files Uploaded',
      'uploadFailed': 'Upload Failed',
      'attachments': 'Attachments',
      'viewAttachments': 'View Attachments',
      'viewFile': 'View File',
      'loadingFile': 'Loading File...',
      'fileLoaded': 'File Loaded Successfully',
      'fileLoadFailed': 'Failed to Load File',
      'fileOpenFailed': 'Failed to Open File',
      'download': 'Download',
      'close': 'Close',
      'tapToView': 'Tap to view file',
      // Error and status messages
      'complaintNotFound': 'Complaint Not Found',
      'loadingGrievances': 'Loading Grievances',
      'noResultsFound': 'No Results Found',
      'noGrievances': 'No Grievances',
      'tryAdjustingSearch': 'Try adjusting your search',
      'noGrievancesSubmitted': 'No Grievances Submitted',
      'formCleared': 'Form Cleared',
      // Selection prompts
      'selectGrievanceType': 'Select Grievance Type',
      'selectDistrict': 'Select District',
      'selectBlock': 'Select Block',
      'selectVillage': 'Select Village',
      'selectHabitation': 'Select Habitation',
      'selectComplaintType': 'Select Complaint Type',
      'selectSubComplaintType': 'Select Sub Complaint Type',
      'select': 'Select',
      // Success and error messages
      'newGrievanceSubmitted': 'New Grievance Submitted',
      'unknownError': 'Unknown Error',
      'contactNumberRequired': 'Contact number is required',
      'validContactNumber': 'Enter valid contact number',
      'nameRequired': 'Name is required',
      'validEmail': 'Enter valid email',
      'addressRequired': 'Address is required',
      'pincodeRequired': 'Pincode is required',
      'noDataFound': 'No Data Found',
      'attachment': 'Attachment',
      // OTP and authentication
      'resendOtp': 'Resend OTP',
      'validOtp': 'Enter valid OTP',
      'loginSuccessful': 'Login Successful',
      'loginFailed': 'Login Failed',
      'sendingOtp': 'Sending OTP',
      'registrationFailed': 'Registration Failed',
      'registrationSuccessful': 'Registration Successful',
      'loggingOut': 'Logging Out',
      'save': 'Save',
      'loggedOut': 'Logged Out',
      'profileUpdated': 'Profile Updated',
      'twadDivision': 'Twad Division',
      "submitFeedback": "Submit Feedback",
      "loadingProfile": "Loading profile...",
      "storagePermissionDenied": "Storage permission denied",
      "complaintDescriptionRequired": "Complaint Description Required",
      'filesUploadedSuccessfully': 'Files uploaded successfully!',
      'errorUploadingFiles': 'Error uploading files: ',
      'warningOrganization': 'Select  organization',
      'warningSelectZone': 'Please select a zone',
      'warningSelectZoneWard': 'Please select a zone ward',
      'warningSelectMunicipality': 'Please select a municipality',

      'warningSelectMunicipalityWard': 'Please select a municipality ward',
      'warningSelectTownPanchayat': 'Please select a town panchayat',
      'warningSelectTownPanchayatWard': 'Please select a town panchayat ward',
      'downloading': 'Downloading...',
      'profile': 'Profile',
      'enterOtpVerifyMobile': 'Enter OTP for verify your mobile number',
      'textOtpTesting': 'Text OTP for testing purpose only:',
      'confirm': 'Confirm',
      'otpValidationFailed': 'OTP validation failed',
      'failedToSendOtp': 'Failed to send OTP. Please try again.',
      'errorMessage': 'Error:',
      'otpExpiresIn': 'OTP Expires in',
      'open': 'Reopen',
      'openGrievance': 'Reopen Grievance',
      'openGrievanceHint': 'Enter the reason',
      'openGrievanceReason': 'Reason',
      'reopeningGrievance': 'Reopening grievance...',
      'from': 'From',
      'to': 'To',
      'complaintrequired': 'Enter the required fields ',
      'openGrievanceError': 'Enter Reason',
      'filedeletedsuccess': 'File deleted successfully',
      'fileuploadedsuccess': 'File uploaded successfully!',
      'fileupdating': 'Uploading files...',
      'profilerequiredfields': 'Please select required fields',
      'documents': 'Documents',
      'comments': 'Comments',
      'entercomments': 'Enter your comments',
      'locationDetail': 'Location Details',
      'noLocation':
          'No location selected yet. Tap the map or use the button above.',
      'mapSentence':
          'Tap on the map to select your location, or use the button below to your current location.',
      'selectLocation': 'Select Location on Map',
      'clearLocation': 'Clear Location',
      'currentLocation': 'Current Location',
      'locationMap': 'Tap anywhere on the map to select location',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'locationSelect': 'Location Selected',
      'getLocation': 'Getting Location...',
      'locationClear': 'Location Cleared',
      'mapTap': 'Location selected via map tap',
      'gpsLocation': 'Current GPS location captured. Map updated.',
      'permenantlyDenied': 'Location permissions permanently denied',
      'permissionDenied': 'Location permissions denied',
      'serviceDisable': 'Location services are disabled',
      'notes': 'closure',
    },
    'ta': {
      'notes': 'மூடல்',
      'entercomments': 'உங்கள் கருத்துக்களை உள்ளிடவும்',
      'comments': 'கருத்துகள்',
      'documents': 'ஆவணங்கள்',
      'profilerequiredfields': 'தேவையான புலங்களை உள்ளிடவும்',
      'filedeletedsuccess': 'கோப்பு வெற்றிகரமாக நீக்கப்பட்டது',
      'fileuploadedsuccess': 'கோப்பு வெற்றிகரமாக பதிவேற்றப்பட்டது!',
      'fileupdating': 'கோப்புகள் பதிவேற்றப்படுகின்றன...',

      'openGrievanceError': 'காரணத்தை அளிக்கவும்”',
      'complaintrequired': 'தேவையான புலங்களை உள்ளிடவும்',
      'to': 'இறுதி தேதி',
      'from': 'முதல் தேதி',
      'loadingData': 'ஏற்றுகிறது...',
      'recentCardstitle': 'சமீபத்திய குறைகள்',
      'welcome': 'வணக்கம்',
      'dashboard': 'முகப்பு',
      'totalGrievances': 'மொத்த புகார்கள்',
      'grievancesInProgress': 'நடைபெற்று வரும் புகார்கள்',
      'noResultsFound': 'முடிவுகள் இல்லை',
      'grievancesClosed': 'மூடப்பட்ட புகார்கள்',
      'addGrievance': 'புகார் சேர்க்க',
      'noRecentGrievances': 'சமீபத்திய புகார்கள் இல்லை',
      'unableToLoadStatistics': 'புள்ளிவிவரங்களை ஏற்ற முடியவில்லை',
      'pleaseTryAgainLater': 'தயவுசெய்து பின்னர் முயற்சிக்கவும்',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'featureComingSoon': 'விரைவில் வரும் அம்சம்!',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'grievanceCardComplaintno': 'புகார் எண்:',
      'assignedTo': 'ஒதுக்கப்பட்டவர்',
      // Dashboard and cards
      'dashboardCardtext1': 'மொத்த குறைகள்',
      'dashboardCardtext2': 'செயல்பாட்டில் உள்ள குறைகள்',
      'dashboardCardtext3': 'தீர்க்கப்பட்ட குறைகள்',
      'addGreivance': 'புகார் சேர்க்கவும்',
      'noGrievance': 'புகார்கள் இல்லை',
      // Grievance card
      'grievanceCardTitle': 'தலைப்பு',
      'grievanceCardStatus': 'நிலை',
      'grievanceView': 'விவரங்களைக் காண்க',
      'errorcontact':
          'தயவுசெய்து செல்லுபடியாகும் 10 இலக்க தொலைபேசி எண்ணை உள்ளிடவும்',
      'individualcomplaint': 'தனிப்பட்ட புகார்',
      'publiccomplaint': 'பொது புகார்',
      // Form fieldsi
      'grievanceType': 'குறைகளின் வகை ',
      'complaintCategoryLabel': 'புகார் வகை',
      'complaintSubCategoryLabel': 'துணை வகை',
      'descriptionLabel': 'விவரம்',
      'documentLabel': 'ஆவணம்',
      'chooseFileButton': 'கோப்பைத் தேர்ந்தெடுக்கவும்',
      'UploadedFiles': 'பதிவேற்றிய கோப்பு',
      'filechosen': 'கோப்பு தேர்ந்தெடுக்கப்பட்டது',
      'allowedDocumenttypes': 'அனுமதிக்கப்பட்டவை: PDF, JPG, PNG',
      'declaratin': 'அறிவிப்பு',
      'submitButton': 'சமர்ப்பிக்கவும்',
      'grievanceTypeLabel': 'குறைகளின் வகை *',
      // Location fields
      'gistrictLabel': 'மாவட்டம்',
      'organizationLabel': 'அமைப்பு',
      'beneficiaryLabel': 'பயனாளர் வகை',
      'organizationCorporation': 'மாநகராட்சி',
      'organizationMunicipality': 'நகராட்சி',
      'organizationTownpanchayat': 'நகர பஞ்சாயத்து',
      'organizationPanchayat': 'பஞ்சாயத்து',
      'organizationTwad': 'ட்வாட்',
      'zoneLabel': 'மண்டலம்',
      'zonewardLabel': 'மண்டல வார்டு',
      'wardLabel': 'வார்டு',
      'municipalityLabel': 'நகராட்சி',
      'municipalitywardLabel': 'நகராட்சி வார்டு',
      'townpanchayatLabel': 'நகர பஞ்சாயத்து',
      'townpanchayatwardLabel': 'நகர பஞ்சாயத்து வார்டு',
      'blockLabel': 'வட்டம்',
      'villageLabel': 'கிராமம்',
      'habbinationLabel': 'குடியிருப்பு',
      'addressLabel': 'முகவரி',
      // Profile and authentication
      'profilePageTitle': 'சுயவிவரம்',
      'editProfile': ' திருத்து',
      'logout': 'வெளியேறு',
      'cancel': 'ரத்து செய்',
      'logoutTitle': 'வெளியேறு',
      'logoutQuestion': 'நீங்கள் வெளியேற விரும்புகிறீர்களா?',
      'description': "வேலை",
      'maintenanceActivity': "பராமரிப்பு நடவடிக்கை",
      'startDate': "தொடக்க தேதி",
      'endDate': "முடிவு தேதி",
      'maintenanceDescription':
          "இந்த பகுதியில் பராமரிப்பு பணிகள் நடைபெற்று வருகின்றன. பராமரிப்பு முடியும் வரை புகார்களை சமர்ப்பித்தாலும் அவை செயலாக்கப்படாமல் இருக்கலாம்.",
      'nameLabel': 'பெயர்',
      'mailIdLabel': 'மின்னஞ்சல்',
      'phnoLable': 'அலைபேசி எண்',
      'pincodeLabel': 'அஞ்சல் குறியீடு',
      'createaccount': 'கணக்கை உருவாக்கவும்',
      'signninwithotp': 'OTP மூலம் உள்நுழைக',
      'alreadyhaveanaccount': 'ஏற்கனவே கணக்கு உள்ளதா?',
      'register': 'பதிவு செய்யவும்',
      'noaccount': 'கணக்கு இல்லையா? ஒன்றை உருவாக்கவும்',
      // Hints
      'hintcontact': 'தொடர்பு எண்ணை உள்ளிடவும்',
      'hintname': 'உங்கள் பெயரை உள்ளிடவும்',
      'hintEmail': 'மின்னஞ்சல் முகவரியை உள்ளிடவும்',
      'hintAddress': 'உங்கள் முகவரியை உள்ளிடவும்',
      'hintPincode': 'பின்கோடு உள்ளிடவும்',
      'descriptionhint': 'விவரத்தை உள்ளிடவும்',
      // Status and feedback
      'processing': 'செயலாக்கம்',
      'acknowledgement': 'ஒப்புதல்',
      'closure': 'மூடல்',
      'closeddate': 'மூடிய தேதி',
      'feedback': 'கருத்து',
      'newgrievance': 'புதிய குறைகள்',
      'contactdetails': 'தொடர்பு விவரங்கள்',
      'complaintdetails': 'புகார் விவரங்கள்',
      'clearButton': 'அழிக்கவும்',
      'feedbacksubmittedcard': 'கருத்து சமர்ப்பிக்கப்பட்டது',
      'date': 'தேதி',
      'complaintinformation': 'புகார் தகவல்',
      'complaint': 'புகார்',
      'submittedStatus': 'சமர்ப்பிக்கப்பட்டது',
      'statusPageTitle': 'புகார் நிலை',
      // Profile and settings
      'profileInformation': 'சுயவிவர தகவல்',
      'setting': 'அமைப்புகள்',
      'profileSettings': 'சுயவிவர அமைப்புகள்',
      'signin': 'உள்நுழைக',
      'back': 'திரும்பு',
      'enterOTP': 'OTP ஐ உள்ளிடவும்',
      'grievance': 'புகார்',
      'grievanceStatus': 'புகார் நிலை',
      'detailsview': 'விவரக் காட்சி',
      'search': 'தேடல்',
      // Status types
      'inProgress': 'நடைபெற்று கொண்டிருக்கும்',
      'resolved': 'தீர்க்கப்பட்டது',
      'closed': 'மூடப்பட்டது',
      'rejected': 'நிராகரிக்கப்பட்டது',
      'draft': 'வரைவு',
      // Download and file operations
      'downloadComplete': 'பதிவிறக்கம் முடிந்தது',
      'downloadingAcknowledgement': 'ஒப்புதல் பதிவிறக்கம்',
      'downloadFailed': 'பதிவிறக்கம் தோல்வி',
      'fileNotAvailable': 'கோப்பு கிடைக்கவில்லை',
      'filesUploaded': 'கோப்புகள் பதிவேற்றப்பட்டன',
      'uploadFailed': 'பதிவேற்றம் தோல்வி',
      'attachments': 'இணைப்புகள்',
      'viewAttachments': 'இணைப்புகளைப் பார்க்க',
      'viewFile': 'கோப்பைப் பார்க்க',
      'loadingFile': 'கோப்பு ஏற்றுகிறது...',
      'fileLoaded': 'கோப்பு வெற்றிகரமாக ஏற்றப்பட்டது',
      'fileLoadFailed': 'கோப்பு ஏற்றுவதில் தோல்வி',
      'fileOpenFailed': 'கோப்பு திறப்பதில் தோல்வி',
      'download': 'பதிவிறக்கம்',
      'close': 'மூடு',
      'tapToView': 'கோப்பைப் பார்க்க தட்டவும்',
      // Error and status messages
      'complaintNotFound': 'புகார் கிடைக்கவில்லை',
      'loadingGrievances': 'புகார்கள் ஏற்றப்படுகின்றன',
      'noRecordFound': 'பதிவு எதுவும் கிடைக்கவில்லை',
      'noGrievances': 'புகார்கள் இல்லை',
      'tryAdjustingSearch': 'உங்கள் தேடலை மாற்றி முயற்சிக்கவும்',
      'noGrievancesSubmitted': 'புகார்கள் சமர்ப்பிக்கப்படவில்லை',
      'formCleared': 'படிவம் அழிக்கப்பட்டது',
      'youcannotcreatecomplaintnowafter1houryoucancreate':
          'நீங்கள் இப்போது புகார் அளிக்க முடியாது 1 மணி நேரத்திற்குப் பிறகு நீங்கள் உருவாக்கலாம்',
      // Selection prompts
      'selectGrievanceType': 'புகார் வகையைத் தேர்ந்தெடுக்கவும்',
      'selectDistrict': 'மாவட்டத்தைத் தேர்ந்தெடுக்கவும்',
      'selectBlock': 'வட்டத்தைத் தேர்ந்தெடுக்கவும்',
      'selectVillage': 'கிராமத்தைத் தேர்ந்தெடுக்கவும்',
      'selectHabitation': 'குடியிருப்பைத் தேர்ந்தெடுக்கவும்',
      'selectComplaintType': 'புகார் வகையைத் தேர்ந்தெடுக்கவும்',
      'selectSubComplaintType': 'துணைப் புகார் வகையைத் தேர்ந்தெடுக்கவும்',
      'select': 'தேர்ந்தெடுக்கவும்',
      // Success and error messages
      'newGrievanceSubmitted': 'புதிய புகார் சமர்ப்பிக்கப்பட்டது',
      'unknownError': 'அறியப்படாத பிழை',
      'contactNumberRequired': 'தொடர்பு எண் தேவை',
      'validContactNumber': 'சரியான தொடர்பு எண்ணை உள்ளிடவும்',
      'nameRequired': 'பெயர் தேவை',
      'validEmail': 'சரியான மின்னஞ்சலை உள்ளிடவும்',
      'addressRequired': 'முகவரி தேவை',
      'pincodeRequired': 'அஞ்சல் குறியீடு தேவை',
      'noDataFound': 'தரவு கிடைக்கவில்லை',
      'attachment': 'இணைப்பு',
      // OTP and authentication
      'resendOtp': 'OTP ஐ மீண்டும் அனுப்பவும்',
      'validOtp': 'சரியான OTP ஐ உள்ளிடவும்',
      'loginSuccessful': 'உள்நுழைவு வெற்றிகரமானது',
      'loginFailed': 'உள்நுழைவு தோல்வி',
      'sendingOtp': 'OTP அனுப்பப்படுகிறது',
      'registrationFailed': 'பதிவு தோல்வி',
      'registrationSuccessful': 'பதிவு வெற்றிகரமானது',
      'loggingOut': 'வெளியேறுகிறது',
      'save': 'சேமிக்கவும்',
      'loggedOut': 'வெளியேறிவிட்டீர்கள்',
      'profileUpdated': 'சுயவிவரம் புதுப்பிக்கப்பட்டது',
      'twadDivision': 'TWAD பிரிவு',
      "submitFeedback": "கருத்தை சமர்ப்பிக்க",
      "loadingProfile": "சுயவிவரம் ஏற்றப்படுகிறது...",
      "storagePermissionDenied": "சேமிப்பு அனுமதி மறுக்கப்பட்டது",
      "complaintDescriptionRequired": "புகார் விளக்கம் தேவை",
      'filesUploadedSuccessfully_ta': 'கோப்புகள் வெற்றிகரமாக பதிவேற்றப்பட்டன!',

      'errorUploadingFiles': 'கோப்புகளை பதிவேற்றும்போது பிழை:',
      'warningOrganization': ' அமைப்பு தேர்ந்தெடுக்கவும்',
      'warningSelectZone': 'தயவுசெய்து ஒரு மண்டலத்தைத் தேர்ந்தெடுக்கவும்',
      'warningSelectZoneWard': 'மண்டல வார்டைத் தேர்ந்தெடுக்கவும்',
      'warningSelectMunicipality': ' நகராட்சியைத் தேர்ந்தெடுக்கவும்',
      'warningSelectMunicipalityWard': 'நகராட்சி வார்டைத் தேர்ந்தெடுக்கவும்',
      'warningSelectTownPanchayat': ' ஊராட்சி ஒன்றியத்தைத் தேர்ந்தெடுக்கவும்',
      'warningSelectTownPanchayatWard':
          ' ஊராட்சி ஒன்றிய வார்டைத் தேர்ந்தெடுக்கவும்',
      'downloading': 'பதிவிறக்கம் நடைபெற்று வருகிறது...',

      'enterOtpVerifyMobile': 'உங்கள் மொபைல் எண்ணை சரிபார்க்க OTP-ஐ உள்ளிடவும்',
      'textOtpTesting': 'சோதனைக்கான OTP மட்டும்:',
      'confirm': 'உறுதி செய்யவும்',
      'otpValidationFailed': 'OTP சரிபார்ப்பு தோல்வியடைந்தது',
      'failedToSendOtp':
          'OTP அனுப்ப இயலவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.',
      'errorMessage': 'பிழை: ',
      'otpExpiresIn': 'OTP  இல் காலாவதியாகும்',
      'open': 'மீண்டும் திறக்கவும்',
      'openGrievance': 'மீண்டும் திறந்த புகார்',
      'openGrievanceReason': 'காரணம்',
      'openGrievanceHint': 'காரணத்தை அளிக்கவும்',
      'reopeningGrievance': 'புகாரை மீண்டும் திறக்கப்படுகிறது...',
      'locationDetail': 'இடத்தின் விவரங்கள்',
      'noLocation':
          'இன்னும் இடம் தேர்ந்தெடுக்கப்படவில்லை. வரைபடத்தில் தொட்டு அல்லது மேலுள்ள பொத்தானைப் பயன்படுத்தவும்.',
      'mapSentence':
          'உங்கள் இருப்பிடத்தைத் தேர்வுசெய்ய வரைபடத்தில் தொடவும், அல்லது கீழே உள்ள பொத்தானை பயன்படுத்தி உங்கள் தற்போதைய இருப்பிடத்தை பெறவும்.',
      'selectLocation': 'வரைபடத்தில் இடத்தைத் தேர்வுசெய்க',
      'clearLocation': 'இருப்பிடத்தை நீக்கவும்',
      'currentLocation': 'தற்போதைய இருப்பிடம்',
      'locationMap':
          'இருப்பிடத்தைத் தேர்வுசெய்ய வரைபடத்தில் எங்காவது தொட்டு தொடவும்',
      'latitude': 'அட்சரேகை',
      'longitude': 'தீர்க்கரேகை',
      'locationSelect': 'இருப்பிடம் தேர்ந்தெடுக்கப்பட்டது',
      'getLocation': 'இருப்பிடம் பெறப்படுகிறது...',
      'locationClear': 'இருப்பிடம் நீக்கப்பட்டது',
      'mapTap': 'வரைபடத்தில் தொட்டு இருப்பிடம் தேர்ந்தெடுக்கப்பட்டது',
      'gpsLocation':
          'தற்போதைய GPS இருப்பிடம் பெறப்பட்டது. வரைபடம் புதுப்பிக்கப்பட்டது.',
      'permenantlyDenied': 'இருப்பிட அனுமதிகள் நிரந்தரமாக மறுக்கப்பட்டுள்ளன',
      'permissionDenied': 'இருப்பிட அனுமதிகள் மறுக்கப்பட்டுள்ளன',
      'serviceDisable': 'இருப்பிட சேவைகள் முடக்கப்பட்டுள்ளன',
    },
  };

  // 🚀 Dynamic translations from API (merged with static)
  final Map<String, Map<String, String>> _dynamicTranslations = {};
  Map<String, Map<String, String>> _mergedTranslations = {};

  // Current language
  String _currentLanguage = 'en';

  /// Initialize with static translations
  void initialize(String initialLanguage) {
    _currentLanguage = initialLanguage;
    _mergedTranslations = Map.from(_staticTranslations);
  }

  /// Get translation with smart fallback priority and space trimming
  /// Priority: Dynamic API > Static > Key itself
  String translate(String key, {String? language}) {
    final lang = language ?? _currentLanguage;

    // 🔧 Trim spaces from key for robust matching
    final trimmedKey = key.trim();

    // Try with trimmed key first
    String? translation =
        _mergedTranslations[lang]?[trimmedKey] ??
        _dynamicTranslations[lang]?[trimmedKey] ??
        _staticTranslations[lang]?[trimmedKey];

    // If not found, try with original key (in case spaces are intentional)
    translation ??=
        _mergedTranslations[lang]?[key] ??
        _dynamicTranslations[lang]?[key] ??
        _staticTranslations[lang]?[key];

    // Fallback to trimmed key if no translation found
    return translation ?? trimmedKey;
  }

  /// Update dynamic translations and merge with static
  void updateDynamicTranslations(
    String language,
    Map<String, String> apiTranslations,
  ) {
    // � CRITICAL FIX: Handle API format properly
    // API always returns: {"English Text": "Tamil Translation"}
    // We need to create both English and Tamil mappings from this single API response

    final englishTranslations = <String, String>{};
    final tamilTranslations = <String, String>{};

    for (final entry in apiTranslations.entries) {
      final englishKey = entry.key.trim(); // "BLOCKED DRAINAGE..."
      final tamilValue = entry.value.trim(); // "அடைப்பு கால்வாய்..."

      // For English: key maps to itself (show original English)
      englishTranslations[englishKey] = englishKey;

      // For Tamil: key maps to Tamil translation
      tamilTranslations[englishKey] = tamilValue;

      // Also handle original untrimmed keys for backwards compatibility
      if (entry.key != englishKey) {
        englishTranslations[entry.key] = entry.key;
        tamilTranslations[entry.key] = tamilValue;
      }
    }

    // Store both language mappings
    _dynamicTranslations['en'] = englishTranslations;
    _dynamicTranslations['ta'] = tamilTranslations;

    // Merge with static translations for both languages
    _mergedTranslations['en'] = Map<String, String>.from(
      _staticTranslations['en'] ?? {},
    );
    _mergedTranslations['en']!.addAll(englishTranslations);

    _mergedTranslations['ta'] = Map<String, String>.from(
      _staticTranslations['ta'] ?? {},
    );
    _mergedTranslations['ta']!.addAll(tamilTranslations);
  }

  /// Get merged translations for caching
  Map<String, String>? getMergedTranslations(String language) {
    return _mergedTranslations[language];
  }

  /// Check if we have any translations for language
  bool hasTranslationsFor(String language) {
    return _mergedTranslations.containsKey(language) ||
        _staticTranslations.containsKey(language);
  }

  /// Get available languages
  List<String> get availableLanguages => ['en', 'ta'];

  /// Get current language
  String get currentLanguage => _currentLanguage;

  /// Set current language
  void setCurrentLanguage(String language) {
    if (availableLanguages.contains(language)) {
      _currentLanguage = language;
    }
  }

  /// Get translation statistics
  Map<String, dynamic> getTranslationStats() {
    return {
      'currentLanguage': _currentLanguage,
      'availableLanguages': availableLanguages,
      'staticTranslations': {
        for (var lang in _staticTranslations.keys)
          lang: _staticTranslations[lang]!.length,
      },
      'dynamicTranslations': {
        for (var lang in _dynamicTranslations.keys)
          lang: _dynamicTranslations[lang]!.length,
      },
      'mergedTranslations': {
        for (var lang in _mergedTranslations.keys)
          lang: _mergedTranslations[lang]!.length,
      },
    };
  }

  /// Clear dynamic translations (for testing/reset)
  void clearDynamicTranslations() {
    _dynamicTranslations.clear();
    _mergedTranslations = Map.from(_staticTranslations);
  }
}
