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
  String get languageSelectTitle => 'भाषा सेलेक्ट करें';

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
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'डिलीट करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get locationServiceDisabledTitle => 'लोकेशन बंद है';

  @override
  String get locationServiceDisabledMessage =>
      'अपनी वर्तमान लोकेशन का पता लगाने के लिए लोकेशन ऑन करें।';

  @override
  String get locationEnableButton => 'लोकेशन चालू करें';

  @override
  String get locationPermissionDeniedTitle => 'लोकेशन की परमिशन चाहिए';

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
      'बस एक बार पोस्ट करें। Verified ट्रांसपोर्टर आपको सीधे कॉल करेंगे। कोई बिचौलिया नहीं।';

  @override
  String get onboardingChangeLanguage => 'भाषा बदलें';

  @override
  String get phoneEnterNumberHint => 'अपना नंबर दर्ज करें';

  @override
  String get phoneContinueButton => 'मोबाइल नंबर से आगे बढ़ें';

  @override
  String get otpTitle => '4 अंकों का OTP डालें';

  @override
  String otpSentTo(String phone) {
    return '+91 $phone पर भेजा गया';
  }

  @override
  String get otpHelperText => 'OTP नहीं मिला? नंबर चेक करें और दोबारा भेजें।';

  @override
  String otpResendIn(String seconds) {
    return 'नहीं मिला? 0:$seconds में फिर से भेजें';
  }

  @override
  String get otpResendCode => 'OTP दोबारा भेजें';

  @override
  String get callDialerHint => 'आपका फोन डायलर खोलता है';

  @override
  String get callCalling => 'कॉल लग रही है…';

  @override
  String callConnected(String duration) {
    return 'कॉल जुड़ गई · $duration';
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
  String get homeHeroButton => 'अभी पोस्ट करें';

  @override
  String get homeQuickActions => 'क्या करना है?';

  @override
  String get homePostNewTruck => 'नया पोस्ट करें';

  @override
  String get homePostNewTruckSubtitle => '30 सेकंड में हो जाएगा';

  @override
  String get homeSearchTrucks => 'ट्रक ढूंढें';

  @override
  String get homeSearchTrucksSubtitle => 'आस-पास के ट्रक देखें';

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
  String get kycVerifyTitle => 'आधार Verify करें';

  @override
  String get kycAadhaarHint => 'XXXX XXXX XXXX';

  @override
  String get kycVerifyButton => 'आधार Verify करें';

  @override
  String get kycOtpHelperText =>
      'OTP आपके आधार से जुड़े मोबाइल नंबर पर भेजा गया है। सत्यापित करने के लिए कृपया इसे दर्ज करें।';

  @override
  String get kycOtpVerifyButton => 'OTP सत्यापित करें';

  @override
  String get kycThankYou => 'आधार Verify हो गया!';

  @override
  String get kycSuccessMessage => 'एक और कदम — अब अपनी फोटो Confirm करें।';

  @override
  String get faceReviewTitle => 'यही फोटो इस्तेमाल करें?';

  @override
  String get faceReviewRetake => 'दोबारा लें';

  @override
  String get faceReviewConfirm => 'इस फ़ोटो का उपयोग करें';

  @override
  String get faceReviewVerifyingTitle => 'Verify हो रहा है';

  @override
  String get faceReviewVerifyingMessage =>
      'थोड़ा इंतज़ार करें, आपकी फोटो Verify हो रही है।';

  @override
  String get faceReviewVerificationFailed =>
      'हम आपके सत्यापन की पुष्टि नहीं कर सके। कृपया फिर से प्रयास करें।';

  @override
  String get postScreenTitle => 'पोस्ट करें';

  @override
  String get postRouteSectionLabel => 'रूट';

  @override
  String get postSelectTruckSectionLabel => 'ट्रक सेलेक्ट करें';

  @override
  String get postOriginLabel => 'कहाँ से (Current Location)';

  @override
  String get postOriginHint => 'लोकेशन लेने के लिए बटन दबाएँ';

  @override
  String get postGpsAutoDetected => 'GPS से पता लगाया गया';

  @override
  String postDestinationLabel(int number) {
    return 'कहाँ तक $number';
  }

  @override
  String get postDestinationHint => 'कहाँ तक दर्ज करें';

  @override
  String get postCouldNotLoadTrucks => 'आपके ट्रक लोड नहीं हो सके';

  @override
  String get postSelectTruckHint => 'एक ट्रक सेलेक्ट करें';

  @override
  String get postSearchTruckHint => 'ट्रक नंबर से ढूंढें';

  @override
  String get postAddNewTruck => 'नया ट्रक जोड़ें';

  @override
  String get postTruckSearchEmptyMessage =>
      'इस नंबर से कोई ट्रक उपलब्ध नहीं है। नंबर टाइप करें और इसे जोड़ने के लिए नीचे नया ट्रक जोड़ें पर टैप करें।';

  @override
  String get postSubmitButton => 'पोस्ट करें';

  @override
  String get postAddTruckSheetTitle => 'ट्रक जोड़ें';

  @override
  String get postTruckNumberLabel => 'ट्रक नंबर';

  @override
  String get postTruckNumberHint => 'जैसे MH04AB1234';

  @override
  String get postTruckTypeLabel => 'ट्रक का प्रकार';

  @override
  String get postSelectTypeHint => 'प्रकार सेलेक्ट करें';

  @override
  String get postCapacityLabel => 'क्षमता';

  @override
  String get postSelectCapacityHint => 'क्षमता सेलेक्ट करें';

  @override
  String get postAddTruckButton => 'ट्रक जोड़ें';

  @override
  String get postVerifyButton => 'सत्यापित करें';

  @override
  String get postContactSectionTitle => 'किसको कॉल आए?';

  @override
  String get postContactMe => 'मैं';

  @override
  String get postContactSomeoneElse => 'कोई दूसरा';

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
  String get postSaveChangesButton => 'सेव करें';

  @override
  String get postSuccessTitle => 'ट्रक सफलतापूर्वक पोस्ट हो गया!';

  @override
  String get postSuccessSubtitle =>
      'आपके आस-पास के लोड मालिक अब इसे देख सकते हैं और सीधे आपको कॉल कर सकते हैं।';

  @override
  String get postSuccessTruckTypeLabel => 'ट्रक का प्रकार';

  @override
  String get postSuccessPickupLabel => 'पिकअप स्थान';

  @override
  String get postSuccessGoToDashboard => 'होम पर जाएँ';

  @override
  String get postSuccessPostAnother => 'एक और पोस्ट करें';

  @override
  String get myTrucksTitle => 'मेरे ट्रक';

  @override
  String get myTrucksDeleteTitle => 'ट्रक डिलीट करें';

  @override
  String myTrucksDeleteMessage(String vehicleNumber) {
    return '$vehicleNumber को अपने ट्रकों से डिलीट करें? यह वापस नहीं किया जा सकता।';
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
  String get tripsDeleteTitle => 'यात्रा डिलीट करें';

  @override
  String get tripsDeleteMessage =>
      'इस यात्रा को स्थायी रूप से डिलीट करें? यह वापस नहीं किया जा सकता।';

  @override
  String tripsMoreDestinations(int count) {
    return '+$count और';
  }

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileAccountSection => 'खाता';

  @override
  String get profileVerifiedDriver => '✓ सत्यापित';

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
  String get profileTermsPrivacy => 'Terms & Privacy';

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
  String get searchTitle => 'ट्रक ढूंढें';

  @override
  String get searchSubtitle => 'अपने लोड के लिए सही ट्रक ढूंढें';

  @override
  String get searchOriginLabel => 'कहाँ से';

  @override
  String get searchOriginHint => 'कहाँ से सेलेक्ट करें';

  @override
  String get searchDestinationLabel => 'कहाँ तक';

  @override
  String get searchDestinationHint => 'कहाँ तक सेलेक्ट करें';

  @override
  String get searchTruckTypeLabel => 'ट्रक का प्रकार';

  @override
  String get searchSelectTruckHint => 'ट्रक सेलेक्ट करें';

  @override
  String get searchCapacityLabel => 'क्षमता';

  @override
  String get searchVehicleNumberLabel => 'वाहन नंबर';

  @override
  String get searchSelectHint => 'सेलेक्ट करें';

  @override
  String get searchFindTrucksButton => 'ट्रक ढूंढें';

  @override
  String get resultsTitle => 'रिजल्ट';

  @override
  String get resultsSearching => 'ढूंढ रहे हैं…';

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
  String get resultsYourResults => 'आपके रिजल्ट';

  @override
  String get resultsRunSearch => 'परिणाम देखने के लिए खोज चलाएं';

  @override
  String get resultsNoneNearby => 'आस-पास कोई ट्रक नहीं मिला';

  @override
  String get resultsAnyOrigin => 'कोई भी कहाँ से';

  @override
  String get resultsAnyDestination => 'कोई भी कहाँ तक';

  @override
  String get resultsOriginLabel => 'कहाँ से';

  @override
  String get resultsDestinationLabel => 'कहाँ तक';

  @override
  String get resultsDateLabel => 'तारीख';

  @override
  String get resultsAny => 'कोई भी';

  @override
  String get resultsSortByLabel => 'Sort करें:';

  @override
  String get resultsSortNearestOrigin => 'कहाँ से के सबसे निकट';

  @override
  String get resultsSortNearestDestination => 'कहाँ तक के सबसे निकट';

  @override
  String get resultsCallDialerError => 'फोन नहीं खुल पाया';

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
  String get mutualContactsSheetTitle => 'कॉमन कॉन्टैक्ट';

  @override
  String get mutualContactsEmpty => 'कोई कॉमन कॉन्टैक्ट नहीं मिला';

  @override
  String get mutualContactsNumberUnavailable => 'नंबर उपलब्ध नहीं';

  @override
  String get contactsPermissionRationale =>
      'Convoy अन्य उपयोगकर्ताओं के साथ पारस्परिक संबंध दिखाने के लिए आपके संपर्कों का उपयोग करता है। आपके संपर्क कभी साझा नहीं किए जाते — केवल सुरक्षित एकतरफा हैश सिंक किए जाते हैं।';

  @override
  String get contactsPermissionDeniedMessage =>
      'Contacts की परमिशन बंद है। सेटिंग्स से ऑन करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'ढूंढें';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count और';
  }

  @override
  String capacityTon(int capacity) {
    return '$capacity टन';
  }

  @override
  String get networkOfflineBanner => 'इंटरनेट नहीं है';

  @override
  String get truckMapPreviewTitle => 'लाइव ट्रक मैप';

  @override
  String get truckMapPreviewSubtitle =>
      'अपने पास के ट्रक देखने के लिए टैप करें';

  @override
  String get truckMapPreviewCta => 'लाइव मैप देखें';

  @override
  String get truckMapAppBarTitle => 'आपके आस-पास के ट्रक';

  @override
  String get truckMapLoading => 'आपके आस-पास के ट्रक खोजे जा रहे हैं…';

  @override
  String get truckMapNoTrucksNearby => '150 किमी के भीतर कोई ट्रक नहीं मिला';

  @override
  String get truckMapErrorGeneric => 'ट्रक लोड नहीं हो सके';

  @override
  String get truckMapRetry => 'फिर से कोशिश करें';

  @override
  String truckMapCountFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रक पास में',
      one: '1 ट्रक पास में',
    );
    return '$_temp0';
  }

  @override
  String get truckMapDetailsTitle => 'ट्रक विवरण';

  @override
  String truckMapViewList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सूची देखें ($count)',
      one: 'सूची देखें (1)',
    );
    return '$_temp0';
  }
}
