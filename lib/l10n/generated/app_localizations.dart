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
  /// **'Convoy'**
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
  /// **'Allow Convoy to access your location from Settings to auto-detect your current location.'**
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
  /// **'Loads come\nto you, every day.'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post your truck once. Verified transporters call you. No middlemen, no running around.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get onboardingChangeLanguage;

  /// No description provided for @phoneEnterNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Number'**
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
  /// **'Convoy has no in-app calling. Tapping Call\nopens your phone dialer and logs it for your records.'**
  String get callDisclaimer;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeHello;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your truck is ready\nto earn 💰'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post now and get verified load requests instantly.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeHeroButton.
  ///
  /// In en, this message translates to:
  /// **'Post Truck Now'**
  String get homeHeroButton;

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

  /// No description provided for @homeManageSection.
  ///
  /// In en, this message translates to:
  /// **'Manage Post & Searches'**
  String get homeManageSection;

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

  /// No description provided for @kycPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your KYC is Pending'**
  String get kycPendingTitle;

  /// No description provided for @kycPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are verifying your details. Please complete\nyour KYC to continue using Sharkship services.'**
  String get kycPendingSubtitle;

  /// No description provided for @kycWhatsNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next?'**
  String get kycWhatsNext;

  /// No description provided for @kycWhatsNextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you as soon as your KYC is verified.'**
  String get kycWhatsNextSubtitle;

  /// No description provided for @kycIdCardLabel.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get kycIdCardLabel;

  /// No description provided for @kycIdCardBrand.
  ///
  /// In en, this message translates to:
  /// **'Sharkship'**
  String get kycIdCardBrand;

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

  /// No description provided for @kycThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get kycThankYou;

  /// No description provided for @kycSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'eKYC Process Successfully Completed'**
  String get kycSuccessMessage;

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

  /// No description provided for @postAddNewTruck.
  ///
  /// In en, this message translates to:
  /// **'Add New Truck'**
  String get postAddNewTruck;

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
  /// **'✓ Verified Driver'**
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
  /// **'Convoy uses your contacts to show mutual connections with other users. Your contacts are never shared — only secure one-way hashes are synced.'**
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

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @truckCardMoreDestinations.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String truckCardMoreDestinations(int count);

  /// No description provided for @capacityTon.
  ///
  /// In en, this message translates to:
  /// **'{capacity} Ton'**
  String capacityTon(int capacity);

  /// No description provided for @networkOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkOfflineBanner;
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
