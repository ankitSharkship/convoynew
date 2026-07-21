// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Convoy';

  @override
  String get languageSelectTitle => 'भाषा चुनें';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get languageKannada => 'ಕನ್ನಡ';

  @override
  String get somethingWentWrong => 'कुछ गड़बड़ हो गई';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get ok => 'ठीक है';

  @override
  String get locationServiceDisabledTitle => 'लोकेशन बंद है';

  @override
  String get locationServiceDisabledMessage =>
      'अपनी वर्तमान लोकेशन का पता लगाने के लिए लोकेशन सेवाएं चालू करें।';

  @override
  String get locationEnableButton => 'लोकेशन चालू करें';

  @override
  String get locationPermissionDeniedTitle => 'लोकेशन अनुमति आवश्यक है';

  @override
  String get locationPermissionDeniedMessage =>
      'अपनी वर्तमान लोकेशन का पता लगाने के लिए सेटिंग्स से Convoy को लोकेशन एक्सेस की अनुमति दें।';

  @override
  String get locationOpenSettingsButton => 'सेटिंग्स खोलें';

  @override
  String get truckTypeOpenBody => 'खुली बॉडी';

  @override
  String get truckTypeClosedBody => 'बंद बॉडी';

  @override
  String get truckTypeTipper => 'टिपर';

  @override
  String get truckTypeSidewallTrailer => 'साइडवॉल ट्रेलर';

  @override
  String get truckTypeFlatBedTrailer => 'फ्लैट बेड ट्रेलर';

  @override
  String get truckTypeFlatBedTruck => 'फ्लैट बेड ट्रक';

  @override
  String get truckTypeLowBedTrailer => 'लो बेड ट्रेलर';

  @override
  String get truckTypeRefrigeratedTruck => 'रेफ्रिजरेटेड ट्रक';

  @override
  String get truckTypeBulker => 'बल्कर';

  @override
  String get truckTypeTanker => 'टैंकर';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingTitle => 'लोड हर दिन\nआपके पास आते हैं।';

  @override
  String get onboardingSubtitle =>
      'अपना ट्रक एक बार पोस्ट करें। सत्यापित ट्रांसपोर्टर आपको कॉल करेंगे। कोई बिचौलिया नहीं, कोई भागदौड़ नहीं।';

  @override
  String get onboardingChangeLanguage => 'भाषा बदलें';

  @override
  String get phoneEnterNumberHint => 'अपना नंबर दर्ज करें';

  @override
  String get phoneContinueButton => 'मोबाइल नंबर से जारी रखें';

  @override
  String get otpTitle => '4 अंकों का कोड दर्ज करें';

  @override
  String otpSentTo(String phone) {
    return '+91 $phone पर भेजा गया';
  }

  @override
  String get otpHelperText =>
      'कोड नहीं मिला? नंबर जांचें और फिर से भेजने की कोशिश करें।';

  @override
  String otpResendIn(String seconds) {
    return 'नहीं मिला? 0:$seconds में फिर से भेजें';
  }

  @override
  String get otpResendCode => 'कोड फिर से भेजें';

  @override
  String get callDialerHint => 'आपका फोन डायलर खोलता है';

  @override
  String get callCalling => 'कॉल हो रही है…';

  @override
  String callConnected(String duration) {
    return 'जुड़ गया · $duration';
  }

  @override
  String get callDisclaimer =>
      'Convoy में इन-ऐप कॉलिंग नहीं है। कॉल पर टैप करने से\nआपका फोन डायलर खुलता है और इसे रिकॉर्ड के लिए दर्ज किया जाता है।';

  @override
  String get homeHello => 'नमस्ते';

  @override
  String get homeHeroTitle => 'आपका ट्रक कमाई के लिए\nतैयार है 💰';

  @override
  String get homeHeroSubtitle =>
      'अभी पोस्ट करें और तुरंत सत्यापित लोड अनुरोध पाएं।';

  @override
  String get homeHeroButton => 'अभी ट्रक पोस्ट करें';

  @override
  String get homeQuickActions => 'त्वरित कार्य';

  @override
  String get homePostNewTruck => 'नया ट्रक पोस्ट करें';

  @override
  String get homePostNewTruckSubtitle => '30 सेकंड में तैयार';

  @override
  String get homeSearchTrucks => 'ट्रक खोजें';

  @override
  String get homeSearchTrucksSubtitle => 'उपलब्ध वाहन खोजें';

  @override
  String get homeManageSection => 'पोस्ट और खोज प्रबंधित करें';

  @override
  String get homeViewAll => 'सभी देखें';

  @override
  String get homeRecentPosts => 'हाल की पोस्ट';

  @override
  String get homeRecentSearch => 'हाल की खोज';

  @override
  String get homeNoRecentPosts => 'कोई हाल की पोस्ट नहीं';

  @override
  String get homeNoRecentSearches => 'कोई हाल की खोज नहीं';

  @override
  String get kycVerifyTitle => 'आधार कार्ड सत्यापित करें';

  @override
  String get kycAadhaarHint => 'XXXX XXXX XXXX';

  @override
  String get kycVerifyButton => 'आधार सत्यापित करें';

  @override
  String get kycOtpHelperText =>
      'OTP आपके आधार से जुड़े मोबाइल नंबर पर भेजा गया है। सत्यापित करने के लिए कृपया इसे दर्ज करें।';

  @override
  String get kycOtpVerifyButton => 'OTP सत्यापित करें';

  @override
  String get kycThankYou => 'आधार सत्यापित!';

  @override
  String get kycSuccessMessage =>
      'एक और कदम — सत्यापन पूरा करने के लिए अपनी फ़ोटो की पुष्टि करें।';

  @override
  String get faceReviewTitle => 'इस फ़ोटो का उपयोग करें?';

  @override
  String get faceReviewRetake => 'फिर से लें';

  @override
  String get faceReviewConfirm => 'इस फ़ोटो का उपयोग करें';

  @override
  String get faceReviewVerifyingTitle => 'सत्यापन हो रहा है';

  @override
  String get faceReviewVerifyingMessage =>
      'कृपया प्रतीक्षा करें, हम आपकी फ़ोटो सत्यापित कर रहे हैं';

  @override
  String get faceReviewVerificationFailed =>
      'हम आपके सत्यापन की पुष्टि नहीं कर सके। कृपया फिर से प्रयास करें।';

  @override
  String get postScreenTitle => 'अपना ट्रक पोस्ट करें';

  @override
  String get postRouteSectionLabel => 'मार्ग';

  @override
  String get postSelectTruckSectionLabel => 'ट्रक चुनें';

  @override
  String get postOriginLabel => 'से (वर्तमान स्थान)';

  @override
  String get postOriginHint => 'पता लगाने के लिए लोकेट बटन दबाएं';

  @override
  String get postGpsAutoDetected => 'GPS से पता लगाया गया';

  @override
  String postDestinationLabel(int number) {
    return 'गंतव्य $number';
  }

  @override
  String get postDestinationHint => 'गंतव्य दर्ज करें';

  @override
  String get postCouldNotLoadTrucks => 'आपके ट्रक लोड नहीं हो सके';

  @override
  String get postSelectTruckHint => 'एक ट्रक चुनें';

  @override
  String get postSearchTruckHint => 'ट्रक नंबर से खोजें';

  @override
  String get postAddNewTruck => 'नया ट्रक जोड़ें';

  @override
  String get postTruckSearchEmptyMessage =>
      'इस नंबर से कोई ट्रक उपलब्ध नहीं है। नंबर टाइप करें और इसे जोड़ने के लिए नीचे नया ट्रक जोड़ें पर टैप करें।';

  @override
  String get postSubmitButton => 'ट्रक पोस्ट करें';

  @override
  String get postAddTruckSheetTitle => 'ट्रक जोड़ें';

  @override
  String get postTruckNumberLabel => 'ट्रक नंबर';

  @override
  String get postTruckNumberHint => 'जैसे MH04AB1234';

  @override
  String get postTruckTypeLabel => 'ट्रक का प्रकार';

  @override
  String get postSelectTypeHint => 'प्रकार चुनें';

  @override
  String get postCapacityLabel => 'क्षमता';

  @override
  String get postSelectCapacityHint => 'क्षमता चुनें';

  @override
  String get postAddTruckButton => 'ट्रक जोड़ें';

  @override
  String get postVerifyButton => 'सत्यापित करें';

  @override
  String get postContactSectionTitle => 'किससे संपर्क करें?';

  @override
  String get postContactMe => 'मैं';

  @override
  String get postContactSomeoneElse => 'कोई और';

  @override
  String get postContactNameLabel => 'संपर्क का नाम';

  @override
  String get postContactNameHint => 'संपर्क का नाम दर्ज करें';

  @override
  String get postContactNumberLabel => 'संपर्क नंबर';

  @override
  String get postContactNumberHint => '10 अंकों का मोबाइल नंबर';

  @override
  String get postContactNumberError =>
      'एक मान्य 10 अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String get postEditTitle => 'ट्रक पोस्ट संपादित करें';

  @override
  String get postSaveChangesButton => 'बदलाव सहेजें';

  @override
  String get postSuccessTitle => 'आपका ट्रक पोस्ट हो गया!';

  @override
  String get postSuccessSubtitle =>
      'आपके आस-पास के लोड मालिक अब इसे देख सकते हैं और सीधे आपको कॉल कर सकते हैं।';

  @override
  String get postSuccessTruckTypeLabel => 'ट्रक का प्रकार';

  @override
  String get postSuccessPickupLabel => 'पिकअप स्थान';

  @override
  String get postSuccessGoToDashboard => 'डैशबोर्ड पर जाएं';

  @override
  String get postSuccessPostAnother => 'एक और ट्रक पोस्ट करें';

  @override
  String get myTrucksTitle => 'मेरे ट्रक';

  @override
  String get myTrucksDeleteTitle => 'ट्रक हटाएं';

  @override
  String myTrucksDeleteMessage(String vehicleNumber) {
    return '$vehicleNumber को अपने ट्रकों से हटाएं? यह वापस नहीं किया जा सकता।';
  }

  @override
  String get myTrucksNoTrucks => 'अभी तक कोई ट्रक नहीं जोड़ा गया';

  @override
  String get tripsTitle => 'मेरी यात्राएं';

  @override
  String get tripsNoTrips => 'अभी तक कोई यात्रा पोस्ट नहीं की गई';

  @override
  String get tripsActiveLabel => 'सक्रिय यात्रा';

  @override
  String get tripsExpiredLabel => 'समाप्त';

  @override
  String get tripsEdit => 'संपादित करें';

  @override
  String get tripsReactivate => 'पुनः सक्रिय करें';

  @override
  String get tripsDeleteTitle => 'यात्रा हटाएं';

  @override
  String get tripsDeleteMessage =>
      'इस यात्रा को स्थायी रूप से हटाएं? यह वापस नहीं किया जा सकता।';

  @override
  String tripsMoreDestinations(int count) {
    return '+$count और';
  }

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get profileAccountSection => 'खाता';

  @override
  String get profileVerifiedDriver => '✓ सत्यापित ड्राइवर';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLogoutTitle => 'लॉगआउट';

  @override
  String get profileLogoutConfirm => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get profileKycLabel => 'KYC सत्यापन';

  @override
  String get profileKycVerified => '✓ पूर्ण';

  @override
  String get profileKycInReview => 'समीक्षा में';

  @override
  String get profileKycRejected => 'अस्वीकृत';

  @override
  String get profileKycPending => 'लंबित';

  @override
  String get profileKycPhotoPending => 'फ़ोटो लंबित';

  @override
  String get profileKycAlreadyVerified =>
      'आपका KYC पहले ही सत्यापित हो चुका है';

  @override
  String get profileMyVehicles => 'मेरे वाहन';

  @override
  String get profileTermsPrivacy => 'नियम व गोपनीयता';

  @override
  String get profileHelp => '24×7 ड्राइवर सहायता';

  @override
  String profileAccountStatusPrefix(String status) {
    return 'खाता $status';
  }

  @override
  String get profileAccountSuspended => 'निलंबित';

  @override
  String get profileAccountBlocked => 'अवरुद्ध';

  @override
  String get profileAccountInactive => 'निष्क्रिय';

  @override
  String get searchTitle => 'ट्रक खोजें';

  @override
  String get searchSubtitle => 'अपने लोड के लिए सही ट्रक खोजें';

  @override
  String get searchOriginLabel => 'मूल स्थान';

  @override
  String get searchOriginHint => 'मूल स्थान चुनें';

  @override
  String get searchDestinationLabel => 'गंतव्य';

  @override
  String get searchDestinationHint => 'गंतव्य चुनें';

  @override
  String get searchTruckTypeLabel => 'ट्रक का प्रकार';

  @override
  String get searchSelectTruckHint => 'ट्रक चुनें';

  @override
  String get searchCapacityLabel => 'क्षमता';

  @override
  String get searchVehicleNumberLabel => 'वाहन नंबर';

  @override
  String get searchSelectHint => 'चुनें';

  @override
  String get searchFindTrucksButton => 'ट्रक खोजें';

  @override
  String get resultsTitle => 'खोज परिणाम';

  @override
  String get resultsSearching => 'खोज रहे हैं…';

  @override
  String resultsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रक मिले',
      one: '1 ट्रक मिला',
    );
    return '$_temp0';
  }

  @override
  String get resultsYourResults => 'आपके खोज परिणाम';

  @override
  String get resultsRunSearch => 'परिणाम देखने के लिए खोज चलाएं';

  @override
  String get resultsNoneNearby => 'आस-पास कोई ट्रक नहीं मिला';

  @override
  String get resultsAnyOrigin => 'कोई भी मूल स्थान';

  @override
  String get resultsAnyDestination => 'कोई भी गंतव्य';

  @override
  String get resultsOriginLabel => 'मूल स्थान';

  @override
  String get resultsDestinationLabel => 'गंतव्य';

  @override
  String get resultsDateLabel => 'तारीख';

  @override
  String get resultsAny => 'कोई भी';

  @override
  String get resultsSortByLabel => 'इसके अनुसार क्रमबद्ध करें:';

  @override
  String get resultsSortNearestOrigin => 'मूल स्थान के सबसे निकट';

  @override
  String get resultsSortNearestDestination => 'गंतव्य के सबसे निकट';

  @override
  String get resultsCallDialerError => 'फोन डायलर नहीं खुल सका';

  @override
  String get resultsCallNow => 'अभी कॉल करें';

  @override
  String resultsPageOf(int page, int totalPages) {
    return 'पृष्ठ $page / $totalPages';
  }

  @override
  String resultsMutualCount(int count) {
    return '$count पारस्परिक';
  }

  @override
  String get resultsViewAllMutuals => 'सभी देखें';

  @override
  String resultsPostedBy(String userName) {
    return 'पोस्टकर्ता: $userName';
  }

  @override
  String get mutualContactsSheetTitle => 'पारस्परिक संपर्क';

  @override
  String get mutualContactsEmpty => 'कोई पारस्परिक संपर्क नहीं मिला';

  @override
  String get mutualContactsNumberUnavailable => 'नंबर उपलब्ध नहीं';

  @override
  String get contactsPermissionRationale =>
      'Convoy अन्य उपयोगकर्ताओं के साथ पारस्परिक संबंध दिखाने के लिए आपके संपर्कों का उपयोग करता है। आपके संपर्क कभी साझा नहीं किए जाते — केवल सुरक्षित एकतरफा हैश सिंक किए जाते हैं।';

  @override
  String get contactsPermissionDeniedMessage =>
      'संपर्क अनुमति अस्वीकृत। पारस्परिक कनेक्शन देखने के लिए सेटिंग्स में इसे सक्षम करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'खोजें';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count और';
  }

  @override
  String capacityTon(int capacity) {
    return '$capacity टन';
  }

  @override
  String get networkOfflineBanner => 'इंटरनेट कनेक्शन नहीं है';
}
