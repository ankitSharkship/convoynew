// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'Convoy';

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
      'Current Location मिळवण्यासाठी Settings मध्ये जाऊन Convoy ला लोकेशनची परवानगी द्या.';

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
  String get onboardingSkip => 'स्किप करा';

  @override
  String get onboardingGetStarted => 'सुरू करा';

  @override
  String get onboardingTitle => 'लोड रोज\nतुमच्यापर्यंत पोहोचतात.';

  @override
  String get onboardingSubtitle =>
      'एकदाच ट्रक पोस्ट करा. Verified Transporter थेट तुम्हाला Call करतील. कोणताही दलाल नाही, धावपळ नाही.';

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
  String get callDialerHint => 'तुमचा फोन Dialer उघडेल';

  @override
  String get callCalling => 'Call सुरू आहे…';

  @override
  String callConnected(String duration) {
    return 'Connected · $duration';
  }

  @override
  String get callDisclaimer =>
      'Convoy मध्ये इन-अॅप Calling नाही. Call वर टॅप केल्यावर तुमचा फोन Dialer उघडेल. ही माहिती फक्त रेकॉर्डसाठी जतन केली जाते.';

  @override
  String get homeHello => 'नमस्कार 👋';

  @override
  String get homeHeroTitle => 'तुमचा ट्रक कमाईसाठी\nतयार आहे 💰';

  @override
  String get homeHeroSubtitle =>
      'आत्ताच ट्रक पोस्ट करा आणि लगेच Verified Load मिळवा.';

  @override
  String get homeHeroButton => 'ट्रक पोस्ट करा';

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
  String get homeManageSection => 'तुमच्या पोस्ट आणि शोध';

  @override
  String get homeViewAll => 'सगळं पहा';

  @override
  String get homeRecentPosts => 'अलीकडच्या पोस्ट';

  @override
  String get homeRecentSearch => 'अलीकडचे शोध';

  @override
  String get homeNoRecentPosts => 'अजून कोणतीही पोस्ट नाही';

  @override
  String get homeNoRecentSearches => 'अजून कोणताही शोध नाही';

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
  String get profileKycPending => 'बाकी आहे';

  @override
  String get profileKycPhotoPending => 'फोटो बाकी आहे';

  @override
  String get profileKycAlreadyVerified => 'तुमचं KYC आधीच Verify झालं आहे';

  @override
  String get profileMyVehicles => 'माझी वाहनं';

  @override
  String get profileTermsPrivacy => 'Terms & Privacy';

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
  String get mutualContactsSheetTitle => 'कॉमन Contact';

  @override
  String get mutualContactsEmpty => 'एकही कॉमन Contact सापडला नाही';

  @override
  String get mutualContactsNumberUnavailable => 'नंबर उपलब्ध नाही';

  @override
  String get contactsPermissionRationale =>
      'तुमच्या Contact List मधले कॉमन Contact दाखवण्यासाठी Convoy ला Contacts ची परवानगी लागते. तुमचे Contacts कोणाशीही शेअर केले जात नाहीत. फक्त सुरक्षित Hash वापरून Match केले जातात.';

  @override
  String get contactsPermissionDeniedMessage =>
      'Contacts ची परवानगी दिलेली नाही. कॉमन Contact पाहण्यासाठी Settings मध्ये जाऊन परवानगी द्या.';

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'शोधा';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count आणखी';
  }

  @override
  String capacityTon(int capacity) {
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
  String truckMapViewList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यादी पहा ($count)',
      one: 'यादी पहा (1)',
    );
    return '$_temp0';
  }
}
