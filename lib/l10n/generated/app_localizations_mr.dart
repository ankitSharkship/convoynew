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
  String get uploadsRecordCta => 'रील अपलोड करा';

  @override
  String get uploadsMenuDelete => 'हटवा';

  @override
  String get uploadsDeleteConfirmTitle => 'ही रील हटवायची?';

  @override
  String get uploadsDeleteConfirmBody =>
      'ही रील आणि तिचे लाइक व कमेंट कायमचे हटवले जातील. हे पूर्ववत करता येणार नाही.';

  @override
  String get uploadsDeleteSuccess => 'रील हटवली';

  @override
  String get uploadsReelNotPlayable => 'ही रील अजून प्ले करता येत नाही';

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

  @override
  String get walletTxnCallHold => '1:1 कॉलसाठी राखून ठेवले';

  @override
  String get walletTxnCallRelease => '1:1 कॉलची राखून ठेवलेली रक्कम परत';

  @override
  String get walletTxnCallDebit => '1:1 कॉलसाठी पेमेंट';

  @override
  String get walletTxnCallEarning => '1:1 कॉलमधून कमाई';

  @override
  String get oneToOneSheetTitle => '1:1 लाइव्ह सेशनची विनंती';

  @override
  String get oneToOneSheetBadge => 'थेट संपर्क';

  @override
  String oneToOneSheetSubtitle(String name) {
    return 'मालवाहतूक, मार्गाचे तपशील आणि बुकिंगबद्दल $name यांच्याशी खाजगी लाइव्ह कॉलवर बोला.';
  }

  @override
  String get oneToOneDriverFallback => 'ड्रायव्हर';

  @override
  String get oneToOneHowTitle => 'आधी ड्रायव्हर पुष्टी करेल';

  @override
  String get oneToOneHowBody =>
      'ड्रायव्हर तुमची विनंती पाहतील आणि मग तुम्हाला कॉल करतील. तुम्ही त्यांना पाहू-ऐकू शकता आणि तुमच्या मायक्रोफोनने बोलता.';

  @override
  String get oneToOneTopicLabel => 'चर्चेचा विषय';

  @override
  String get oneToOneRequiredTag => 'आवश्यक';

  @override
  String get oneToOneTopicHint =>
      'उदा. मार्गाची स्थिती, भाड्याची चर्चा, रवानगीची वेळ';

  @override
  String get oneToOneTopicRequired =>
      'तुम्हाला कशाबद्दल बोलायचे आहे ते ड्रायव्हरला सांगा';

  @override
  String get oneToOneDurationLabel => 'सेशनचा कालावधी';

  @override
  String oneToOneDurationMinutes(int minutes) {
    return '$minutes मिनिटे';
  }

  @override
  String get oneToOneDurationQuick => 'छोटी चर्चा';

  @override
  String get oneToOneDurationReview => 'मार्ग आढावा';

  @override
  String get oneToOneDurationDeep => 'सविस्तर बुकिंग';

  @override
  String get oneToOneOfferLabel => 'तुमची ऑफर';

  @override
  String get oneToOneOfferHint => 'रक्कम ₹ मध्ये';

  @override
  String oneToOneOfferRange(String min, String max) {
    return '$min ते $max दरम्यान ऑफर द्या';
  }

  @override
  String oneToOneHoldExplainer(String hold, String amount) {
    return 'कनेक्ट करण्याचा खर्च म्हणून आता $hold राखून ठेवले जातील. कॉलनंतर तुम्ही निवडा: समाधानी असाल तर पूर्ण $amount द्या, नाहीतर फक्त $hold.';
  }

  @override
  String oneToOneWalletAvailable(String amount) {
    return 'वॉलेट: $amount उपलब्ध';
  }

  @override
  String oneToOneNeedMoney(String amount) {
    return 'ही विनंती पाठवण्यासाठी वॉलेटमध्ये $amount जोडा';
  }

  @override
  String get oneToOneAddMoneyButton => 'पैसे जोडा';

  @override
  String get oneToOneMoneyAdded => 'टेस्ट पैसे जोडले';

  @override
  String get oneToOneRechargeSoon => 'वॉलेट रिचार्ज लवकरच येत आहे';

  @override
  String get oneToOneSendButton => 'विनंती पाठवा';

  @override
  String get oneToOneStatusTitle => 'तुमची 1:1 विनंती';

  @override
  String oneToOneStatusPending(String name) {
    return '$name यांच्या उत्तराची वाट पाहत आहोत';
  }

  @override
  String oneToOneStatusAccepted(String name) {
    return '$name यांनी स्वीकारले. ते लवकरच तुम्हाला कॉल करतील';
  }

  @override
  String oneToOneStatusRinging(String name) {
    return '$name तुम्हाला कॉल करत आहेत…';
  }

  @override
  String oneToOneStatusLive(String name) {
    return '$name यांच्याशी कॉल सुरू आहे';
  }

  @override
  String get oneToOneStatusAwaitingFeedback =>
      'कॉल संपला. पेमेंट पूर्ण करण्यासाठी कसे वाटले ते सांगा';

  @override
  String oneToOneStatusCompleted(String amount) {
    return 'कॉल पूर्ण झाला. तुम्ही $amount दिले';
  }

  @override
  String oneToOneStatusRejected(String name) {
    return '$name आत्ता तुमचा कॉल घेऊ शकत नाहीत. तुमचे पैसे परत केले आहेत';
  }

  @override
  String get oneToOneStatusExpired =>
      'वेळेत उत्तर मिळाले नाही. तुमचे पैसे परत केले आहेत';

  @override
  String get oneToOneStatusCancelled =>
      'विनंती रद्द केली. तुमचे पैसे परत केले आहेत';

  @override
  String get oneToOneStatusFailed => 'कॉल कनेक्ट झाला नाही. काहीही आकारले नाही';

  @override
  String oneToOneOfferSummary(String amount, int minutes) {
    return 'ऑफर $amount · $minutes मिनिटे';
  }

  @override
  String oneToOneFrozenSummary(String hold) {
    return 'विनंती संपेपर्यंत $hold राखून ठेवले आहेत';
  }

  @override
  String oneToOneExpiresIn(String time) {
    return '$time मध्ये कालबाह्य';
  }

  @override
  String get oneToOneCancelButton => 'विनंती रद्द करा';

  @override
  String get oneToOneDoneButton => 'ठीक आहे';

  @override
  String get oneToOneStatusLoadError => 'तुमची विनंती लोड होऊ शकली नाही';

  @override
  String get oneToOneBannerTitle => '1:1 व्हिडिओ विनंती प्रलंबित';

  @override
  String oneToOneBannerOffered(String amount) {
    return '$amount ऑफर';
  }

  @override
  String oneToOneBannerMore(int count) {
    return '+$count आणखी';
  }

  @override
  String get oneToOneBannerReview => 'पाहा';

  @override
  String get oneToOneRequesterFallback => 'विनंती करणारा';

  @override
  String get oneToOneIncomingTitle => '1:1 व्हिडिओ विनंती';

  @override
  String oneToOneIncomingFrom(String name) {
    return '$name यांना तुमच्याशी लाइव्ह 1:1 कॉल करायचा आहे';
  }

  @override
  String get oneToOneIncomingTopicLabel => 'त्यांना याबद्दल बोलायचे आहे';

  @override
  String get oneToOneEarningsTitle => 'तुमची कमाई';

  @override
  String oneToOneEarningsBody(String hold, String amount, String name) {
    return 'कॉल 30 सेकंद जोडलेला राहिला तर किमान $hold. नंतर $name समाधानी असतील तर पूर्ण $amount.';
  }

  @override
  String get oneToOneAcceptButton => 'स्वीकारा';

  @override
  String get oneToOneRejectButton => 'नाकारा';

  @override
  String get oneToOneRejectConfirmTitle => 'ही विनंती नाकारायची?';

  @override
  String oneToOneRejectConfirmBody(String name) {
    return '$name यांचे पैसे परत केले जातील आणि विनंती बंद होईल.';
  }

  @override
  String get oneToOneKeepButton => 'राहू द्या';

  @override
  String oneToOneIncomingAccepted(String name) {
    return 'तुम्ही $name यांची विनंती स्वीकारली';
  }

  @override
  String get oneToOneIncomingRejected => 'तुम्ही ही विनंती नाकारली';

  @override
  String get oneToOneIncomingExpired => 'ही विनंती कालबाह्य झाली';

  @override
  String oneToOneIncomingCancelled(String name) {
    return '$name यांनी ही विनंती रद्द केली';
  }

  @override
  String oneToOneIncomingFeedback(String name) {
    return 'कॉल संपला. $name यांच्या प्रतिसादाची वाट पाहत आहोत';
  }

  @override
  String oneToOneIncomingCompleted(String amount) {
    return 'कॉल पूर्ण झाला. तुम्ही $amount कमावले';
  }

  @override
  String get oneToOneBannerReadyTitle => '1:1 कॉल सुरू करण्यास तयार';

  @override
  String get oneToOneBannerStart => 'सुरू करा';

  @override
  String get oneToOneStartCallButton => 'कॉल सुरू करा';

  @override
  String oneToOneStartCallHint(String name) {
    return '$name यांचा फोन 45 सेकंद वाजेल. सुरू करण्यापूर्वी गाडी सुरक्षित ठिकाणी थांबवा.';
  }

  @override
  String callRingingTitle(String name) {
    return '$name यांना कॉल करत आहे…';
  }

  @override
  String get callRingingHint => 'त्यांचा फोन वाजत आहे';

  @override
  String callWaitingForPeer(String name) {
    return '$name यांची वाट पाहत आहे…';
  }

  @override
  String callPeerDropped(String name) {
    return '$name यांचे कनेक्शन तुटले. ते परत येण्याची वाट पाहत आहे…';
  }

  @override
  String get callYouDropped => 'तुमचे कनेक्शन तुटले. पुन्हा जोडत आहे…';

  @override
  String get callServerUnreachable =>
      'सर्व्हरशी संपर्क होत नाही. कॉल सुरू आहे, पण त्याचा वेळ मोजला जाणार नाही.';

  @override
  String get callReconnectButton => 'पुन्हा जोडा';

  @override
  String callTimeLeft(String time) {
    return '$time बाकी';
  }

  @override
  String get callCounted => 'कॉल मोजला गेला';

  @override
  String callCountsAfter(int seconds) {
    return 'एकत्र $seconds सेकंद झाल्यावर कॉल मोजला जाईल';
  }

  @override
  String get callEndButton => 'संपवा';

  @override
  String get callCancelRingButton => 'रद्द करा';

  @override
  String get callEndConfirmTitle => 'कॉल संपवायचा?';

  @override
  String callEndConfirmCounted(String name) {
    return 'हा कॉल मोजला गेला आहे. $name यांना कसा झाला ते विचारले जाईल.';
  }

  @override
  String get callEndConfirmNotCounted =>
      'हा कॉल अजून मोजला गेला नाही. आता संपवला तर कोणतेही शुल्क लागणार नाही.';

  @override
  String get callKeepGoing => 'सुरू ठेवा';

  @override
  String get callMute => 'म्यूट';

  @override
  String get callUnmute => 'अनम्यूट';

  @override
  String get callCameraOff => 'कॅमेरा बंद';

  @override
  String get callCameraOn => 'कॅमेरा चालू';

  @override
  String get callFlip => 'फिरवा';

  @override
  String get callSpeaker => 'स्पीकर';

  @override
  String get callChat => 'चॅट';

  @override
  String callAudioOnlyNote(String name) {
    return 'फक्त तुमचा माइक चालू आहे. $name तुम्हाला पाहू शकत नाहीत.';
  }

  @override
  String get callSafetyTitle => 'गाडी चालवताना फोन वापरू नका';

  @override
  String get callSafetyBody =>
      'हा कॉल घेण्यापूर्वी गाडी सुरक्षित ठिकाणी थांबवा. गाडी चालू असताना स्क्रीन पाहू नका किंवा टाइप करू नका.';

  @override
  String get callSafetyOk => 'मी गाडी थांबवली आहे';

  @override
  String get callChatTitle => 'चॅट';

  @override
  String get callChatHint => 'संदेश लिहा';

  @override
  String get callChatEmpty => 'संदेश फक्त या कॉलपुरते राहतात.';

  @override
  String get callChatSendFailed => 'पाठवता आले नाही. तुमचे कनेक्शन तपासा.';

  @override
  String get callStarting => 'कॉल सुरू होत आहे…';

  @override
  String get callPermissionMic =>
      'कॉलमध्ये सहभागी होण्यासाठी मायक्रोफोनची परवानगी द्या.';

  @override
  String get callPermissionCamera =>
      'समोरची व्यक्ती तुम्हाला पाहू शकावी म्हणून कॅमेऱ्याची परवानगी द्या.';

  @override
  String get callOpenSettings => 'सेटिंग्ज उघडा';

  @override
  String get callClose => 'बंद करा';

  @override
  String get callEndedTitle => 'कॉल संपला';

  @override
  String callEndedDriverCounted(
    String duration,
    String name,
    String callAmount,
    String offer,
  ) {
    return 'तुम्ही $duration कॉलवर होता. आता $name समाधानी होते की नाही ते सांगतील. तुम्हाला $callAmount नक्की मिळतील, आणि समाधानी असल्यास $offer.';
  }

  @override
  String callEndedRequesterCounted(String name) {
    return '$name यांच्यासोबतच्या कॉलसाठी धन्यवाद.';
  }

  @override
  String callEndedTooShort(int seconds) {
    return 'कॉल मोजण्यासाठी खूप लहान होता ($seconds सेकंदांपेक्षा कमी). कोणतेही शुल्क लागले नाही.';
  }

  @override
  String callEndedUnanswered(String name) {
    return '$name यांनी कॉल उचलला नाही. विनंतीची मुदत संपेपर्यंत तुम्ही पुन्हा प्रयत्न करू शकता.';
  }

  @override
  String callEndedDeclined(String name) {
    return '$name यांनी कॉल नाकारला. विनंती बंद झाली.';
  }

  @override
  String get callEndedUnconfirmed =>
      'तुम्ही कॉल सोडला. सर्व्हरशी संपर्क झाला नाही, त्यामुळे थोड्या वेळात हिशेब होईल.';

  @override
  String get callEndedOther => 'कॉल संपला आहे.';

  @override
  String get callDoneButton => 'झाले';

  @override
  String callIncomingTitle(String name) {
    return '$name तुम्हाला कॉल करत आहेत';
  }

  @override
  String callIncomingOffer(String amount, int minutes) {
    return '$amount प्रस्तावित · $minutes मिनिटे';
  }

  @override
  String callIncomingHint(String name) {
    return 'तुम्ही $name यांना ऐकाल आणि त्यांचा कॅमेरा पाहाल. फक्त तुमचा माइक चालू राहील.';
  }

  @override
  String get callAnswer => 'उचला';

  @override
  String get callDecline => 'नाकारा';

  @override
  String get callDeclineHint =>
      'नाकारल्यास तुमची विनंती रद्द होते आणि तुमचे पैसे परत केले जातात.';

  @override
  String callRingSeconds(int seconds) {
    return 'वाजत आहे · $seconds से';
  }

  @override
  String callMissed(String name) {
    return 'तुमचा कॉल चुकला. $name पुन्हा प्रयत्न करू शकतात, किंवा तुम्ही तुमची विनंती रद्द करू शकता.';
  }

  @override
  String get callRejoinTitle => 'तुम्ही अजूनही कॉलमध्ये आहात';

  @override
  String callRejoinBody(String name) {
    return '$name यांच्यासोबतचा तुमचा कॉल अजून सुरू आहे. पुढे चालू ठेवण्यासाठी पुन्हा जोडा.';
  }

  @override
  String get callRejoinButton => 'पुन्हा जोडा';

  @override
  String get callRejoinEndButton => 'कॉल संपवा';

  @override
  String get callFeedbackTitle => 'तुम्ही कॉलने समाधानी होता का?';

  @override
  String callFeedbackBody(String name) {
    return '$name यांना किती पैसे मिळतील हे तुमच्या उत्तरावर ठरते.';
  }

  @override
  String callFeedbackYes(String amount) {
    return 'होय, $amount द्या';
  }

  @override
  String callFeedbackNo(String amount) {
    return 'नाही, फक्त $amount द्या';
  }

  @override
  String callFeedbackNoNote(String amount) {
    return '$amount हा कॉल जोडण्याचा खर्च आहे.';
  }

  @override
  String get callFeedbackLater => 'नंतर ठरवतो';

  @override
  String callFeedbackLaterNote(String amount) {
    return '24 तासांत उत्तर न दिल्यास फक्त $amount दिले जातील.';
  }

  @override
  String callFeedbackThanks(String amount) {
    return 'धन्यवाद! तुम्ही $amount दिले.';
  }

  @override
  String get callDeclineFailed =>
      'सर्व्हरशी संपर्क होऊ शकला नाही. तुमचे कनेक्शन तपासून पुन्हा प्रयत्न करा.';

  @override
  String get callOngoingTitle => 'कॉल सुरू आहे';

  @override
  String callOngoingText(String name) {
    return '$name यांच्यासोबतच्या कॉलवर परत जाण्यासाठी टॅप करा';
  }

  @override
  String get rechargeTitle => 'तुमच्या वॉलेटमध्ये पैसे जोडा';

  @override
  String get rechargeAmountLabel => 'जोडायची रक्कम (₹)';

  @override
  String rechargeRange(String min, String max) {
    return 'एका वेळी ₹$min ते ₹$max दरम्यान';
  }

  @override
  String rechargeInvalidAmount(String min, String max) {
    return '₹$min ते ₹$max दरम्यान रक्कम टाका';
  }

  @override
  String get rechargeAddedToWallet => 'तुमच्या वॉलेटमध्ये जमा होईल';

  @override
  String get rechargeGatewayFee => 'पेमेंट गेटवे शुल्क';

  @override
  String get rechargeYouPay => 'तुम्ही द्याल';

  @override
  String rechargePayButton(String amount) {
    return '$amount द्या';
  }

  @override
  String get rechargeUnavailable => 'सध्या पैसे जोडणे उपलब्ध नाही';

  @override
  String get rechargeCreating => 'तुमचे पेमेंट तयार होत आहे…';

  @override
  String get rechargePaying => 'पेमेंट विंडोमध्ये पेमेंट पूर्ण करा';

  @override
  String get rechargeConfirming => 'तुमच्या पेमेंटची खात्री केली जात आहे…';

  @override
  String rechargeDone(String amount) {
    return '$amount तुमच्या वॉलेटमध्ये जमा झाले';
  }

  @override
  String get rechargePending =>
      'आम्ही अजूनही तुमच्या पेमेंटची खात्री करत आहोत. तुमचा बॅलन्स लवकरच अपडेट होईल. पुन्हा पेमेंट करण्याची गरज नाही.';

  @override
  String get rechargeFailedGeneric =>
      'पेमेंट पूर्ण झाले नाही. तुमच्याकडून कोणतेही शुल्क घेतले नाही.';

  @override
  String get rechargeClose => 'बंद करा';
}
