// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'Bonut';

  @override
  String get languageSelectTitle => 'भाषा निवडा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get languageKannada => 'ಕನ್ನಡ';

  @override
  String get somethingWentWrong => 'काहीतरी गडबड झाली';

  @override
  String get tryAgain => 'पुन्हा करून पाहा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get delete => 'काढा';

  @override
  String get ok => 'ठीक आहे';

  @override
  String get locationServiceDisabledTitle => 'लोकेशन बंद आहे';

  @override
  String get locationServiceDisabledMessage =>
      'तुमचं Current Location मिळवण्यासाठी लोकेशन सुरू करा.';

  @override
  String get locationEnableButton => 'लोकेशन सुरू करा';

  @override
  String get locationPermissionDeniedTitle => 'लोकेशनची परवानगी द्या';

  @override
  String get locationPermissionDeniedMessage =>
      'Current Location मिळवण्यासाठी Settings मध्ये जाऊन Bonut ला लोकेशनची परवानगी द्या.';

  @override
  String get locationOpenSettingsButton => 'Settings उघडा';

  @override
  String get truckTypeOpenBody => 'ओपन बॉडी';

  @override
  String get truckTypeClosedBody => 'क्लोज्ड बॉडी';

  @override
  String get truckTypeTipper => 'टिपर';

  @override
  String get truckTypeSidewallTrailer => 'साइडवॉल ट्रेलर';

  @override
  String get truckTypeFlatBedTrailer => 'फ्लॅट बेड ट्रेलर';

  @override
  String get truckTypeFlatBedTruck => 'फ्लॅट बेड ट्रक';

  @override
  String get truckTypeLowBedTrailer => 'लो बेड ट्रेलर';

  @override
  String get truckTypeRefrigeratedTruck => 'रेफ्रिजरेटेड ट्रक';

  @override
  String get truckTypeBulker => 'बल्कर';

  @override
  String get truckTypeTanker => 'टँकर';

  @override
  String get truckTypePuller => 'पुलर';

  @override
  String get truckTypeWindbladeTrailer => 'विंडब्लेड ट्रेलर';

  @override
  String get truckTypePickupTruck => 'पिकअप ट्रक/टाटा एस';

  @override
  String get onboardingSkip => 'स्किप करा';

  @override
  String get onboardingGetStarted => 'सुरु करा';

  @override
  String get onboardingTitle => 'लोड्स ~दररोज~\nतुमच्याकडे येतील.';

  @override
  String get onboardingSubtitle =>
      'तुमचा ट्रक एकदा पोस्ट करा. वेरिफाइड ट्रान्सपोर्टर तुम्हाला कॉल करतील. मध्यस्थ नाही, धावपळ नाही.';

  @override
  String get onboardingPage2Title => 'आता कोणताही ट्रक ~रिकामा जाणार नाही~';

  @override
  String get onboardingPage2Subtitle =>
      'तुमचा ट्रक सूचीबद्ध करा. मालमालक तुम्हाला शोधतील.';

  @override
  String get onboardingPage2Button => 'पुढे चला';

  @override
  String get onboardingPage3Title => 'व्हेरिफाइड लोड.\n~थेट कनेक्शन.~';

  @override
  String get onboardingPage3Subtitle => 'प्रत्येक ट्रिपसाठी अस्सल लोड्स.';

  @override
  String get onboardingPage3Button => 'सुरु करा';

  @override
  String get onboardingChangeLanguage => 'भाषा बदला';

  @override
  String get phoneEnterNumberHint => 'मोबाइल नंबर टाका';

  @override
  String get phoneContinueButton => 'मोबाइल नंबरने पुढे जा';

  @override
  String get otpTitle => '4 अंकी OTP टाका';

  @override
  String otpSentTo(String phone) {
    return '+91 $phone वर पाठवला';
  }

  @override
  String get otpHelperText => 'OTP मिळाला नाही? नंबर तपासा आणि पुन्हा पाठवा.';

  @override
  String otpResendIn(String seconds) {
    return 'OTP नाही? 0:$seconds मध्ये पुन्हा पाठवा';
  }

  @override
  String get otpResendCode => 'OTP पुन्हा पाठवा';

  @override
  String get enterNameTitle => 'आम्ही तुम्हाला काय म्हणावे?';

  @override
  String get enterNameSubtitle => 'सुरू ठेवण्यासाठी तुमचे नाव टाका';

  @override
  String get enterNameHint => 'तुमचे नाव टाका';

  @override
  String get enterNameButton => 'सुरू ठेवा';

  @override
  String get enterNameError =>
      'तुमचे नाव जतन करता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get callDialerHint => 'तुमचा फोन Dialer उघडेल';

  @override
  String get callCalling => 'Call सुरू आहे…';

  @override
  String callConnected(String duration) {
    return 'Connected · $duration';
  }

  @override
  String get callDisclaimer =>
      'Bonut मध्ये इन-अॅप Calling नाही. Call वर टॅप केल्यावर तुमचा फोन Dialer उघडेल. ही माहिती फक्त रेकॉर्डसाठी जतन केली जाते.';

  @override
  String get homeHello => 'नमस्कार 👋';

  @override
  String get homeHeroTitle => 'ट्रक तयार आहे? आता काम सुरू करा.';

  @override
  String get homeHeroSubtitle =>
      'व्हेरिफाइड लोड विनंत्या थेट तुमच्या मोबाइलवर.';

  @override
  String get homeHeroButton => 'ट्रक लिस्ट करा';

  @override
  String get homeCarousel2Title => 'आजचा पहिला लोड पकडा?';

  @override
  String get homeCarousel2Subtitle =>
      '100% व्हेरिफाइड लोड्स. फसवणूक नाही, फक्त फायदा.';

  @override
  String get homeCarousel3Title => 'रिकामा ट्रक... सर्वात महाग असतो.';

  @override
  String get homeCarousel3Subtitle =>
      'आजच लिस्ट करा, व्हेरिफाइड लोड लगेच मिळवा.';

  @override
  String get homeCarousel4Title => 'तुमचा ट्रक. तुमची मेहनत. पक्का फायदा.';

  @override
  String get homeCarousel4Subtitle =>
      'व्हेरिफाइड लोड्स. योग्य दर. वेळेवर पेमेंट.';

  @override
  String get homeQuickActions => 'काय करायचं?';

  @override
  String get homePostNewTruck => 'नवीन ट्रक पोस्ट करा';

  @override
  String get homePostNewTruckSubtitle => 'फक्त 30 सेकंदात';

  @override
  String get homeSearchTrucks => 'ट्रक शोधा';

  @override
  String get homeSearchTrucksSubtitle => 'उपलब्ध ट्रक पाहा';

  @override
  String get profileRecentPostsSearches => 'अलीकडील पोस्ट आणि शोध';

  @override
  String get homeViewAll => 'सर्व पहा';

  @override
  String get homeRecentPosts => 'अलीकडील पोस्ट';

  @override
  String get homeRecentSearch => 'अलीकडील शोध';

  @override
  String get homeNoRecentPosts => 'अजून कोणतीही पोस्ट नाही';

  @override
  String get homeNoRecentSearches => 'अजून कोणताही शोध नाही';

  @override
  String get homeTrendingReels => 'ट्रेंडिंग रोड रील्स';

  @override
  String get homeViewFeed => 'सर्व पहा';

  @override
  String get homeNoReelsYet => 'अजून कोणतीही रील नाही';

  @override
  String get reelCreateSheetTitle => 'नवीन रील';

  @override
  String get reelCreateRecordOption => 'व्हिडिओ रेकॉर्ड करा';

  @override
  String get reelCreateRecordOptionSubtitle => 'तुमचा कॅमेरा वापरा';

  @override
  String get reelCreateGalleryOption => 'गॅलरीमधून निवडा';

  @override
  String get reelCreateGalleryOptionSubtitle => 'विद्यमान व्हिडिओ निवडा';

  @override
  String get reelRecordCameraError => 'कॅमेरा अ‍ॅक्सेस करता आला नाही';

  @override
  String get reelRecordHint => 'रेकॉर्ड करण्यासाठी टॅप करा';

  @override
  String get reelTrimTitle => 'तुमची रील ट्रिम करा';

  @override
  String reelTrimSelectedDuration(String seconds) {
    return '${seconds}s निवडले';
  }

  @override
  String get reelTrimNext => 'पुढे';

  @override
  String get reelDetailsTitle => 'रील तपशील';

  @override
  String get reelDetailsTitleLabel => 'शीर्षक';

  @override
  String get reelDetailsTitleHint => 'तुमच्या रीलला शीर्षक द्या';

  @override
  String get reelDetailsDescriptionLabel => 'वर्णन (ऐच्छिक)';

  @override
  String get reelDetailsDescriptionHint => 'वर्णन जोडा';

  @override
  String get reelDetailsTitleRequired => 'कृपया शीर्षक टाका';

  @override
  String get reelPostButton => 'रील पोस्ट करा';

  @override
  String get reelUploadingTitle => 'तुमची रील अपलोड होत आहे…';

  @override
  String get reelUploadingSubtitle => 'कृपया अ‍ॅप बंद करू नका';

  @override
  String get reelUploadSuccessTitle => 'रील अपलोड झाली!';

  @override
  String get reelUploadSuccessSubtitle =>
      'तुमची रील प्रक्रिया होत आहे आणि लवकरच फीडमध्ये दिसेल.';

  @override
  String get reelBackToReels => 'रील्सवर परत जा';

  @override
  String get kycVerifyTitle => 'आधार कार्ड Verify करा';

  @override
  String get kycAadhaarHint => 'XXXX XXXX XXXX';

  @override
  String get kycVerifyButton => 'आधार Verify करा';

  @override
  String get kycOtpHelperText =>
      'तुमच्या आधारला जोडलेल्या मोबाइल नंबरवर OTP पाठवला आहे. तो टाकून Verify करा.';

  @override
  String get kycOtpVerifyButton => 'OTP Verify करा';

  @override
  String get kycCheckingAadhaar => 'तपासत आहे...';

  @override
  String get kycAadhaarUnavailable => 'हा आधार वापरता येणार नाही';

  @override
  String get kycAadhaarConflictSnackbar =>
      'हा आधार आधीच दुसऱ्या खात्याशी सत्यापित झाला आहे.';

  @override
  String get kycThankYou => 'आधार Verify झाला!';

  @override
  String get kycSuccessMessage =>
      'आता फक्त एक स्टेप बाकी आहे. तुमचा फोटो Verify करूया.';

  @override
  String get faceReviewTitle => 'हा फोटो वापरायचा?';

  @override
  String get faceReviewRetake => 'पुन्हा काढा';

  @override
  String get faceReviewConfirm => 'हा फोटो वापरा';

  @override
  String get faceReviewVerifyingTitle => 'Verify होत आहे';

  @override
  String get faceReviewVerifyingMessage =>
      'थोडा वेळ थांबा, तुमचा फोटो Verify करत आहोत.';

  @override
  String get faceReviewVerificationFailed =>
      'तुमचा फोटो Verify करता आला नाही. कृपया पुन्हा करून पाहा.';

  @override
  String get postScreenTitle => 'तुमचा ट्रक पोस्ट करा';

  @override
  String get postRouteSectionLabel => 'रूट';

  @override
  String get postSelectTruckSectionLabel => 'ट्रक निवडा';

  @override
  String get postOriginLabel => 'कुठून (Current Location)';

  @override
  String get postOriginHint => 'Current Location साठी Locate बटण दाबा';

  @override
  String get postGpsAutoDetected => 'GPS ने सापडलं';

  @override
  String postDestinationLabel(int number) {
    return 'कुठपर्यंत $number';
  }

  @override
  String get postDestinationHint => 'कुठपर्यंत टाका';

  @override
  String get postCouldNotLoadTrucks => 'तुमचे ट्रक लोड करता आले नाहीत';

  @override
  String get postSelectTruckHint => 'ट्रक निवडा';

  @override
  String get postSearchTruckHint => 'ट्रक नंबर टाका';

  @override
  String get postAddNewTruck => 'नवीन ट्रक जोडा';

  @override
  String get postTruckSearchEmptyMessage =>
      'या नंबरचा ट्रक सापडला नाही. नंबर टाका आणि खाली \'नवीन ट्रक जोडा\' वर टॅप करून ट्रक जोडा.';

  @override
  String get postSubmitButton => 'ट्रक पोस्ट करा';

  @override
  String get postAddTruckSheetTitle => 'नवीन ट्रक जोडा';

  @override
  String get postTruckNumberLabel => 'ट्रक नंबर';

  @override
  String get postTruckNumberHint => 'उदा. MH04AB1234';

  @override
  String get postTruckTypeLabel => 'ट्रकचा प्रकार';

  @override
  String get postSelectTypeHint => 'प्रकार निवडा';

  @override
  String get postCapacityLabel => 'क्षमता';

  @override
  String get postSelectCapacityHint => 'क्षमता निवडा';

  @override
  String get postAddTruckButton => 'ट्रक जोडा';

  @override
  String get postVerifyButton => 'Verify करा';

  @override
  String get postContactSectionTitle => 'Contact कोणाचा?';

  @override
  String get postContactMe => 'माझा';

  @override
  String get postContactSomeoneElse => 'दुसऱ्याचा';

  @override
  String get postContactNameLabel => 'Contact नाव';

  @override
  String get postContactNameHint => 'नाव टाका';

  @override
  String get postContactNumberLabel => 'Contact नंबर';

  @override
  String get postContactNumberHint => '10 अंकी मोबाइल नंबर';

  @override
  String get postContactNumberError => 'योग्य 10 अंकी मोबाइल नंबर टाका';

  @override
  String get postEditTitle => 'ट्रक पोस्ट Edit करा';

  @override
  String get postSaveChangesButton => 'बदल सेव्ह करा';

  @override
  String get postSuccessTitle => 'ट्रक यशस्वीपणे पोस्ट झाला!';

  @override
  String get postSuccessSubtitle =>
      'आता तुमच्या जवळचे Load Owner हा ट्रक पाहू शकतात आणि थेट तुम्हाला Call करू शकतात.';

  @override
  String get postSuccessTruckTypeLabel => 'ट्रक प्रकार';

  @override
  String get postSuccessPickupLabel => 'Pickup';

  @override
  String get postSuccessGoToDashboard => 'Dashboard वर जा';

  @override
  String get postSuccessPostAnother => 'आणखी एक ट्रक पोस्ट करा';

  @override
  String get myTrucksTitle => 'माझे ट्रक';

  @override
  String get myTrucksDeleteTitle => 'ट्रक काढा';

  @override
  String myTrucksDeleteMessage(String vehicleNumber) {
    return '$vehicleNumber काढायचा? नंतर परत आणता येणार नाही.';
  }

  @override
  String get myTrucksNoTrucks => 'अजून एकही ट्रक जोडलेला नाही';

  @override
  String get tripsTitle => 'माझे ट्रिप';

  @override
  String get tripsNoTrips => 'अजून एकही ट्रिप पोस्ट केलेली नाही';

  @override
  String get tripsActiveLabel => 'चालू';

  @override
  String get tripsExpiredLabel => 'कालबाह्य';

  @override
  String get tripsEdit => 'Edit करा';

  @override
  String get tripsReactivate => 'पुन्हा सुरू करा';

  @override
  String get tripsDeleteTitle => 'ट्रिप काढा';

  @override
  String get tripsDeleteMessage =>
      'ही ट्रिप कायमची काढायची? नंतर परत आणता येणार नाही.';

  @override
  String tripsMoreDestinations(int count) {
    return '+$count आणखी';
  }

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get profileAccountSection => 'खाते';

  @override
  String get profileVerifiedDriver => '✓ Verified';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLogoutTitle => 'Logout';

  @override
  String get profileLogoutConfirm => 'खरंच Logout करायचं आहे का?';

  @override
  String get profileKycLabel => 'KYC Status';

  @override
  String get profileKycVerified => '✓ Verified';

  @override
  String get profileKycInReview => 'Review मध्ये';

  @override
  String get profileKycRejected => 'Reject';

  @override
  String get profileKycPending => 'प्रलंबित';

  @override
  String get profileKycPhotoPending => 'फोटो बाकी आहे';

  @override
  String get profileKycAlreadyVerified => 'तुमचं KYC आधीच Verify झालं आहे';

  @override
  String get profileMyVehicles => 'माझी वाहनं';

  @override
  String get profileTermsPrivacy => 'अटी आणि गोपनीयता';

  @override
  String get profileHelp => '24×7 Driver Support';

  @override
  String profileAccountStatusPrefix(String status) {
    return 'खातं $status';
  }

  @override
  String get profileAccountSuspended => 'Suspend';

  @override
  String get profileAccountBlocked => 'Blocked';

  @override
  String get profileAccountInactive => 'Inactive';

  @override
  String get searchTitle => 'ट्रक शोधा';

  @override
  String get searchSubtitle => 'तुमच्या Load साठी योग्य ट्रक शोधा';

  @override
  String get searchOriginLabel => 'कुठून';

  @override
  String get searchOriginHint => 'कुठून निवडा';

  @override
  String get searchDestinationLabel => 'कुठपर्यंत';

  @override
  String get searchDestinationHint => 'कुठपर्यंत निवडा';

  @override
  String get searchTruckTypeLabel => 'ट्रक प्रकार';

  @override
  String get searchSelectTruckHint => 'ट्रक निवडा';

  @override
  String get searchCapacityLabel => 'क्षमता';

  @override
  String get searchVehicleNumberLabel => 'वाहन नंबर';

  @override
  String get searchSelectHint => 'निवडा';

  @override
  String get searchCapacityNotApplicable => 'लागू नाही';

  @override
  String get searchFindTrucksButton => 'ट्रक शोधा';

  @override
  String get resultsTitle => 'शोधाचे निकाल';

  @override
  String get resultsSearching => 'ट्रक शोधत आहोत…';

  @override
  String resultsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रक सापडले',
      one: '1 ट्रक सापडला',
    );
    return '$_temp0';
  }

  @override
  String get resultsYourResults => 'तुमचे निकाल';

  @override
  String get resultsRunSearch => 'निकाल पाहण्यासाठी ट्रक शोधा';

  @override
  String get resultsNoneNearby => 'जवळपास एकही ट्रक सापडला नाही';

  @override
  String get resultsAnyOrigin => 'कोठूनही';

  @override
  String get resultsAnyDestination => 'कोठेही';

  @override
  String get resultsOriginLabel => 'कुठून';

  @override
  String get resultsDestinationLabel => 'कुठपर्यंत';

  @override
  String get resultsDateLabel => 'तारीख';

  @override
  String get resultsAny => 'कोणतंही';

  @override
  String get resultsSortByLabel => 'क्रम लावा';

  @override
  String get resultsSortNearestOrigin => 'Pickup च्या सर्वात जवळ';

  @override
  String get resultsSortNearestDestination => 'Destination च्या सर्वात जवळ';

  @override
  String get resultsCallDialerError => 'Dialer उघडता आला नाही';

  @override
  String get resultsCallNow => 'Call करा';

  @override
  String resultsPageOf(int page, int totalPages) {
    return '$totalPages पैकी $page';
  }

  @override
  String resultsMutualCount(int count) {
    return '$count कॉमन';
  }

  @override
  String get resultsViewAllMutuals => 'सगळे पहा';

  @override
  String resultsPostedBy(String userName) {
    return 'पोस्ट केलं: $userName';
  }

  @override
  String get resultsCallSheetTitle => 'तुम्हाला कोणाला कॉल करायचा आहे?';

  @override
  String get resultsContactLabel => 'संपर्क';

  @override
  String get resultsPostedByLabel => 'पोस्ट केलं';

  @override
  String get mutualContactsSheetTitle => 'कॉमन Contact';

  @override
  String get mutualContactsEmpty => 'एकही कॉमन Contact सापडला नाही';

  @override
  String get mutualContactsNumberUnavailable => 'नंबर उपलब्ध नाही';

  @override
  String get contactsPermissionRationale =>
      'तुमच्या Contact List मधले कॉमन Contact दाखवण्यासाठी Bonut ला Contacts ची परवानगी लागते. तुमचे Contacts कोणाशीही शेअर केले जात नाहीत. फक्त सुरक्षित Hash वापरून Match केले जातात.';

  @override
  String get contactsPermissionDeniedMessage =>
      'Contacts ची परवानगी दिलेली नाही. कॉमन Contact पाहण्यासाठी Settings मध्ये जाऊन परवानगी द्या.';

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'शोध';

  @override
  String get navWallet => 'वॉलेट';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get navReels => 'रील्स';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count आणखी';
  }

  @override
  String capacityTon(num capacity) {
    return '$capacity टन';
  }

  @override
  String get networkOfflineBanner => 'इंटरनेट नाही';

  @override
  String get truckMapPreviewTitle => 'लाईव्ह ट्रक मॅप';

  @override
  String get truckMapPreviewSubtitle =>
      'तुमच्या जवळचे ट्रक पाहण्यासाठी टॅप करा';

  @override
  String get truckMapPreviewCta => 'लाईव्ह मॅप पहा';

  @override
  String get truckMapAppBarTitle => 'तुमच्या जवळचे ट्रक';

  @override
  String get truckMapLoading => 'जवळचे ट्रक शोधत आहोत…';

  @override
  String get truckMapNoTrucksNearby => '150 किमीच्या आत एकही ट्रक सापडला नाही';

  @override
  String get truckMapErrorGeneric => 'ट्रक लोड करता आले नाहीत';

  @override
  String get truckMapRetry => 'पुन्हा करून पाहा';

  @override
  String truckMapCountFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रक जवळ आहेत',
      one: '1 ट्रक जवळ आहे',
    );
    return '$_temp0';
  }

  @override
  String get truckMapDetailsTitle => 'ट्रकची माहिती';

  @override
  String get truckDetailsRequestOneToOne => '1:1 विनंती करा';

  @override
  String get truckDetailsCallDriver => 'बुक करण्यासाठी ड्रायव्हरला कॉल करा';

  @override
  String get truckDetailsRequestSoon => '1:1 विनंत्या लवकरच येत आहेत';

  @override
  String get truckDetailsClose => 'बंद करा';

  @override
  String truckMapViewList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यादी पहा ($count)',
      one: 'यादी पहा (1)',
    );
    return '$_temp0';
  }

  @override
  String get walletTitle => 'वॉलेट';

  @override
  String get walletBalanceCardLabel => 'आतापर्यंत मिळवलेले एकूण रिवॉर्ड';

  @override
  String walletPendingPayout(String amount) {
    return '$amount पेमेंट प्रलंबित';
  }

  @override
  String get walletFrozenMessage => 'वॉलेट फ्रीझ आहे — सहाय्याशी संपर्क साधा';

  @override
  String get walletRedeemButton => 'रिडीम करा';

  @override
  String get walletScratchCardsTab => 'स्क्रॅच कार्ड्स';

  @override
  String get walletTransactionsTab => 'व्यवहार';

  @override
  String get walletNoTransactions => 'अद्याप कोणतेही व्यवहार नाहीत';

  @override
  String get walletTxnCredit => 'रिवॉर्ड जमा झाले';

  @override
  String get walletTxnReserveRedeem => 'रिडीम विनंती केली';

  @override
  String get walletTxnConfirmPayout => 'पेमेंट पाठवले';

  @override
  String get walletTxnReleaseReserve => 'रिडीम नाकारले — परत जमा';

  @override
  String get walletRedeemSheetTitle => 'UPI वर रिडीम करा';

  @override
  String walletRedeemAvailableLabel(String amount) {
    return 'उपलब्ध: $amount';
  }

  @override
  String get walletUpiIdLabel => 'UPI आयडी';

  @override
  String get walletUpiIdHint => 'yourname@bank';

  @override
  String get walletUpiIdRequired => 'UPI आयडी टाका';

  @override
  String get walletUpiIdInvalid => 'वैध UPI आयडी टाका, उदा. name@bank';

  @override
  String get walletConfirmRedeemButton => 'रिडीमची पुष्टी करा';

  @override
  String get walletRedeemSuccessMessage => 'रिडीम विनंती सबमिट केली';

  @override
  String get walletScratchCardsEmpty =>
      'अद्याप कोणतेही स्क्रॅच कार्ड नाही — ट्रक पोस्ट करा आणि एक मिळवा!';

  @override
  String get walletScratchCardScratchHint => 'स्क्रॅच करा';

  @override
  String get walletScratchCardNoReward => 'बक्षीस नाही';

  @override
  String get walletScratchCardExpired => 'मुदत संपली';

  @override
  String get scratchCardRevealButton => 'दाखवा';

  @override
  String get postScratchCardTitle => 'तुम्ही स्क्रॅच कार्ड जिंकले आहे!';

  @override
  String get postScratchCardSubtitle =>
      'तुमचे बक्षीस पाहण्यासाठी कार्ड स्क्रॅच करा';

  @override
  String get postScratchCardWonTitle => '🎉 तुम्ही जिंकलात!';

  @override
  String get postScratchCardNoRewardTitle => 'पुढच्या वेळी नशीब आजमवा!';

  @override
  String get postScratchCardNoRewardSubtitle =>
      'जिंकण्याच्या अधिक संधींसाठी दररोज पोस्ट करत रहा';

  @override
  String get postScratchCardContinueButton => 'पुढे सुरू ठेवा';

  @override
  String get walletKycRequiredMessage =>
      'तुमचे वॉलेट आणि रिवॉर्ड्स अ‍ॅक्सेस करण्यासाठी कृपया तुमचे KYC पूर्ण करा';

  @override
  String get walletKycCompleteButton => 'KYC पूर्ण करा';

  @override
  String get wheelPickerDoneButton => 'पूर्ण';

  @override
  String get postLengthLabel => 'लांबी';

  @override
  String get postHeightLabel => 'उंची';

  @override
  String get postSelectLengthHint => 'लांबी निवडा';

  @override
  String get postSelectHeightHint => 'उंची निवडा';

  @override
  String feetValue(num value) {
    return '$value फूट';
  }

  @override
  String get reelCommentsTitle => 'टिप्पण्या';

  @override
  String get reelCommentsEmpty => 'अजून टिप्पणी नाही. पहिली टिप्पणी तुमची!';

  @override
  String get reelCommentHint => 'टिप्पणी जोडा…';

  @override
  String get reelCommentPost => 'पोस्ट';

  @override
  String get reelCommentDelete => 'हटवा';

  @override
  String get reelFollow => 'फॉलो करा';

  @override
  String get reelFollowing => 'फॉलो करत आहात';

  @override
  String reelShareText(String title) {
    return '$title — ही रील Convoy वर पहा';
  }

  @override
  String get reelCategoryAll => 'सर्व';

  @override
  String get reelDetailsCategoriesLabel => 'श्रेणी';

  @override
  String get reelDetailsCategoriesHint => '1 ते 5 निवडा';

  @override
  String get reelDetailsCategoriesRequired => 'किमान एक श्रेणी निवडा';

  @override
  String get reelDetailsHashtagsLabel => 'हॅशटॅग (ऐच्छिक)';

  @override
  String get reelDetailsHashtagsHint => '#trucklife #nightrun';

  @override
  String get reelDetailsHashtagsMax =>
      'तुम्ही जास्तीत जास्त 10 हॅशटॅग जोडू शकता';

  @override
  String get profileMyUploads => 'माझे अपलोड';

  @override
  String get uploadsCreatorInsights => 'क्रिएटर इनसाइट्स';

  @override
  String get uploadsNewPost => 'नवीन पोस्ट';

  @override
  String get uploadsStatReels => 'रील्स';

  @override
  String get uploadsStatTotalViews => 'एकूण व्ह्यूज';

  @override
  String get uploadsStatAppreciation => 'कौतुक';

  @override
  String uploadsThisWeek(int count) {
    return 'या आठवड्यात +$count';
  }

  @override
  String uploadsAllReelsTab(int count) {
    return 'सर्व रील्स ($count)';
  }

  @override
  String uploadsCategoryTab(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get uploadsEmpty => 'तुम्ही अजून एकही रील अपलोड केलेली नाही';

  @override
  String get uploadsRecordCta => 'रील रेकॉर्ड / अपलोड करा';

  @override
  String get uploadsMenuEdit => 'संपादित करा';

  @override
  String get uploadsMenuDelete => 'हटवा';

  @override
  String get uploadsMenuComingSoon => 'लवकरच येत आहे';

  @override
  String get uploadsStatusProcessing => 'प्रक्रिया सुरू';

  @override
  String get uploadsStatusRejected => 'नाकारले';

  @override
  String get uploadsStatusFailed => 'अयशस्वी';

  @override
  String get uploadsPostedToday => 'आज';

  @override
  String get uploadsPostedYesterday => 'काल';

  @override
  String uploadsPostedDaysAgo(int days) {
    return '$days दिवसांपूर्वी';
  }

  @override
  String uploadsPostedWeeksAgo(int weeks) {
    return '$weeks आठवड्यांपूर्वी';
  }

  @override
  String uploadsPostedMonthsAgo(int months) {
    return '$months महिन्यांपूर्वी';
  }

  @override
  String get navHeatmap => 'हीटमॅप';

  @override
  String get heatmapTitle => 'अ‍ॅक्टिव्हिटी हीटमॅप';

  @override
  String get heatmapTabTrucks => 'ट्रक';

  @override
  String get heatmapTabReels => 'रील्स';

  @override
  String get heatmapLoading => 'हीटमॅप लोड होत आहे…';

  @override
  String get heatmapErrorGeneric => 'हीटमॅप लोड करता आला नाही';

  @override
  String get heatmapEmptyTrucks => 'दाखवण्यासाठी अजून कोणताही लाइव्ह ट्रक नाही';

  @override
  String get heatmapEmptyReels => 'लोकेशनसह अलीकडील रील्स अजून नाहीत';

  @override
  String get heatmapZoomOutHint => 'अधिक अ‍ॅक्टिव्हिटी पाहण्यासाठी झूम आउट करा';

  @override
  String get heatmapLegendLow => 'कमी';

  @override
  String get heatmapLegendHigh => 'जास्त';

  @override
  String get heatmapMyLocation => 'माझे स्थान';

  @override
  String heatmapCellTrucks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'या भागात $count ट्रक',
      one: 'या भागात 1 ट्रक',
    );
    return '$_temp0';
  }

  @override
  String heatmapCellReels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'या भागात $count रील्स',
      one: 'या भागात 1 रील',
    );
    return '$_temp0';
  }

  @override
  String get heatmapNoTrucksInView => 'या भागात सध्या कोणताही ट्रक नाही';

  @override
  String get heatmapPinsTruncated =>
      'केंद्राच्या सर्वात जवळचे ट्रक दाखवत आहोत — अधिक पाहण्यासाठी झूम इन करा';

  @override
  String get heatmapPinsModeHint => 'वैयक्तिक ट्रक · तपशिलांसाठी पिनवर टॅप करा';

  @override
  String get heatmapPinLoading => 'ट्रकचा तपशील लोड होत आहे…';

  @override
  String get heatmapPinUnavailable => 'ही ट्रक पोस्ट आता उपलब्ध नाही';

  @override
  String get heatmapPinDetailError => 'ट्रकचा तपशील लोड करता आला नाही';

  @override
  String get reelsAreaThisArea => 'हा परिसर';

  @override
  String get reelsAreaShowAll => 'सर्व रील्स दाखवा';

  @override
  String get reelsAreaEmpty => 'या भागात सध्या कोणतीही रील नाही';
}
