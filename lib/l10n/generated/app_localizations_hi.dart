// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Bonut';

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
      'अपनी वर्तमान लोकेशन का पता लगाने के लिए सेटिंग्स से Bonut को लोकेशन एक्सेस की अनुमति दें।';

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
  String get truckTypePuller => 'पुलर';

  @override
  String get truckTypeWindbladeTrailer => 'विंडब्लेड ट्रेलर';

  @override
  String get truckTypePickupTruck => 'पिकअप ट्रक/टाटा ऐस';

  @override
  String get onboardingSkip => 'स्किप करें';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingTitle => 'लोड ~हर दिन~\nआपके पास आएंगे।';

  @override
  String get onboardingSubtitle =>
      'अपना ट्रक एक बार पोस्ट करें। वेरिफाइड ट्रांसपोर्टर आपको कॉल करेंगे। कोई बिचौलिया नहीं, कोई भागदौड़ नहीं।';

  @override
  String get onboardingPage2Title => 'अब कोई ट्रक ~खाली नहीं चलेगा~';

  @override
  String get onboardingPage2Subtitle =>
      'अपना ट्रक लिस्ट करें। लोड मालिक आपको ढूंढ लेंगे।';

  @override
  String get onboardingPage2Button => 'आगे बढ़ें';

  @override
  String get onboardingPage3Title => 'वेरिफाइड लोड\n~सीधा कनेक्शन~';

  @override
  String get onboardingPage3Subtitle => 'वास्तविक लोड आपकी हर ट्रिप के लिए';

  @override
  String get onboardingPage3Button => 'शुरू करें';

  @override
  String get onboardingChangeLanguage => 'भाषा बदलें';

  @override
  String get phoneEnterNumberHint => 'मोबाइल नंबर दर्ज करें';

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
  String get enterNameTitle => 'हम आपको क्या कहें?';

  @override
  String get enterNameSubtitle => 'जारी रखने के लिए अपना नाम दर्ज करें';

  @override
  String get enterNameHint => 'अपना नाम दर्ज करें';

  @override
  String get enterNameButton => 'जारी रखें';

  @override
  String get enterNameError =>
      'आपका नाम सहेजा नहीं जा सका। कृपया पुनः प्रयास करें।';

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
      'Bonut में इन-ऐप कॉलिंग नहीं है। कॉल पर टैप करने से\nआपका फोन डायलर खुलता है और इसे रिकॉर्ड के लिए दर्ज किया जाता है।';

  @override
  String get homeHello => 'नमस्ते';

  @override
  String get homeHeroTitle => 'ट्रक तैयार है? अब काम शुरू करें।';

  @override
  String get homeHeroSubtitle => 'वेरिफाइड लोड रिक्वेस्ट सीधे आपके मोबाइल पर।';

  @override
  String get homeHeroButton => 'ट्रक लिस्ट करें';

  @override
  String get homeCarousel2Title => 'आज का पहला लोड पकड़ें?';

  @override
  String get homeCarousel2Subtitle =>
      '100% वेरिफाइड लोड। कोई धोखाधड़ी नहीं, सिर्फ फायदा।';

  @override
  String get homeCarousel3Title => 'खाली ट्रक... सबसे महंगा होता है।';

  @override
  String get homeCarousel3Subtitle =>
      'आज ही लिस्ट करो, वेरिफाइड लोड तुरंत पाओ।';

  @override
  String get homeCarousel4Title => 'आपका ट्रक। आपकी मेहनत। पक्का फायदा।';

  @override
  String get homeCarousel4Subtitle => 'वेरिफाइड लोड। सही रेट। टाइम पर पेमेंट।';

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
  String get profileRecentPostsSearches => 'हाल की पोस्ट और खोजें';

  @override
  String get homeViewAll => 'सभी देखें';

  @override
  String get homeRecentPosts => 'हाल की पोस्ट';

  @override
  String get homeRecentSearch => 'हाल की सर्च';

  @override
  String get homeNoRecentPosts => 'कोई हाल की पोस्ट नहीं';

  @override
  String get homeNoRecentSearches => 'कोई हाल की खोज नहीं';

  @override
  String get homeTrendingReels => 'ट्रेंडिंग रोड रील्स';

  @override
  String get homeViewFeed => 'सभी देखें';

  @override
  String get homeNoReelsYet => 'अभी कोई रील नहीं';

  @override
  String get reelCreateSheetTitle => 'नई रील';

  @override
  String get reelCreateRecordOption => 'वीडियो रिकॉर्ड करें';

  @override
  String get reelCreateRecordOptionSubtitle => 'अपने कैमरे का उपयोग करें';

  @override
  String get reelCreateGalleryOption => 'गैलरी से चुनें';

  @override
  String get reelCreateGalleryOptionSubtitle => 'मौजूदा वीडियो चुनें';

  @override
  String get reelRecordCameraError => 'कैमरा एक्सेस नहीं हो पाया';

  @override
  String get reelRecordHint => 'रिकॉर्ड करने के लिए टैप करें';

  @override
  String get reelTrimTitle => 'अपनी रील ट्रिम करें';

  @override
  String reelTrimSelectedDuration(String seconds) {
    return '${seconds}s चुना गया';
  }

  @override
  String get reelTrimNext => 'अगला';

  @override
  String get reelDetailsTitle => 'रील विवरण';

  @override
  String get reelDetailsTitleLabel => 'टाइटल';

  @override
  String get reelDetailsTitleHint => 'अपनी रील को एक टाइटल दें';

  @override
  String get reelDetailsDescriptionLabel => 'विवरण (वैकल्पिक)';

  @override
  String get reelDetailsDescriptionHint => 'विवरण जोड़ें';

  @override
  String get reelDetailsTitleRequired => 'कृपया एक टाइटल दर्ज करें';

  @override
  String get reelPostButton => 'रील पोस्ट करें';

  @override
  String get reelUploadingTitle => 'आपकी रील अपलोड हो रही है…';

  @override
  String get reelUploadingSubtitle => 'कृपया ऐप बंद न करें';

  @override
  String get reelUploadSuccessTitle => 'रील अपलोड हो गई!';

  @override
  String get reelUploadSuccessSubtitle =>
      'आपकी रील प्रोसेस हो रही है और जल्द ही फ़ीड में दिखेगी।';

  @override
  String get reelBackToReels => 'रील्स पर वापस जाएं';

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
  String get kycCheckingAadhaar => 'जाँच की जा रही है...';

  @override
  String get kycAadhaarUnavailable => 'यह आधार इस्तेमाल नहीं किया जा सकता';

  @override
  String get kycAadhaarConflictSnackbar =>
      'यह आधार पहले से ही किसी दूसरे खाते से सत्यापित है।';

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
  String get profileVerifiedDriver => '✓ Verified';

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
  String get profileKycPending => 'पेंडिंग';

  @override
  String get profileKycPhotoPending => 'फ़ोटो लंबित';

  @override
  String get profileKycAlreadyVerified =>
      'आपका KYC पहले ही सत्यापित हो चुका है';

  @override
  String get profileMyVehicles => 'मेरे वाहन';

  @override
  String get profileTermsPrivacy => 'नियम और गोपनीयता';

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
  String get searchCapacityNotApplicable => 'लागू नहीं';

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
  String get resultsCallSheetTitle => 'आप किसे कॉल करना चाहेंगे?';

  @override
  String get resultsContactLabel => 'संपर्क';

  @override
  String get resultsPostedByLabel => 'पोस्टकर्ता';

  @override
  String get mutualContactsSheetTitle => 'कॉमन कॉन्टैक्ट';

  @override
  String get mutualContactsEmpty => 'कोई कॉमन कॉन्टैक्ट नहीं मिला';

  @override
  String get mutualContactsNumberUnavailable => 'नंबर उपलब्ध नहीं';

  @override
  String get contactsPermissionRationale =>
      'Bonut अन्य उपयोगकर्ताओं के साथ पारस्परिक संबंध दिखाने के लिए आपके संपर्कों का उपयोग करता है। आपके संपर्क कभी साझा नहीं किए जाते — केवल सुरक्षित एकतरफा हैश सिंक किए जाते हैं।';

  @override
  String get contactsPermissionDeniedMessage =>
      'Contacts की परमिशन बंद है। सेटिंग्स से ऑन करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'सर्च';

  @override
  String get navWallet => 'वॉलेट';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get navReels => 'रील्स';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count और';
  }

  @override
  String capacityTon(num capacity) {
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
  String get truckDetailsRequestOneToOne => '1:1 अनुरोध करें';

  @override
  String get truckDetailsCallDriver => 'बुक करने के लिए ड्राइवर को कॉल करें';

  @override
  String get truckDetailsRequestSoon => '1:1 अनुरोध जल्द आ रहे हैं';

  @override
  String get truckDetailsClose => 'बंद करें';

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

  @override
  String get walletTitle => 'वॉलेट';

  @override
  String get walletBalanceCardLabel => 'अब तक अर्जित कुल रिवॉर्ड';

  @override
  String walletPendingPayout(String amount) {
    return '$amount भुगतान लंबित';
  }

  @override
  String get walletFrozenMessage => 'वॉलेट फ़्रीज़ है — सहायता से संपर्क करें';

  @override
  String get walletRedeemButton => 'रिडीम करें';

  @override
  String get walletScratchCardsTab => 'स्क्रैच कार्ड';

  @override
  String get walletTransactionsTab => 'लेन-देन';

  @override
  String get walletNoTransactions => 'अभी तक कोई लेन-देन नहीं';

  @override
  String get walletTxnCredit => 'रिवॉर्ड जमा हुआ';

  @override
  String get walletTxnReserveRedeem => 'रिडीम अनुरोध किया गया';

  @override
  String get walletTxnConfirmPayout => 'भुगतान भेजा गया';

  @override
  String get walletTxnReleaseReserve => 'रिडीम अस्वीकृत — वापस जमा';

  @override
  String get walletRedeemSheetTitle => 'UPI पर रिडीम करें';

  @override
  String walletRedeemAvailableLabel(String amount) {
    return 'उपलब्ध: $amount';
  }

  @override
  String get walletUpiIdLabel => 'UPI आईडी';

  @override
  String get walletUpiIdHint => 'yourname@bank';

  @override
  String get walletUpiIdRequired => 'UPI आईडी दर्ज करें';

  @override
  String get walletUpiIdInvalid => 'मान्य UPI आईडी दर्ज करें, जैसे name@bank';

  @override
  String get walletConfirmRedeemButton => 'रिडीम की पुष्टि करें';

  @override
  String get walletRedeemSuccessMessage => 'रिडीम अनुरोध सबमिट किया गया';

  @override
  String get walletScratchCardsEmpty =>
      'अभी तक कोई स्क्रैच कार्ड नहीं — ट्रक पोस्ट करें और एक पाएं!';

  @override
  String get walletScratchCardScratchHint => 'स्क्रैच करें';

  @override
  String get walletScratchCardNoReward => 'कोई इनाम नहीं';

  @override
  String get walletScratchCardExpired => 'समाप्त';

  @override
  String get scratchCardRevealButton => 'दिखाएं';

  @override
  String get postScratchCardTitle => 'आपने एक स्क्रैच कार्ड जीता है!';

  @override
  String get postScratchCardSubtitle =>
      'अपना इनाम देखने के लिए कार्ड स्क्रैच करें';

  @override
  String get postScratchCardWonTitle => '🎉 आप जीत गए!';

  @override
  String get postScratchCardNoRewardTitle => 'अगली बार किस्मत आजमाएं!';

  @override
  String get postScratchCardNoRewardSubtitle =>
      'जीतने के और मौकों के लिए रोज़ पोस्ट करते रहें';

  @override
  String get postScratchCardContinueButton => 'जारी रखें';

  @override
  String get walletKycRequiredMessage =>
      'अपने वॉलेट और रिवॉर्ड तक पहुंचने के लिए कृपया अपना KYC पूरा करें';

  @override
  String get walletKycCompleteButton => 'KYC पूरा करें';

  @override
  String get wheelPickerDoneButton => 'पूर्ण';

  @override
  String get postLengthLabel => 'लंबाई';

  @override
  String get postHeightLabel => 'ऊंचाई';

  @override
  String get postSelectLengthHint => 'लंबाई चुनें';

  @override
  String get postSelectHeightHint => 'ऊंचाई चुनें';

  @override
  String feetValue(num value) {
    return '$value फ़ीट';
  }

  @override
  String get reelCommentsTitle => 'टिप्पणियां';

  @override
  String get reelCommentsEmpty => 'अभी कोई टिप्पणी नहीं। सबसे पहले आप लिखें!';

  @override
  String get reelCommentHint => 'टिप्पणी जोड़ें…';

  @override
  String get reelCommentPost => 'पोस्ट';

  @override
  String get reelCommentDelete => 'हटाएं';

  @override
  String get reelFollow => 'फ़ॉलो करें';

  @override
  String get reelFollowing => 'फ़ॉलो कर रहे हैं';

  @override
  String reelShareText(String title) {
    return '$title — यह रील Convoy पर देखें';
  }

  @override
  String get reelCategoryAll => 'सभी';

  @override
  String get reelDetailsCategoriesLabel => 'श्रेणियां';

  @override
  String get reelDetailsCategoriesHint => '1 से 5 चुनें';

  @override
  String get reelDetailsCategoriesRequired => 'कम से कम एक श्रेणी चुनें';

  @override
  String get reelDetailsHashtagsLabel => 'हैशटैग (वैकल्पिक)';

  @override
  String get reelDetailsHashtagsHint => '#trucklife #nightrun';

  @override
  String get reelDetailsHashtagsMax => 'आप अधिकतम 10 हैशटैग जोड़ सकते हैं';

  @override
  String get profileMyUploads => 'मेरे अपलोड';

  @override
  String get uploadsCreatorInsights => 'क्रिएटर इनसाइट्स';

  @override
  String get uploadsNewPost => 'नई पोस्ट';

  @override
  String get uploadsStatReels => 'रील्स';

  @override
  String get uploadsStatTotalViews => 'कुल व्यूज़';

  @override
  String get uploadsStatAppreciation => 'सराहना';

  @override
  String uploadsThisWeek(int count) {
    return 'इस सप्ताह +$count';
  }

  @override
  String uploadsAllReelsTab(int count) {
    return 'सभी रील्स ($count)';
  }

  @override
  String uploadsCategoryTab(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get uploadsEmpty => 'आपने अभी तक कोई रील अपलोड नहीं की है';

  @override
  String get uploadsRecordCta => 'रील रिकॉर्ड / अपलोड करें';

  @override
  String get uploadsMenuEdit => 'संपादित करें';

  @override
  String get uploadsMenuDelete => 'हटाएं';

  @override
  String get uploadsMenuComingSoon => 'जल्द आ रहा है';

  @override
  String get uploadsStatusProcessing => 'प्रोसेसिंग';

  @override
  String get uploadsStatusRejected => 'अस्वीकृत';

  @override
  String get uploadsStatusFailed => 'विफल';

  @override
  String get uploadsPostedToday => 'आज';

  @override
  String get uploadsPostedYesterday => 'कल';

  @override
  String uploadsPostedDaysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String uploadsPostedWeeksAgo(int weeks) {
    return '$weeks सप्ताह पहले';
  }

  @override
  String uploadsPostedMonthsAgo(int months) {
    return '$months माह पहले';
  }

  @override
  String get navHeatmap => 'हीटमैप';

  @override
  String get heatmapTitle => 'गतिविधि हीटमैप';

  @override
  String get heatmapTabTrucks => 'ट्रक';

  @override
  String get heatmapTabReels => 'रील्स';

  @override
  String get heatmapLoading => 'हीटमैप लोड हो रहा है…';

  @override
  String get heatmapErrorGeneric => 'हीटमैप लोड नहीं हो सका';

  @override
  String get heatmapEmptyTrucks => 'अभी दिखाने के लिए कोई लाइव ट्रक नहीं है';

  @override
  String get heatmapEmptyReels => 'अभी लोकेशन वाली कोई हालिया रील नहीं है';

  @override
  String get heatmapZoomOutHint => 'ज़्यादा गतिविधि देखने के लिए ज़ूम आउट करें';

  @override
  String get heatmapLegendLow => 'कम';

  @override
  String get heatmapLegendHigh => 'ज़्यादा';

  @override
  String get heatmapMyLocation => 'मेरी लोकेशन';

  @override
  String heatmapCellTrucks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस क्षेत्र में $count ट्रक',
      one: 'इस क्षेत्र में 1 ट्रक',
    );
    return '$_temp0';
  }

  @override
  String heatmapCellReels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस क्षेत्र में $count रील्स',
      one: 'इस क्षेत्र में 1 रील',
    );
    return '$_temp0';
  }

  @override
  String get heatmapNoTrucksInView => 'इस क्षेत्र में अभी कोई ट्रक नहीं है';

  @override
  String get heatmapPinsTruncated =>
      'केंद्र के सबसे पास के ट्रक दिखाए जा रहे हैं — और देखने के लिए ज़ूम इन करें';

  @override
  String get heatmapPinsModeHint => 'अलग-अलग ट्रक · जानकारी के लिए पिन दबाएं';

  @override
  String get heatmapPinLoading => 'ट्रक की जानकारी लोड हो रही है…';

  @override
  String get heatmapPinUnavailable => 'यह ट्रक पोस्ट अब उपलब्ध नहीं है';

  @override
  String get heatmapPinDetailError => 'ट्रक की जानकारी लोड नहीं हो सकी';

  @override
  String get reelsAreaThisArea => 'यह क्षेत्र';

  @override
  String get reelsAreaShowAll => 'सभी रील्स दिखाएं';

  @override
  String get reelsAreaEmpty => 'इस क्षेत्र में अभी कोई रील नहीं है';
}
