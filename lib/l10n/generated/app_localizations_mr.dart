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
  String get somethingWentWrong => 'काहीतरी चूक झाली';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get delete => 'हटवा';

  @override
  String get ok => 'ठीक आहे';

  @override
  String get truckTypeOpenBody => 'ओपन बॉडी';

  @override
  String get truckTypeClosedBody => 'क्लोज्ड बॉडी';

  @override
  String get truckTypeContainer20Ft => 'कंटेनर २० फूट';

  @override
  String get truckTypeContainer32Ft => 'कंटेनर ३२ फूट';

  @override
  String get truckTypeTipper => 'टिपर';

  @override
  String get truckTypeSidewallTrailer => 'साइडवॉल ट्रेलर';

  @override
  String get truckTypeFlatBedTrailer => 'फ्लॅट बेड ट्रेलर';

  @override
  String get truckTypeBulker => 'बल्कर';

  @override
  String get truckTypeTanker => 'टँकर';

  @override
  String get onboardingSkip => 'वगळा';

  @override
  String get onboardingGetStarted => 'सुरुवात करा';

  @override
  String get onboardingTitle => 'लोड दररोज\nतुमच्याकडे येतात.';

  @override
  String get onboardingSubtitle =>
      'तुमचा ट्रक एकदा पोस्ट करा. सत्यापित ट्रान्सपोर्टर तुम्हाला कॉल करतील. कोणताही मध्यस्थ नाही, धावपळ नाही.';

  @override
  String get onboardingChangeLanguage => 'भाषा बदला';

  @override
  String get phoneEnterNumberHint => 'तुमचा नंबर टाका';

  @override
  String get phoneContinueButton => 'मोबाइल नंबरसह पुढे जा';

  @override
  String get otpTitle => '4 अंकी कोड टाका';

  @override
  String otpSentTo(String phone) {
    return '+91 $phone वर पाठवला';
  }

  @override
  String get otpHelperText =>
      'कोड मिळाला नाही? नंबर तपासा आणि पुन्हा पाठवण्याचा प्रयत्न करा.';

  @override
  String otpResendIn(String seconds) {
    return 'मिळाला नाही? 0:$seconds मध्ये पुन्हा पाठवा';
  }

  @override
  String get otpResendCode => 'कोड पुन्हा पाठवा';

  @override
  String get callDialerHint => 'तुमचा फोन डायलर उघडतो';

  @override
  String get callCalling => 'कॉल होत आहे…';

  @override
  String callConnected(String duration) {
    return 'जोडले · $duration';
  }

  @override
  String get callDisclaimer =>
      'Convoy मध्ये इन-अॅप कॉलिंग नाही. कॉलवर टॅप केल्यास\nतुमचा फोन डायलर उघडतो आणि तो नोंदीसाठी साठवला जातो.';

  @override
  String get homeHello => 'नमस्कार';

  @override
  String get homeHeroTitle => 'तुमचा ट्रक कमाईसाठी\nतयार आहे 💰';

  @override
  String get homeHeroSubtitle =>
      'आत्ताच पोस्ट करा आणि त्वरित सत्यापित लोड विनंत्या मिळवा.';

  @override
  String get homeHeroButton => 'आत्ता ट्रक पोस्ट करा';

  @override
  String get homeQuickActions => 'त्वरित कृती';

  @override
  String get homePostNewTruck => 'नवीन ट्रक पोस्ट करा';

  @override
  String get homePostNewTruckSubtitle => '30 सेकंदात तयार';

  @override
  String get homeSearchTrucks => 'ट्रक शोधा';

  @override
  String get homeSearchTrucksSubtitle => 'उपलब्ध वाहने शोधा';

  @override
  String get homeManageSection => 'पोस्ट आणि शोध व्यवस्थापित करा';

  @override
  String get homeRecentPosts => 'अलीकडील पोस्ट';

  @override
  String get homeRecentSearch => 'अलीकडील शोध';

  @override
  String get homeNoRecentPosts => 'कोणतीही अलीकडील पोस्ट नाही';

  @override
  String get homeNoRecentSearches => 'कोणताही अलीकडील शोध नाही';

  @override
  String get kycVerifyTitle => 'आधार कार्ड सत्यापित करा';

  @override
  String get kycAadhaarHint => 'XXXX XXXX XXXX';

  @override
  String get kycVerifyButton => 'आधार सत्यापित करा';

  @override
  String get kycPendingTitle => 'तुमचे KYC प्रलंबित आहे';

  @override
  String get kycPendingSubtitle =>
      'आम्ही तुमचे तपशील सत्यापित करत आहोत. Sharkship सेवा वापरणे सुरू ठेवण्यासाठी\nकृपया तुमचे KYC पूर्ण करा.';

  @override
  String get kycWhatsNext => 'पुढे काय होते?';

  @override
  String get kycWhatsNextSubtitle =>
      'तुमचे KYC सत्यापित होताच आम्ही तुम्हाला कळवू.';

  @override
  String get kycIdCardLabel => 'KYC';

  @override
  String get kycIdCardBrand => 'Sharkship';

  @override
  String get kycOtpHelperText =>
      'OTP तुमच्या आधारशी जोडलेल्या मोबाइल नंबरवर पाठवला आहे. सत्यापित करण्यासाठी कृपया तो टाका.';

  @override
  String get kycOtpVerifyButton => 'OTP सत्यापित करा';

  @override
  String get kycThankYou => 'धन्यवाद';

  @override
  String get kycSuccessMessage => 'eKYC प्रक्रिया यशस्वीरित्या पूर्ण झाली';

  @override
  String get postScreenTitle => 'तुमचा ट्रक पोस्ट करा';

  @override
  String get postRouteSectionLabel => 'मार्ग';

  @override
  String get postSelectTruckSectionLabel => 'ट्रक निवडा';

  @override
  String get postOriginLabel => 'पासून (सध्याचे स्थान)';

  @override
  String get postOriginHint => 'शोधण्यासाठी लोकेट बटण दाबा';

  @override
  String get postGpsAutoDetected => 'GPS द्वारे शोधले';

  @override
  String postDestinationLabel(int number) {
    return 'गंतव्यस्थान $number';
  }

  @override
  String get postDestinationHint => 'गंतव्यस्थान टाका';

  @override
  String get postCouldNotLoadTrucks => 'तुमचे ट्रक लोड होऊ शकले नाहीत';

  @override
  String get postSelectTruckHint => 'एक ट्रक निवडा';

  @override
  String get postAddNewTruck => 'नवीन ट्रक जोडा';

  @override
  String get postSubmitButton => 'ट्रक पोस्ट करा';

  @override
  String get postAddTruckSheetTitle => 'ट्रक जोडा';

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
  String get postVerifyButton => 'सत्यापित करा';

  @override
  String get postContactSectionTitle => 'कोणाशी संपर्क करायचा?';

  @override
  String get postContactMe => 'मी';

  @override
  String get postContactSomeoneElse => 'इतर कोणीतरी';

  @override
  String get postContactNameLabel => 'संपर्काचे नाव';

  @override
  String get postContactNameHint => 'संपर्काचे नाव टाका';

  @override
  String get postContactNumberLabel => 'संपर्क क्रमांक';

  @override
  String get postContactNumberHint => '10 अंकी मोबाइल क्रमांक';

  @override
  String get postContactNumberError => 'वैध 10 अंकी मोबाइल क्रमांक टाका';

  @override
  String get postEditTitle => 'ट्रक पोस्ट संपादित करा';

  @override
  String get postSaveChangesButton => 'बदल जतन करा';

  @override
  String get postSuccessTitle => 'तुमचा ट्रक पोस्ट झाला!';

  @override
  String get postSuccessSubtitle =>
      'तुमच्या जवळचे लोड मालक आता तो पाहू शकतात आणि थेट तुम्हाला कॉल करू शकतात.';

  @override
  String get postSuccessTruckTypeLabel => 'ट्रकचा प्रकार';

  @override
  String get postSuccessPickupLabel => 'पिकअप स्थान';

  @override
  String get postSuccessGoToDashboard => 'डॅशबोर्डवर जा';

  @override
  String get postSuccessPostAnother => 'आणखी एक ट्रक पोस्ट करा';

  @override
  String get myTrucksTitle => 'माझे ट्रक';

  @override
  String get myTrucksDeleteTitle => 'ट्रक हटवा';

  @override
  String myTrucksDeleteMessage(String vehicleNumber) {
    return '$vehicleNumber तुमच्या ट्रकमधून काढायचा? हे परत करता येणार नाही.';
  }

  @override
  String get myTrucksNoTrucks => 'अजून कोणताही ट्रक जोडलेला नाही';

  @override
  String get tripsTitle => 'माझ्या यात्रा';

  @override
  String get tripsNoTrips => 'अजून कोणतीही यात्रा पोस्ट केलेली नाही';

  @override
  String get tripsActiveLabel => 'सक्रिय यात्रा';

  @override
  String get tripsExpiredLabel => 'कालबाह्य';

  @override
  String get tripsEdit => 'संपादित करा';

  @override
  String get tripsReactivate => 'पुन्हा सक्रिय करा';

  @override
  String get tripsDeleteTitle => 'यात्रा हटवा';

  @override
  String get tripsDeleteMessage =>
      'ही यात्रा कायमची हटवायची? हे परत करता येणार नाही.';

  @override
  String tripsMoreDestinations(int count) {
    return '+$count अधिक';
  }

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get profileAccountSection => 'खाते';

  @override
  String get profileVerifiedDriver => '✓ सत्यापित चालक';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLogoutTitle => 'लॉगआउट';

  @override
  String get profileLogoutConfirm => 'तुम्हाला खरंच लॉगआउट करायचे आहे का?';

  @override
  String get profileKycLabel => 'KYC पडताळणी';

  @override
  String get profileKycVerified => '✓ पूर्ण';

  @override
  String get profileKycInReview => 'पुनरावलोकनात';

  @override
  String get profileKycRejected => 'नाकारले';

  @override
  String get profileKycPending => 'प्रलंबित';

  @override
  String get profileMyVehicles => 'माझी वाहने';

  @override
  String get profileTermsPrivacy => 'अटी व गोपनीयता';

  @override
  String get profileHelp => '24×7 चालक सहाय्य';

  @override
  String profileAccountStatusPrefix(String status) {
    return 'खाते $status';
  }

  @override
  String get profileAccountSuspended => 'निलंबित';

  @override
  String get profileAccountBlocked => 'अवरोधित';

  @override
  String get profileAccountInactive => 'निष्क्रिय';

  @override
  String get searchTitle => 'ट्रक शोधा';

  @override
  String get searchSubtitle => 'तुमच्या लोडसाठी योग्य ट्रक शोधा';

  @override
  String get searchOriginLabel => 'उगम स्थान';

  @override
  String get searchOriginHint => 'उगम स्थान निवडा';

  @override
  String get searchDestinationLabel => 'गंतव्यस्थान';

  @override
  String get searchDestinationHint => 'गंतव्यस्थान निवडा';

  @override
  String get searchTruckTypeLabel => 'ट्रकचा प्रकार';

  @override
  String get searchSelectTruckHint => 'ट्रक निवडा';

  @override
  String get searchCapacityLabel => 'क्षमता';

  @override
  String get searchSelectHint => 'निवडा';

  @override
  String get searchFindTrucksButton => 'ट्रक शोधा';

  @override
  String get resultsTitle => 'शोध निकाल';

  @override
  String get resultsSearching => 'शोधत आहे…';

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
  String get resultsYourResults => 'तुमचे शोध निकाल';

  @override
  String get resultsRunSearch => 'निकाल पाहण्यासाठी शोध घ्या';

  @override
  String get resultsNoneNearby => 'जवळपास कोणताही ट्रक सापडला नाही';

  @override
  String get resultsAnyOrigin => 'कोणतेही उगम स्थान';

  @override
  String get resultsAnyDestination => 'कोणतेही गंतव्यस्थान';

  @override
  String get resultsOriginLabel => 'उगम स्थान';

  @override
  String get resultsDestinationLabel => 'गंतव्यस्थान';

  @override
  String get resultsDateLabel => 'तारीख';

  @override
  String get resultsAny => 'कोणतेही';

  @override
  String get resultsCallDialerError => 'फोन डायलर उघडता आला नाही';

  @override
  String get resultsCallNow => 'आत्ता कॉल करा';

  @override
  String resultsPageOf(int page, int totalPages) {
    return 'पृष्ठ $page / $totalPages';
  }

  @override
  String resultsMutualCount(int count) {
    return '$count परस्पर';
  }

  @override
  String get navHome => 'मुख्यपृष्ठ';

  @override
  String get navSearch => 'शोधा';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count अधिक';
  }

  @override
  String capacityTon(int capacity) {
    return '$capacity टन';
  }
}
