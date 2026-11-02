import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Bonut'**
  String get appName;

  /// No description provided for @languageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelectTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get languageHindi;

  /// No description provided for @languageMarathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get languageMarathi;

  /// No description provided for @languageKannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get languageKannada;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @locationServiceDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get locationServiceDisabledTitle;

  /// No description provided for @locationServiceDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to auto-detect your current location.'**
  String get locationServiceDisabledMessage;

  /// No description provided for @locationEnableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get locationEnableButton;

  /// No description provided for @locationPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission needed'**
  String get locationPermissionDeniedTitle;

  /// No description provided for @locationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow Bonut to access your location from Settings to auto-detect your current location.'**
  String get locationPermissionDeniedMessage;

  /// No description provided for @locationOpenSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get locationOpenSettingsButton;

  /// No description provided for @truckTypeOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Open Body'**
  String get truckTypeOpenBody;

  /// No description provided for @truckTypeClosedBody.
  ///
  /// In en, this message translates to:
  /// **'Closed Body'**
  String get truckTypeClosedBody;

  /// No description provided for @truckTypeTipper.
  ///
  /// In en, this message translates to:
  /// **'Tipper'**
  String get truckTypeTipper;

  /// No description provided for @truckTypeSidewallTrailer.
  ///
  /// In en, this message translates to:
  /// **'Sidewall Trailer'**
  String get truckTypeSidewallTrailer;

  /// No description provided for @truckTypeFlatBedTrailer.
  ///
  /// In en, this message translates to:
  /// **'Flat Bed Trailer'**
  String get truckTypeFlatBedTrailer;

  /// No description provided for @truckTypeFlatBedTruck.
  ///
  /// In en, this message translates to:
  /// **'Flat Bed Truck'**
  String get truckTypeFlatBedTruck;

  /// No description provided for @truckTypeLowBedTrailer.
  ///
  /// In en, this message translates to:
  /// **'Low Bed Trailer'**
  String get truckTypeLowBedTrailer;

  /// No description provided for @truckTypeRefrigeratedTruck.
  ///
  /// In en, this message translates to:
  /// **'Refrigerated Truck'**
  String get truckTypeRefrigeratedTruck;

  /// No description provided for @truckTypeBulker.
  ///
  /// In en, this message translates to:
  /// **'Bulker'**
  String get truckTypeBulker;

  /// No description provided for @truckTypeTanker.
  ///
  /// In en, this message translates to:
  /// **'Tanker'**
  String get truckTypeTanker;

  /// No description provided for @truckTypePuller.
  ///
  /// In en, this message translates to:
  /// **'Puller'**
  String get truckTypePuller;

  /// No description provided for @truckTypeWindbladeTrailer.
  ///
  /// In en, this message translates to:
  /// **'Windblade Trailer'**
  String get truckTypeWindbladeTrailer;

  /// No description provided for @truckTypePickupTruck.
  ///
  /// In en, this message translates to:
  /// **'Pickup Truck/Tata Ace'**
  String get truckTypePickupTruck;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loads come\nto you, ~every day.~'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post your truck once. Verified transporters call you. No middlemen, no running around.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Ab koi truck ~Khaali nahi chalega~'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Apna truck list kijiye. Load owners aapko dhoondh lenge.'**
  String get onboardingPage2Subtitle;

  /// No description provided for @onboardingPage2Button.
  ///
  /// In en, this message translates to:
  /// **'Aage Badhein'**
  String get onboardingPage2Button;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Verified Loads.\n~Seedha Connection.~'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Genuine Loads aapke har trip ke liye.'**
  String get onboardingPage3Subtitle;

  /// No description provided for @onboardingPage3Button.
  ///
  /// In en, this message translates to:
  /// **'Shuru Karein'**
  String get onboardingPage3Button;

  /// No description provided for @onboardingChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get onboardingChangeLanguage;

  /// No description provided for @phoneEnterNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get phoneEnterNumberHint;

  /// No description provided for @phoneContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Mobile Number'**
  String get phoneContinueButton;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to +91 {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpHelperText.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it? Check the number and try resending.'**
  String get otpHelperText;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Resend in 0:{seconds}'**
  String otpResendIn(String seconds);

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendCode;

  /// No description provided for @enterNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get enterNameTitle;

  /// No description provided for @enterNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your name to continue'**
  String get enterNameSubtitle;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterNameHint;

  /// No description provided for @enterNameButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get enterNameButton;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your name. Please try again.'**
  String get enterNameError;

  /// No description provided for @callDialerHint.
  ///
  /// In en, this message translates to:
  /// **'Opens your phone dialer'**
  String get callDialerHint;

  /// No description provided for @callCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling…'**
  String get callCalling;

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected · {duration}'**
  String callConnected(String duration);

  /// No description provided for @callDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Bounut has no in-app calling. Tapping Call\nopens your phone dialer and logs it for your records.'**
  String get callDisclaimer;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeHello;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Truck Ready Hai? Ab Kaam Shuru Karein.'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified load requests seedha aapke mobile par.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeHeroButton.
  ///
  /// In en, this message translates to:
  /// **'Truck List Karein'**
  String get homeHeroButton;

  /// No description provided for @homeCarousel2Title.
  ///
  /// In en, this message translates to:
  /// **'Aaj Ka Pehla Load Pakde?'**
  String get homeCarousel2Title;

  /// No description provided for @homeCarousel2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'100% verified loads. No fraud, only fayda.'**
  String get homeCarousel2Subtitle;

  /// No description provided for @homeCarousel3Title.
  ///
  /// In en, this message translates to:
  /// **'Khali Truck... Sabse Mehenga Hota Hai.'**
  String get homeCarousel3Title;

  /// No description provided for @homeCarousel3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Aaj hi list karo, verified loads pao turant.'**
  String get homeCarousel3Subtitle;

  /// No description provided for @homeCarousel4Title.
  ///
  /// In en, this message translates to:
  /// **'Aapka Truck. Aapki Mehnat. Pakka Fayda.'**
  String get homeCarousel4Title;

  /// No description provided for @homeCarousel4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified loads. Sahi rate. Time pe payment.'**
  String get homeCarousel4Subtitle;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homePostNewTruck.
  ///
  /// In en, this message translates to:
  /// **'Post New Truck'**
  String get homePostNewTruck;

  /// No description provided for @homePostNewTruckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready in 30 seconds'**
  String get homePostNewTruckSubtitle;

  /// No description provided for @homeSearchTrucks.
  ///
  /// In en, this message translates to:
  /// **'Search Trucks'**
  String get homeSearchTrucks;

  /// No description provided for @homeSearchTrucksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find available vehicles'**
  String get homeSearchTrucksSubtitle;

  /// No description provided for @profileRecentPostsSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Post & Searches'**
  String get profileRecentPostsSearches;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeRecentPosts.
  ///
  /// In en, this message translates to:
  /// **'Recent Posts'**
  String get homeRecentPosts;

  /// No description provided for @homeRecentSearch.
  ///
  /// In en, this message translates to:
  /// **'Recent Search'**
  String get homeRecentSearch;

  /// No description provided for @homeNoRecentPosts.
  ///
  /// In en, this message translates to:
  /// **'No recent posts'**
  String get homeNoRecentPosts;

  /// No description provided for @homeNoRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get homeNoRecentSearches;

  /// No description provided for @homeTrendingReels.
  ///
  /// In en, this message translates to:
  /// **'Trending Road Reels'**
  String get homeTrendingReels;

  /// No description provided for @homeViewFeed.
  ///
  /// In en, this message translates to:
  /// **'View Feed'**
  String get homeViewFeed;

  /// No description provided for @homeNoReelsYet.
  ///
  /// In en, this message translates to:
  /// **'No reels yet'**
  String get homeNoReelsYet;

  /// No description provided for @reelRecordCameraError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t access the camera'**
  String get reelRecordCameraError;

  /// No description provided for @reelRecordHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get reelRecordHint;

  /// No description provided for @reelTrimTitle.
  ///
  /// In en, this message translates to:
  /// **'Trim Your Reel'**
  String get reelTrimTitle;

  /// No description provided for @reelTrimSelectedDuration.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s selected'**
  String reelTrimSelectedDuration(String seconds);

  /// No description provided for @reelTrimNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get reelTrimNext;

  /// No description provided for @reelDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reel Details'**
  String get reelDetailsTitle;

  /// No description provided for @reelDetailsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reelDetailsTitleLabel;

  /// No description provided for @reelDetailsTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Give your reel a title'**
  String get reelDetailsTitleHint;

  /// No description provided for @reelDetailsDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get reelDetailsDescriptionLabel;

  /// No description provided for @reelDetailsDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description'**
  String get reelDetailsDescriptionHint;

  /// No description provided for @reelDetailsTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get reelDetailsTitleRequired;

  /// No description provided for @reelPostButton.
  ///
  /// In en, this message translates to:
  /// **'Post Reel'**
  String get reelPostButton;

  /// No description provided for @reelUploadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploading your reel…'**
  String get reelUploadingTitle;

  /// No description provided for @reelUploadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t close the app'**
  String get reelUploadingSubtitle;

  /// No description provided for @reelUploadSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Reel Uploaded!'**
  String get reelUploadSuccessTitle;

  /// No description provided for @reelUploadSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your reel is being processed and will appear in the feed shortly.'**
  String get reelUploadSuccessSubtitle;

  /// No description provided for @reelBackToReels.
  ///
  /// In en, this message translates to:
  /// **'Back to Reels'**
  String get reelBackToReels;

  /// No description provided for @kycVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Aadhar Card'**
  String get kycVerifyTitle;

  /// No description provided for @kycAadhaarHint.
  ///
  /// In en, this message translates to:
  /// **'XXXX XXXX XXXX'**
  String get kycAadhaarHint;

  /// No description provided for @kycVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Aadhar'**
  String get kycVerifyButton;

  /// No description provided for @kycOtpHelperText.
  ///
  /// In en, this message translates to:
  /// **'OTP has been sent to your Aadhaar-linked mobile number. Please enter it to verify.'**
  String get kycOtpHelperText;

  /// No description provided for @kycOtpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get kycOtpVerifyButton;

  /// No description provided for @kycCheckingAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get kycCheckingAadhaar;

  /// No description provided for @kycAadhaarUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This Aadhaar can\'t be used'**
  String get kycAadhaarUnavailable;

  /// No description provided for @kycAadhaarConflictSnackbar.
  ///
  /// In en, this message translates to:
  /// **'This Aadhaar has already been verified with another account.'**
  String get kycAadhaarConflictSnackbar;

  /// No description provided for @kycThankYou.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Verified!'**
  String get kycThankYou;

  /// No description provided for @kycSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'One more step — let\'s confirm your photo to complete verification.'**
  String get kycSuccessMessage;

  /// No description provided for @faceReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Use this photo?'**
  String get faceReviewTitle;

  /// No description provided for @faceReviewRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get faceReviewRetake;

  /// No description provided for @faceReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get faceReviewConfirm;

  /// No description provided for @faceReviewVerifyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get faceReviewVerifyingTitle;

  /// No description provided for @faceReviewVerifyingMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait, we\'re verifying your photo'**
  String get faceReviewVerifyingMessage;

  /// No description provided for @faceReviewVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your verification. Please try again.'**
  String get faceReviewVerificationFailed;

  /// No description provided for @postScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Post your truck'**
  String get postScreenTitle;

  /// No description provided for @postRouteSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'ROUTE'**
  String get postRouteSectionLabel;

  /// No description provided for @postSelectTruckSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SELECT TRUCK'**
  String get postSelectTruckSectionLabel;

  /// No description provided for @postOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'From (current location)'**
  String get postOriginLabel;

  /// No description provided for @postOriginHint.
  ///
  /// In en, this message translates to:
  /// **'Locate Your Position'**
  String get postOriginHint;

  /// No description provided for @postGpsAutoDetected.
  ///
  /// In en, this message translates to:
  /// **'GPS Auto-detected'**
  String get postGpsAutoDetected;

  /// No description provided for @postDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination {number}'**
  String postDestinationLabel(int number);

  /// No description provided for @postDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get postDestinationHint;

  /// No description provided for @postCouldNotLoadTrucks.
  ///
  /// In en, this message translates to:
  /// **'Could not load your trucks'**
  String get postCouldNotLoadTrucks;

  /// No description provided for @postSelectTruckHint.
  ///
  /// In en, this message translates to:
  /// **'Select a truck'**
  String get postSelectTruckHint;

  /// No description provided for @postSearchTruckHint.
  ///
  /// In en, this message translates to:
  /// **'Search by truck number'**
  String get postSearchTruckHint;

  /// No description provided for @postAddNewTruck.
  ///
  /// In en, this message translates to:
  /// **'Add New Truck'**
  String get postAddNewTruck;

  /// No description provided for @postTruckSearchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No truck with this number available. Type the number and tap Add New Truck below to add it.'**
  String get postTruckSearchEmptyMessage;

  /// No description provided for @postSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Post a Truck'**
  String get postSubmitButton;

  /// No description provided for @postAddTruckSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a Truck'**
  String get postAddTruckSheetTitle;

  /// No description provided for @postTruckNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Truck Number'**
  String get postTruckNumberLabel;

  /// No description provided for @postTruckNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MH04AB1234'**
  String get postTruckNumberHint;

  /// No description provided for @postTruckTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Truck Type'**
  String get postTruckTypeLabel;

  /// No description provided for @postSelectTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get postSelectTypeHint;

  /// No description provided for @postCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get postCapacityLabel;

  /// No description provided for @postSelectCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'Select capacity'**
  String get postSelectCapacityHint;

  /// No description provided for @postAddTruckButton.
  ///
  /// In en, this message translates to:
  /// **'Add Truck'**
  String get postAddTruckButton;

  /// No description provided for @postVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get postVerifyButton;

  /// No description provided for @postContactSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Who should we contact?'**
  String get postContactSectionTitle;

  /// No description provided for @postContactMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get postContactMe;

  /// No description provided for @postContactSomeoneElse.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get postContactSomeoneElse;

  /// No description provided for @postContactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get postContactNameLabel;

  /// No description provided for @postContactNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter contact name'**
  String get postContactNameHint;

  /// No description provided for @postContactNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact number'**
  String get postContactNumberLabel;

  /// No description provided for @postContactNumberHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get postContactNumberHint;

  /// No description provided for @postContactNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get postContactNumberError;

  /// No description provided for @postEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit truck post'**
  String get postEditTitle;

  /// No description provided for @postSaveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get postSaveChangesButton;

  /// No description provided for @postSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your truck is posted!'**
  String get postSuccessTitle;

  /// No description provided for @postSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load owners near you can now see it and call you directly.'**
  String get postSuccessSubtitle;

  /// No description provided for @postSuccessTruckTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Truck type'**
  String get postSuccessTruckTypeLabel;

  /// No description provided for @postSuccessPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get postSuccessPickupLabel;

  /// No description provided for @postSuccessGoToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get postSuccessGoToDashboard;

  /// No description provided for @postSuccessPostAnother.
  ///
  /// In en, this message translates to:
  /// **'Post another truck'**
  String get postSuccessPostAnother;

  /// No description provided for @myTrucksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trucks'**
  String get myTrucksTitle;

  /// No description provided for @myTrucksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete truck'**
  String get myTrucksDeleteTitle;

  /// No description provided for @myTrucksDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {vehicleNumber} from your trucks? This cannot be undone.'**
  String myTrucksDeleteMessage(String vehicleNumber);

  /// No description provided for @myTrucksNoTrucks.
  ///
  /// In en, this message translates to:
  /// **'No trucks added yet'**
  String get myTrucksNoTrucks;

  /// No description provided for @tripsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get tripsTitle;

  /// No description provided for @tripsNoTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips posted yet'**
  String get tripsNoTrips;

  /// No description provided for @tripsActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Trip'**
  String get tripsActiveLabel;

  /// No description provided for @tripsExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get tripsExpiredLabel;

  /// No description provided for @tripsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tripsEdit;

  /// No description provided for @tripsReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get tripsReactivate;

  /// No description provided for @tripsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get tripsDeleteTitle;

  /// No description provided for @tripsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this trip permanently? This cannot be undone.'**
  String get tripsDeleteMessage;

  /// No description provided for @tripsMoreDestinations.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String tripsMoreDestinations(int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileAccountSection;

  /// No description provided for @profileVerifiedDriver.
  ///
  /// In en, this message translates to:
  /// **'✓ Verified'**
  String get profileVerifiedDriver;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileKycLabel.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get profileKycLabel;

  /// No description provided for @profileKycVerified.
  ///
  /// In en, this message translates to:
  /// **'✓ Done'**
  String get profileKycVerified;

  /// No description provided for @profileKycInReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get profileKycInReview;

  /// No description provided for @profileKycRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get profileKycRejected;

  /// No description provided for @profileKycPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get profileKycPending;

  /// No description provided for @profileKycPhotoPending.
  ///
  /// In en, this message translates to:
  /// **'Photo Pending'**
  String get profileKycPhotoPending;

  /// No description provided for @profileKycAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Your KYC is already verified'**
  String get profileKycAlreadyVerified;

  /// No description provided for @profileMyVehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get profileMyVehicles;

  /// No description provided for @profileTermsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get profileTermsPrivacy;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'24×7 Driver Support'**
  String get profileHelp;

  /// No description provided for @profileAccountStatusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Account {status}'**
  String profileAccountStatusPrefix(String status);

  /// No description provided for @profileAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'suspended'**
  String get profileAccountSuspended;

  /// No description provided for @profileAccountBlocked.
  ///
  /// In en, this message translates to:
  /// **'blocked'**
  String get profileAccountBlocked;

  /// No description provided for @profileAccountInactive.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get profileAccountInactive;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Trucks'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the right truck for your load'**
  String get searchSubtitle;

  /// No description provided for @searchOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get searchOriginLabel;

  /// No description provided for @searchOriginHint.
  ///
  /// In en, this message translates to:
  /// **'Select Origin'**
  String get searchOriginHint;

  /// No description provided for @searchDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get searchDestinationLabel;

  /// No description provided for @searchDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get searchDestinationHint;

  /// No description provided for @searchTruckTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Truck Type'**
  String get searchTruckTypeLabel;

  /// No description provided for @searchSelectTruckHint.
  ///
  /// In en, this message translates to:
  /// **'Select Truck'**
  String get searchSelectTruckHint;

  /// No description provided for @searchCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get searchCapacityLabel;

  /// No description provided for @searchVehicleNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle No.'**
  String get searchVehicleNumberLabel;

  /// No description provided for @searchSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get searchSelectHint;

  /// No description provided for @searchCapacityNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get searchCapacityNotApplicable;

  /// No description provided for @searchFindTrucksButton.
  ///
  /// In en, this message translates to:
  /// **'Find Trucks'**
  String get searchFindTrucksButton;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get resultsTitle;

  /// No description provided for @resultsSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get resultsSearching;

  /// No description provided for @resultsFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 truck found} other{{count} trucks found}}'**
  String resultsFoundCount(int count);

  /// No description provided for @resultsYourResults.
  ///
  /// In en, this message translates to:
  /// **'Your search results'**
  String get resultsYourResults;

  /// No description provided for @resultsRunSearch.
  ///
  /// In en, this message translates to:
  /// **'Run a search to see results'**
  String get resultsRunSearch;

  /// No description provided for @resultsNoneNearby.
  ///
  /// In en, this message translates to:
  /// **'No trucks found nearby'**
  String get resultsNoneNearby;

  /// No description provided for @resultsAnyOrigin.
  ///
  /// In en, this message translates to:
  /// **'Any origin'**
  String get resultsAnyOrigin;

  /// No description provided for @resultsAnyDestination.
  ///
  /// In en, this message translates to:
  /// **'Any destination'**
  String get resultsAnyDestination;

  /// No description provided for @resultsOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'ORIGIN'**
  String get resultsOriginLabel;

  /// No description provided for @resultsDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'DESTINATION'**
  String get resultsDestinationLabel;

  /// No description provided for @resultsDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get resultsDateLabel;

  /// No description provided for @resultsAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get resultsAny;

  /// No description provided for @resultsSortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort By:'**
  String get resultsSortByLabel;

  /// No description provided for @resultsSortNearestOrigin.
  ///
  /// In en, this message translates to:
  /// **'Nearest to Origin'**
  String get resultsSortNearestOrigin;

  /// No description provided for @resultsSortNearestDestination.
  ///
  /// In en, this message translates to:
  /// **'Nearest to Destination'**
  String get resultsSortNearestDestination;

  /// No description provided for @resultsCallDialerError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone dialer'**
  String get resultsCallDialerError;

  /// No description provided for @resultsCallNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get resultsCallNow;

  /// No description provided for @resultsPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {totalPages}'**
  String resultsPageOf(int page, int totalPages);

  /// No description provided for @resultsMutualCount.
  ///
  /// In en, this message translates to:
  /// **'{count} mutual'**
  String resultsMutualCount(int count);

  /// No description provided for @resultsViewAllMutuals.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get resultsViewAllMutuals;

  /// No description provided for @resultsPostedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted By: {userName}'**
  String resultsPostedBy(String userName);

  /// No description provided for @resultsCallSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Who would you like to call?'**
  String get resultsCallSheetTitle;

  /// No description provided for @resultsContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get resultsContactLabel;

  /// No description provided for @resultsPostedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Posted By'**
  String get resultsPostedByLabel;

  /// No description provided for @mutualContactsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Mutual Contacts'**
  String get mutualContactsSheetTitle;

  /// No description provided for @mutualContactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No mutual contacts found'**
  String get mutualContactsEmpty;

  /// No description provided for @mutualContactsNumberUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Number unavailable'**
  String get mutualContactsNumberUnavailable;

  /// No description provided for @contactsPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'Bonut uses your contacts to show mutual connections with other users. Your contacts are never shared — only secure one-way hashes are synced.'**
  String get contactsPermissionRationale;

  /// No description provided for @contactsPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission denied. Enable it in Settings to see mutual connections.'**
  String get contactsPermissionDeniedMessage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navReels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get navReels;

  /// No description provided for @truckCardMoreDestinations.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String truckCardMoreDestinations(int count);

  /// No description provided for @capacityTon.
  ///
  /// In en, this message translates to:
  /// **'{capacity} Ton'**
  String capacityTon(num capacity);

  /// No description provided for @networkOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkOfflineBanner;

  /// No description provided for @truckMapPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Truck Map'**
  String get truckMapPreviewTitle;

  /// No description provided for @truckMapPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to view trucks near you'**
  String get truckMapPreviewSubtitle;

  /// No description provided for @truckMapPreviewCta.
  ///
  /// In en, this message translates to:
  /// **'View Live Map'**
  String get truckMapPreviewCta;

  /// No description provided for @truckMapAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Trucks Near You'**
  String get truckMapAppBarTitle;

  /// No description provided for @truckMapLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding trucks near you…'**
  String get truckMapLoading;

  /// No description provided for @truckMapNoTrucksNearby.
  ///
  /// In en, this message translates to:
  /// **'No trucks found within 150 km'**
  String get truckMapNoTrucksNearby;

  /// No description provided for @truckMapErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load trucks'**
  String get truckMapErrorGeneric;

  /// No description provided for @truckMapRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get truckMapRetry;

  /// No description provided for @truckMapCountFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 truck nearby} other{{count} trucks nearby}}'**
  String truckMapCountFound(int count);

  /// No description provided for @truckMapDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Truck Details'**
  String get truckMapDetailsTitle;

  /// No description provided for @truckDetailsRequestOneToOne.
  ///
  /// In en, this message translates to:
  /// **'Request 1:1'**
  String get truckDetailsRequestOneToOne;

  /// No description provided for @truckDetailsCallDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver to Book'**
  String get truckDetailsCallDriver;

  /// No description provided for @truckDetailsRequestSoon.
  ///
  /// In en, this message translates to:
  /// **'1:1 requests are coming soon'**
  String get truckDetailsRequestSoon;

  /// No description provided for @truckDetailsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get truckDetailsClose;

  /// No description provided for @truckMapViewList.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{View List (1)} other{View List ({count})}}'**
  String truckMapViewList(int count);

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletBalanceCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Rewards Earned'**
  String get walletBalanceCardLabel;

  /// No description provided for @walletPendingPayout.
  ///
  /// In en, this message translates to:
  /// **'{amount} pending payout'**
  String walletPendingPayout(String amount);

  /// No description provided for @walletFrozenMessage.
  ///
  /// In en, this message translates to:
  /// **'Wallet frozen — contact support'**
  String get walletFrozenMessage;

  /// No description provided for @walletRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get walletRedeemButton;

  /// No description provided for @walletScratchCardsTab.
  ///
  /// In en, this message translates to:
  /// **'Scratch Cards'**
  String get walletScratchCardsTab;

  /// No description provided for @walletTransactionsTab.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get walletTransactionsTab;

  /// No description provided for @walletNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get walletNoTransactions;

  /// No description provided for @walletTxnCredit.
  ///
  /// In en, this message translates to:
  /// **'Reward credited'**
  String get walletTxnCredit;

  /// No description provided for @walletTxnReserveRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem requested'**
  String get walletTxnReserveRedeem;

  /// No description provided for @walletTxnConfirmPayout.
  ///
  /// In en, this message translates to:
  /// **'Payout sent'**
  String get walletTxnConfirmPayout;

  /// No description provided for @walletTxnReleaseReserve.
  ///
  /// In en, this message translates to:
  /// **'Redeem rejected — refunded'**
  String get walletTxnReleaseReserve;

  /// No description provided for @walletRedeemSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem to UPI'**
  String get walletRedeemSheetTitle;

  /// No description provided for @walletRedeemAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount}'**
  String walletRedeemAvailableLabel(String amount);

  /// No description provided for @walletUpiIdLabel.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get walletUpiIdLabel;

  /// No description provided for @walletUpiIdHint.
  ///
  /// In en, this message translates to:
  /// **'yourname@bank'**
  String get walletUpiIdHint;

  /// No description provided for @walletUpiIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a UPI ID'**
  String get walletUpiIdRequired;

  /// No description provided for @walletUpiIdInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid UPI ID, e.g. name@bank'**
  String get walletUpiIdInvalid;

  /// No description provided for @walletConfirmRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Redeem'**
  String get walletConfirmRedeemButton;

  /// No description provided for @walletRedeemSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Redeem request submitted'**
  String get walletRedeemSuccessMessage;

  /// No description provided for @walletScratchCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scratch cards yet — post a truck to earn one!'**
  String get walletScratchCardsEmpty;

  /// No description provided for @walletScratchCardScratchHint.
  ///
  /// In en, this message translates to:
  /// **'Scratch Here'**
  String get walletScratchCardScratchHint;

  /// No description provided for @walletScratchCardNoReward.
  ///
  /// In en, this message translates to:
  /// **'No reward'**
  String get walletScratchCardNoReward;

  /// No description provided for @walletScratchCardExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get walletScratchCardExpired;

  /// No description provided for @scratchCardRevealButton.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get scratchCardRevealButton;

  /// No description provided for @postScratchCardTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve Earned a Scratch Card!'**
  String get postScratchCardTitle;

  /// No description provided for @postScratchCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scratch the card to reveal your reward'**
  String get postScratchCardSubtitle;

  /// No description provided for @postScratchCardWonTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 You Won!'**
  String get postScratchCardWonTitle;

  /// No description provided for @postScratchCardNoRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Better Luck Next Time!'**
  String get postScratchCardNoRewardTitle;

  /// No description provided for @postScratchCardNoRewardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep posting daily for more chances to win'**
  String get postScratchCardNoRewardSubtitle;

  /// No description provided for @postScratchCardContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get postScratchCardContinueButton;

  /// No description provided for @walletKycRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please complete your KYC to access the wallet and rewards'**
  String get walletKycRequiredMessage;

  /// No description provided for @walletKycCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Complete KYC'**
  String get walletKycCompleteButton;

  /// No description provided for @wheelPickerDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get wheelPickerDoneButton;

  /// No description provided for @postLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get postLengthLabel;

  /// No description provided for @postHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get postHeightLabel;

  /// No description provided for @postSelectLengthHint.
  ///
  /// In en, this message translates to:
  /// **'Select length'**
  String get postSelectLengthHint;

  /// No description provided for @postSelectHeightHint.
  ///
  /// In en, this message translates to:
  /// **'Select height'**
  String get postSelectHeightHint;

  /// No description provided for @feetValue.
  ///
  /// In en, this message translates to:
  /// **'{value} ft'**
  String feetValue(num value);

  /// No description provided for @reelCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get reelCommentsTitle;

  /// No description provided for @reelCommentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get reelCommentsEmpty;

  /// No description provided for @reelCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get reelCommentHint;

  /// No description provided for @reelCommentPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get reelCommentPost;

  /// No description provided for @reelCommentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reelCommentDelete;

  /// No description provided for @reelFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get reelFollow;

  /// No description provided for @reelFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get reelFollowing;

  /// No description provided for @reelShareText.
  ///
  /// In en, this message translates to:
  /// **'{title} — watch this reel on Convoy'**
  String reelShareText(String title);

  /// No description provided for @reelCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reelCategoryAll;

  /// No description provided for @reelDetailsCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get reelDetailsCategoriesLabel;

  /// No description provided for @reelDetailsCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Pick 1 to 5'**
  String get reelDetailsCategoriesHint;

  /// No description provided for @reelDetailsCategoriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one category'**
  String get reelDetailsCategoriesRequired;

  /// No description provided for @reelDetailsHashtagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Hashtags (optional)'**
  String get reelDetailsHashtagsLabel;

  /// No description provided for @reelDetailsHashtagsHint.
  ///
  /// In en, this message translates to:
  /// **'#trucklife #nightrun'**
  String get reelDetailsHashtagsHint;

  /// No description provided for @reelDetailsHashtagsMax.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 10 hashtags'**
  String get reelDetailsHashtagsMax;

  /// No description provided for @profileMyUploads.
  ///
  /// In en, this message translates to:
  /// **'My Uploads'**
  String get profileMyUploads;

  /// No description provided for @uploadsCreatorInsights.
  ///
  /// In en, this message translates to:
  /// **'Creator Insights'**
  String get uploadsCreatorInsights;

  /// No description provided for @uploadsNewPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get uploadsNewPost;

  /// No description provided for @uploadsStatReels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get uploadsStatReels;

  /// No description provided for @uploadsStatTotalViews.
  ///
  /// In en, this message translates to:
  /// **'Total Views'**
  String get uploadsStatTotalViews;

  /// No description provided for @uploadsStatAppreciation.
  ///
  /// In en, this message translates to:
  /// **'Appreciation'**
  String get uploadsStatAppreciation;

  /// No description provided for @uploadsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'+{count} this wk'**
  String uploadsThisWeek(int count);

  /// No description provided for @uploadsAllReelsTab.
  ///
  /// In en, this message translates to:
  /// **'All Reels ({count})'**
  String uploadsAllReelsTab(int count);

  /// No description provided for @uploadsCategoryTab.
  ///
  /// In en, this message translates to:
  /// **'{name} ({count})'**
  String uploadsCategoryTab(String name, int count);

  /// No description provided for @uploadsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t uploaded any reels yet'**
  String get uploadsEmpty;

  /// No description provided for @uploadsRecordCta.
  ///
  /// In en, this message translates to:
  /// **'Upload Reel'**
  String get uploadsRecordCta;

  /// No description provided for @uploadsMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get uploadsMenuDelete;

  /// No description provided for @uploadsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this reel?'**
  String get uploadsDeleteConfirmTitle;

  /// No description provided for @uploadsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the reel along with its likes and comments. This can\'t be undone.'**
  String get uploadsDeleteConfirmBody;

  /// No description provided for @uploadsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reel deleted'**
  String get uploadsDeleteSuccess;

  /// No description provided for @uploadsReelNotPlayable.
  ///
  /// In en, this message translates to:
  /// **'This reel can\'t be played yet'**
  String get uploadsReelNotPlayable;

  /// No description provided for @uploadsStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get uploadsStatusProcessing;

  /// No description provided for @uploadsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get uploadsStatusRejected;

  /// No description provided for @uploadsStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get uploadsStatusFailed;

  /// No description provided for @uploadsPostedToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get uploadsPostedToday;

  /// No description provided for @uploadsPostedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get uploadsPostedYesterday;

  /// No description provided for @uploadsPostedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String uploadsPostedDaysAgo(int days);

  /// No description provided for @uploadsPostedWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks}w ago'**
  String uploadsPostedWeeksAgo(int weeks);

  /// No description provided for @uploadsPostedMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months}mo ago'**
  String uploadsPostedMonthsAgo(int months);

  /// No description provided for @navHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get navHeatmap;

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Heatmap'**
  String get heatmapTitle;

  /// No description provided for @heatmapTabTrucks.
  ///
  /// In en, this message translates to:
  /// **'Trucks'**
  String get heatmapTabTrucks;

  /// No description provided for @heatmapTabReels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get heatmapTabReels;

  /// No description provided for @heatmapLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading heatmap…'**
  String get heatmapLoading;

  /// No description provided for @heatmapErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the heatmap'**
  String get heatmapErrorGeneric;

  /// No description provided for @heatmapEmptyTrucks.
  ///
  /// In en, this message translates to:
  /// **'No live trucks to show yet'**
  String get heatmapEmptyTrucks;

  /// No description provided for @heatmapEmptyReels.
  ///
  /// In en, this message translates to:
  /// **'No recent reels with a location yet'**
  String get heatmapEmptyReels;

  /// No description provided for @heatmapZoomOutHint.
  ///
  /// In en, this message translates to:
  /// **'Zoom out to see more activity'**
  String get heatmapZoomOutHint;

  /// No description provided for @heatmapLegendLow.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get heatmapLegendLow;

  /// No description provided for @heatmapLegendHigh.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapLegendHigh;

  /// No description provided for @heatmapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get heatmapMyLocation;

  /// No description provided for @heatmapCellTrucks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 truck in this area} other{{count} trucks in this area}}'**
  String heatmapCellTrucks(int count);

  /// No description provided for @heatmapCellReels.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 reel in this area} other{{count} reels in this area}}'**
  String heatmapCellReels(int count);

  /// No description provided for @heatmapNoTrucksInView.
  ///
  /// In en, this message translates to:
  /// **'No trucks in this area right now'**
  String get heatmapNoTrucksInView;

  /// No description provided for @heatmapPinsTruncated.
  ///
  /// In en, this message translates to:
  /// **'Showing the trucks closest to the centre — zoom in to see more'**
  String get heatmapPinsTruncated;

  /// No description provided for @heatmapPinsModeHint.
  ///
  /// In en, this message translates to:
  /// **'Individual trucks · tap a pin for details'**
  String get heatmapPinsModeHint;

  /// No description provided for @heatmapPinLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading truck details…'**
  String get heatmapPinLoading;

  /// No description provided for @heatmapPinUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This truck post is no longer available'**
  String get heatmapPinUnavailable;

  /// No description provided for @heatmapPinDetailError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load truck details'**
  String get heatmapPinDetailError;

  /// No description provided for @reelsAreaThisArea.
  ///
  /// In en, this message translates to:
  /// **'This area'**
  String get reelsAreaThisArea;

  /// No description provided for @reelsAreaShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all reels'**
  String get reelsAreaShowAll;

  /// No description provided for @reelsAreaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reels in this area right now'**
  String get reelsAreaEmpty;

  /// No description provided for @walletTxnCallHold.
  ///
  /// In en, this message translates to:
  /// **'Held for 1:1 call'**
  String get walletTxnCallHold;

  /// No description provided for @walletTxnCallRelease.
  ///
  /// In en, this message translates to:
  /// **'1:1 call hold released'**
  String get walletTxnCallRelease;

  /// No description provided for @walletTxnCallDebit.
  ///
  /// In en, this message translates to:
  /// **'Paid for 1:1 call'**
  String get walletTxnCallDebit;

  /// No description provided for @walletTxnCallEarning.
  ///
  /// In en, this message translates to:
  /// **'1:1 call earning'**
  String get walletTxnCallEarning;

  /// No description provided for @oneToOneSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Request 1:1 Live Session'**
  String get oneToOneSheetTitle;

  /// No description provided for @oneToOneSheetBadge.
  ///
  /// In en, this message translates to:
  /// **'DIRECT CONNECT'**
  String get oneToOneSheetBadge;

  /// No description provided for @oneToOneSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to {name} on a private live call about freight, route details and booking.'**
  String oneToOneSheetSubtitle(String name);

  /// No description provided for @oneToOneDriverFallback.
  ///
  /// In en, this message translates to:
  /// **'the driver'**
  String get oneToOneDriverFallback;

  /// No description provided for @oneToOneHowTitle.
  ///
  /// In en, this message translates to:
  /// **'The driver confirms first'**
  String get oneToOneHowTitle;

  /// No description provided for @oneToOneHowBody.
  ///
  /// In en, this message translates to:
  /// **'The driver reviews your request, then calls you. You see and hear them and speak through your microphone.'**
  String get oneToOneHowBody;

  /// No description provided for @oneToOneTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Session discussion topic'**
  String get oneToOneTopicLabel;

  /// No description provided for @oneToOneRequiredTag.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get oneToOneRequiredTag;

  /// No description provided for @oneToOneTopicHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Route status, load negotiation, dispatch schedule'**
  String get oneToOneTopicHint;

  /// No description provided for @oneToOneTopicRequired.
  ///
  /// In en, this message translates to:
  /// **'Tell the driver what you want to discuss'**
  String get oneToOneTopicRequired;

  /// No description provided for @oneToOneDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Session duration'**
  String get oneToOneDurationLabel;

  /// No description provided for @oneToOneDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins'**
  String oneToOneDurationMinutes(int minutes);

  /// No description provided for @oneToOneDurationQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick chat'**
  String get oneToOneDurationQuick;

  /// No description provided for @oneToOneDurationReview.
  ///
  /// In en, this message translates to:
  /// **'Route review'**
  String get oneToOneDurationReview;

  /// No description provided for @oneToOneDurationDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep booking'**
  String get oneToOneDurationDeep;

  /// No description provided for @oneToOneOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Your offer'**
  String get oneToOneOfferLabel;

  /// No description provided for @oneToOneOfferHint.
  ///
  /// In en, this message translates to:
  /// **'Amount in ₹'**
  String get oneToOneOfferHint;

  /// No description provided for @oneToOneOfferRange.
  ///
  /// In en, this message translates to:
  /// **'Offer between {min} and {max}'**
  String oneToOneOfferRange(String min, String max);

  /// No description provided for @oneToOneHoldExplainer.
  ///
  /// In en, this message translates to:
  /// **'{hold} is frozen now as the cost of connecting. After the call you choose: pay the full {amount} if you\'re satisfied, otherwise only {hold}.'**
  String oneToOneHoldExplainer(String hold, String amount);

  /// No description provided for @oneToOneWalletAvailable.
  ///
  /// In en, this message translates to:
  /// **'Wallet: {amount} available'**
  String oneToOneWalletAvailable(String amount);

  /// No description provided for @oneToOneNeedMoney.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} to your wallet to send this request'**
  String oneToOneNeedMoney(String amount);

  /// No description provided for @oneToOneAddMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get oneToOneAddMoneyButton;

  /// No description provided for @oneToOneMoneyAdded.
  ///
  /// In en, this message translates to:
  /// **'Test money added'**
  String get oneToOneMoneyAdded;

  /// No description provided for @oneToOneRechargeSoon.
  ///
  /// In en, this message translates to:
  /// **'Wallet recharge is coming soon'**
  String get oneToOneRechargeSoon;

  /// No description provided for @oneToOneSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get oneToOneSendButton;

  /// No description provided for @oneToOneStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Your 1:1 request'**
  String get oneToOneStatusTitle;

  /// No description provided for @oneToOneStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to respond'**
  String oneToOneStatusPending(String name);

  /// No description provided for @oneToOneStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} accepted. They will call you shortly'**
  String oneToOneStatusAccepted(String name);

  /// No description provided for @oneToOneStatusRinging.
  ///
  /// In en, this message translates to:
  /// **'{name} is calling you…'**
  String oneToOneStatusRinging(String name);

  /// No description provided for @oneToOneStatusLive.
  ///
  /// In en, this message translates to:
  /// **'On a call with {name}'**
  String oneToOneStatusLive(String name);

  /// No description provided for @oneToOneStatusAwaitingFeedback.
  ///
  /// In en, this message translates to:
  /// **'Call finished. Tell us how it went to complete payment'**
  String get oneToOneStatusAwaitingFeedback;

  /// No description provided for @oneToOneStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Call completed. You paid {amount}'**
  String oneToOneStatusCompleted(String amount);

  /// No description provided for @oneToOneStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'{name} can\'t take your call right now. Your money has been released'**
  String oneToOneStatusRejected(String name);

  /// No description provided for @oneToOneStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'No response in time. Your money has been released'**
  String get oneToOneStatusExpired;

  /// No description provided for @oneToOneStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled. Your money has been released'**
  String get oneToOneStatusCancelled;

  /// No description provided for @oneToOneStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'The call didn\'t connect. Nothing was charged'**
  String get oneToOneStatusFailed;

  /// No description provided for @oneToOneOfferSummary.
  ///
  /// In en, this message translates to:
  /// **'Offer {amount} · {minutes} min'**
  String oneToOneOfferSummary(String amount, int minutes);

  /// No description provided for @oneToOneFrozenSummary.
  ///
  /// In en, this message translates to:
  /// **'{hold} is frozen until the request ends'**
  String oneToOneFrozenSummary(String hold);

  /// No description provided for @oneToOneExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String oneToOneExpiresIn(String time);

  /// No description provided for @oneToOneCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get oneToOneCancelButton;

  /// No description provided for @oneToOneDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get oneToOneDoneButton;

  /// No description provided for @oneToOneStatusLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your request'**
  String get oneToOneStatusLoadError;

  /// No description provided for @oneToOneBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'1:1 Video Request Pending'**
  String get oneToOneBannerTitle;

  /// No description provided for @oneToOneBannerOffered.
  ///
  /// In en, this message translates to:
  /// **'{amount} offered'**
  String oneToOneBannerOffered(String amount);

  /// No description provided for @oneToOneBannerMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String oneToOneBannerMore(int count);

  /// No description provided for @oneToOneBannerReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get oneToOneBannerReview;

  /// No description provided for @oneToOneRequesterFallback.
  ///
  /// In en, this message translates to:
  /// **'the requester'**
  String get oneToOneRequesterFallback;

  /// No description provided for @oneToOneIncomingTitle.
  ///
  /// In en, this message translates to:
  /// **'1:1 video request'**
  String get oneToOneIncomingTitle;

  /// No description provided for @oneToOneIncomingFrom.
  ///
  /// In en, this message translates to:
  /// **'{name} wants a live 1:1 call with you'**
  String oneToOneIncomingFrom(String name);

  /// No description provided for @oneToOneIncomingTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'They want to discuss'**
  String get oneToOneIncomingTopicLabel;

  /// No description provided for @oneToOneEarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'What you earn'**
  String get oneToOneEarningsTitle;

  /// No description provided for @oneToOneEarningsBody.
  ///
  /// In en, this message translates to:
  /// **'At least {hold} once the call has been connected for 30 seconds. The full {amount} if {name} is satisfied afterwards.'**
  String oneToOneEarningsBody(String hold, String amount, String name);

  /// No description provided for @oneToOneAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get oneToOneAcceptButton;

  /// No description provided for @oneToOneRejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get oneToOneRejectButton;

  /// No description provided for @oneToOneRejectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this request?'**
  String get oneToOneRejectConfirmTitle;

  /// No description provided for @oneToOneRejectConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s money is released and the request is closed.'**
  String oneToOneRejectConfirmBody(String name);

  /// No description provided for @oneToOneKeepButton.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get oneToOneKeepButton;

  /// No description provided for @oneToOneIncomingAccepted.
  ///
  /// In en, this message translates to:
  /// **'You accepted {name}\'s request'**
  String oneToOneIncomingAccepted(String name);

  /// No description provided for @oneToOneIncomingRejected.
  ///
  /// In en, this message translates to:
  /// **'You declined this request'**
  String get oneToOneIncomingRejected;

  /// No description provided for @oneToOneIncomingExpired.
  ///
  /// In en, this message translates to:
  /// **'This request expired'**
  String get oneToOneIncomingExpired;

  /// No description provided for @oneToOneIncomingCancelled.
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled this request'**
  String oneToOneIncomingCancelled(String name);

  /// No description provided for @oneToOneIncomingFeedback.
  ///
  /// In en, this message translates to:
  /// **'Call finished. Waiting for {name}\'s feedback'**
  String oneToOneIncomingFeedback(String name);

  /// No description provided for @oneToOneIncomingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Call completed. You earned {amount}'**
  String oneToOneIncomingCompleted(String amount);

  /// No description provided for @oneToOneBannerReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'1:1 call ready to start'**
  String get oneToOneBannerReadyTitle;

  /// No description provided for @oneToOneBannerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get oneToOneBannerStart;

  /// No description provided for @oneToOneStartCallButton.
  ///
  /// In en, this message translates to:
  /// **'Start call'**
  String get oneToOneStartCallButton;

  /// No description provided for @oneToOneStartCallHint.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s phone will ring for 45 seconds. Park safely before you start.'**
  String oneToOneStartCallHint(String name);

  /// No description provided for @callRingingTitle.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}…'**
  String callRingingTitle(String name);

  /// No description provided for @callRingingHint.
  ///
  /// In en, this message translates to:
  /// **'Their phone is ringing'**
  String get callRingingHint;

  /// No description provided for @callWaitingForPeer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to join…'**
  String callWaitingForPeer(String name);

  /// No description provided for @callPeerDropped.
  ///
  /// In en, this message translates to:
  /// **'{name} lost connection. Waiting for them to come back…'**
  String callPeerDropped(String name);

  /// No description provided for @callYouDropped.
  ///
  /// In en, this message translates to:
  /// **'Your connection dropped. Reconnecting…'**
  String get callYouDropped;

  /// No description provided for @callServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. The call goes on, but its time may not be counted.'**
  String get callServerUnreachable;

  /// No description provided for @callReconnectButton.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get callReconnectButton;

  /// No description provided for @callTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String callTimeLeft(String time);

  /// No description provided for @callCounted.
  ///
  /// In en, this message translates to:
  /// **'Counts as a call'**
  String get callCounted;

  /// No description provided for @callCountsAfter.
  ///
  /// In en, this message translates to:
  /// **'Counts as a call after {seconds}s together'**
  String callCountsAfter(int seconds);

  /// No description provided for @callEndButton.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get callEndButton;

  /// No description provided for @callCancelRingButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get callCancelRingButton;

  /// No description provided for @callEndConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End the call?'**
  String get callEndConfirmTitle;

  /// No description provided for @callEndConfirmCounted.
  ///
  /// In en, this message translates to:
  /// **'This call has counted. {name} will be asked how it went.'**
  String callEndConfirmCounted(String name);

  /// No description provided for @callEndConfirmNotCounted.
  ///
  /// In en, this message translates to:
  /// **'This call hasn\'t counted yet. If you end it now, nothing is charged.'**
  String get callEndConfirmNotCounted;

  /// No description provided for @callKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get callKeepGoing;

  /// No description provided for @callMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callMute;

  /// No description provided for @callUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get callUnmute;

  /// No description provided for @callCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get callCameraOff;

  /// No description provided for @callCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Camera on'**
  String get callCameraOn;

  /// No description provided for @callFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get callFlip;

  /// No description provided for @callSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get callSpeaker;

  /// No description provided for @callChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get callChat;

  /// No description provided for @callAudioOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Only your microphone is on. {name} can\'t see you.'**
  String callAudioOnlyNote(String name);

  /// No description provided for @callSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t use the phone while driving'**
  String get callSafetyTitle;

  /// No description provided for @callSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Park safely before taking this call. Never look at the screen or type while the vehicle is moving.'**
  String get callSafetyBody;

  /// No description provided for @callSafetyOk.
  ///
  /// In en, this message translates to:
  /// **'I\'m parked'**
  String get callSafetyOk;

  /// No description provided for @callChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get callChatTitle;

  /// No description provided for @callChatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get callChatHint;

  /// No description provided for @callChatEmpty.
  ///
  /// In en, this message translates to:
  /// **'Messages only last for this call.'**
  String get callChatEmpty;

  /// No description provided for @callChatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Check your connection.'**
  String get callChatSendFailed;

  /// No description provided for @callStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting the call…'**
  String get callStarting;

  /// No description provided for @callPermissionMic.
  ///
  /// In en, this message translates to:
  /// **'Allow the microphone to take part in the call.'**
  String get callPermissionMic;

  /// No description provided for @callPermissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow the camera so the other person can see you.'**
  String get callPermissionCamera;

  /// No description provided for @callOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get callOpenSettings;

  /// No description provided for @callClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get callClose;

  /// No description provided for @callEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get callEndedTitle;

  /// No description provided for @callEndedDriverCounted.
  ///
  /// In en, this message translates to:
  /// **'You were on the call for {duration}. {name} will now say if they were satisfied. You earn {callAmount} for sure, and {offer} if they are.'**
  String callEndedDriverCounted(
    String duration,
    String name,
    String callAmount,
    String offer,
  );

  /// No description provided for @callEndedRequesterCounted.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your call with {name}.'**
  String callEndedRequesterCounted(String name);

  /// No description provided for @callEndedTooShort.
  ///
  /// In en, this message translates to:
  /// **'The call was too short to count (under {seconds} seconds). Nothing was charged.'**
  String callEndedTooShort(int seconds);

  /// No description provided for @callEndedUnanswered.
  ///
  /// In en, this message translates to:
  /// **'{name} didn\'t pick up. You can try again until the request expires.'**
  String callEndedUnanswered(String name);

  /// No description provided for @callEndedDeclined.
  ///
  /// In en, this message translates to:
  /// **'{name} declined the call. The request is closed.'**
  String callEndedDeclined(String name);

  /// No description provided for @callEndedUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'You left the call. We couldn\'t reach the server, so it will be settled shortly.'**
  String get callEndedUnconfirmed;

  /// No description provided for @callEndedOther.
  ///
  /// In en, this message translates to:
  /// **'The call has ended.'**
  String get callEndedOther;

  /// No description provided for @callDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get callDoneButton;

  /// No description provided for @callIncomingTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is calling you'**
  String callIncomingTitle(String name);

  /// No description provided for @callIncomingOffer.
  ///
  /// In en, this message translates to:
  /// **'{amount} offered · {minutes} min'**
  String callIncomingOffer(String amount, int minutes);

  /// No description provided for @callIncomingHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll hear {name} and see their camera. Only your microphone is on.'**
  String callIncomingHint(String name);

  /// No description provided for @callAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get callAnswer;

  /// No description provided for @callDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get callDecline;

  /// No description provided for @callDeclineHint.
  ///
  /// In en, this message translates to:
  /// **'Declining cancels your request and releases your money.'**
  String get callDeclineHint;

  /// No description provided for @callRingSeconds.
  ///
  /// In en, this message translates to:
  /// **'Ringing · {seconds}s'**
  String callRingSeconds(int seconds);

  /// No description provided for @callMissed.
  ///
  /// In en, this message translates to:
  /// **'You missed the call. {name} can try again, or you can cancel your request.'**
  String callMissed(String name);

  /// No description provided for @callRejoinTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re still in a call'**
  String get callRejoinTitle;

  /// No description provided for @callRejoinBody.
  ///
  /// In en, this message translates to:
  /// **'Your call with {name} is still going. Rejoin to carry on.'**
  String callRejoinBody(String name);

  /// No description provided for @callRejoinButton.
  ///
  /// In en, this message translates to:
  /// **'Rejoin'**
  String get callRejoinButton;

  /// No description provided for @callRejoinEndButton.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get callRejoinEndButton;

  /// No description provided for @callFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Were you satisfied with the call?'**
  String get callFeedbackTitle;

  /// No description provided for @callFeedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Your answer decides what {name} is paid.'**
  String callFeedbackBody(String name);

  /// No description provided for @callFeedbackYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, pay {amount}'**
  String callFeedbackYes(String amount);

  /// No description provided for @callFeedbackNo.
  ///
  /// In en, this message translates to:
  /// **'No, pay only {amount}'**
  String callFeedbackNo(String amount);

  /// No description provided for @callFeedbackNoNote.
  ///
  /// In en, this message translates to:
  /// **'{amount} is the cost of connecting the call.'**
  String callFeedbackNoNote(String amount);

  /// No description provided for @callFeedbackLater.
  ///
  /// In en, this message translates to:
  /// **'Decide later'**
  String get callFeedbackLater;

  /// No description provided for @callFeedbackLaterNote.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t answer within 24 hours, only {amount} is paid.'**
  String callFeedbackLaterNote(String amount);

  /// No description provided for @callFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! You paid {amount}.'**
  String callFeedbackThanks(String amount);

  /// No description provided for @callDeclineFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection and try again.'**
  String get callDeclineFailed;

  /// No description provided for @callOngoingTitle.
  ///
  /// In en, this message translates to:
  /// **'Call in progress'**
  String get callOngoingTitle;

  /// No description provided for @callOngoingText.
  ///
  /// In en, this message translates to:
  /// **'Tap to return to your call with {name}'**
  String callOngoingText(String name);

  /// No description provided for @rechargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add money to your wallet'**
  String get rechargeTitle;

  /// No description provided for @rechargeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to add (₹)'**
  String get rechargeAmountLabel;

  /// No description provided for @rechargeRange.
  ///
  /// In en, this message translates to:
  /// **'Between ₹{min} and ₹{max} at a time'**
  String rechargeRange(String min, String max);

  /// No description provided for @rechargeInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between ₹{min} and ₹{max}'**
  String rechargeInvalidAmount(String min, String max);

  /// No description provided for @rechargeAddedToWallet.
  ///
  /// In en, this message translates to:
  /// **'Added to your wallet'**
  String get rechargeAddedToWallet;

  /// No description provided for @rechargeGatewayFee.
  ///
  /// In en, this message translates to:
  /// **'Payment gateway fee'**
  String get rechargeGatewayFee;

  /// No description provided for @rechargeYouPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get rechargeYouPay;

  /// No description provided for @rechargePayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String rechargePayButton(String amount);

  /// No description provided for @rechargeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Adding money isn\'t available right now'**
  String get rechargeUnavailable;

  /// No description provided for @rechargeCreating.
  ///
  /// In en, this message translates to:
  /// **'Getting your payment ready…'**
  String get rechargeCreating;

  /// No description provided for @rechargePaying.
  ///
  /// In en, this message translates to:
  /// **'Complete the payment in the payment window'**
  String get rechargePaying;

  /// No description provided for @rechargeConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment…'**
  String get rechargeConfirming;

  /// No description provided for @rechargeDone.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to your wallet'**
  String rechargeDone(String amount);

  /// No description provided for @rechargePending.
  ///
  /// In en, this message translates to:
  /// **'We\'re still confirming your payment. Your balance will update shortly. You don\'t need to pay again.'**
  String get rechargePending;

  /// No description provided for @rechargeFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'The payment didn\'t go through. You haven\'t been charged.'**
  String get rechargeFailedGeneric;

  /// No description provided for @rechargeClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get rechargeClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
