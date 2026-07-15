// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Convoy';

  @override
  String get languageSelectTitle => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get truckTypeOpenBody => 'Open Body';

  @override
  String get truckTypeClosedBody => 'Closed Body';

  @override
  String get truckTypeContainer20Ft => 'Container 20ft';

  @override
  String get truckTypeContainer32Ft => 'Container 32ft';

  @override
  String get truckTypeTipper => 'Tipper';

  @override
  String get truckTypeSidewallTrailer => 'Sidewall Trailer';

  @override
  String get truckTypeFlatBedTrailer => 'Flat Bed Trailer';

  @override
  String get truckTypeBulker => 'Bulker';

  @override
  String get truckTypeTanker => 'Tanker';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingTitle => 'Loads come\nto you, every day.';

  @override
  String get onboardingSubtitle =>
      'Post your truck once. Verified transporters call you. No middlemen, no running around.';

  @override
  String get onboardingChangeLanguage => 'Change language';

  @override
  String get phoneEnterNumberHint => 'Enter Your Number';

  @override
  String get phoneContinueButton => 'Continue with Mobile Number';

  @override
  String get otpTitle => 'Enter the 4-digit code';

  @override
  String otpSentTo(String phone) {
    return 'Sent to +91 $phone';
  }

  @override
  String get otpHelperText =>
      'Didn\'t receive it? Check the number and try resending.';

  @override
  String otpResendIn(String seconds) {
    return 'Didn\'t get it? Resend in 0:$seconds';
  }

  @override
  String get otpResendCode => 'Resend code';

  @override
  String get callDialerHint => 'Opens your phone dialer';

  @override
  String get callCalling => 'Calling…';

  @override
  String callConnected(String duration) {
    return 'Connected · $duration';
  }

  @override
  String get callDisclaimer =>
      'Convoy has no in-app calling. Tapping Call\nopens your phone dialer and logs it for your records.';

  @override
  String get homeHello => 'Hello';

  @override
  String get homeHeroTitle => 'Your truck is ready\nto earn 💰';

  @override
  String get homeHeroSubtitle =>
      'Post now and get verified load requests instantly.';

  @override
  String get homeHeroButton => 'Post Truck Now';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homePostNewTruck => 'Post New Truck';

  @override
  String get homePostNewTruckSubtitle => 'Ready in 30 seconds';

  @override
  String get homeSearchTrucks => 'Search Trucks';

  @override
  String get homeSearchTrucksSubtitle => 'Find available vehicles';

  @override
  String get homeManageSection => 'Manage Post & Searches';

  @override
  String get homeRecentPosts => 'Recent Posts';

  @override
  String get homeRecentSearch => 'Recent Search';

  @override
  String get homeNoRecentPosts => 'No recent posts';

  @override
  String get homeNoRecentSearches => 'No recent searches';

  @override
  String get homeRepost => 'Repost';

  @override
  String homeErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get kycVerifyTitle => 'Verify Aadhar Card';

  @override
  String get kycAadhaarHint => 'XXXX XXXX XXXX';

  @override
  String get kycVerifyButton => 'Verify Aadhar';

  @override
  String get kycPendingTitle => 'Your KYC is Pending';

  @override
  String get kycPendingSubtitle =>
      'We are verifying your details. Please complete\nyour KYC to continue using Sharkship services.';

  @override
  String get kycWhatsNext => 'What happens next?';

  @override
  String get kycWhatsNextSubtitle =>
      'We\'ll notify you as soon as your KYC is verified.';

  @override
  String get kycIdCardLabel => 'KYC';

  @override
  String get kycIdCardBrand => 'Sharkship';

  @override
  String get kycOtpHelperText =>
      'OTP has been sent to your Aadhaar-linked mobile number. Please enter it to verify.';

  @override
  String get kycOtpVerifyButton => 'Verify OTP';

  @override
  String get kycThankYou => 'Thank You';

  @override
  String get kycSuccessMessage => 'eKYC Process Successfully Completed';

  @override
  String get postScreenTitle => 'Post your truck';

  @override
  String get postRouteSectionLabel => 'ROUTE';

  @override
  String get postSelectTruckSectionLabel => 'SELECT TRUCK';

  @override
  String get postOriginLabel => 'From (current location)';

  @override
  String get postOriginHint => 'Tap the locate button to detect';

  @override
  String get postGpsAutoDetected => 'GPS Auto-detected';

  @override
  String postDestinationLabel(int number) {
    return 'Destination $number';
  }

  @override
  String get postDestinationHint => 'Enter destination';

  @override
  String get postCouldNotLoadTrucks => 'Could not load your trucks';

  @override
  String get postSelectTruckHint => 'Select a truck';

  @override
  String get postAddNewTruck => 'Add New Truck';

  @override
  String get postSubmitButton => 'Post a Truck';

  @override
  String get postAddTruckSheetTitle => 'Add a Truck';

  @override
  String get postTruckNumberLabel => 'Truck Number';

  @override
  String get postTruckNumberHint => 'e.g. MH04AB1234';

  @override
  String get postTruckTypeLabel => 'Truck Type';

  @override
  String get postSelectTypeHint => 'Select type';

  @override
  String get postCapacityLabel => 'Capacity';

  @override
  String get postSelectCapacityHint => 'Select capacity';

  @override
  String get postAddTruckButton => 'Add Truck';

  @override
  String get postContactSectionTitle => 'Who should we contact?';

  @override
  String get postContactMe => 'Me';

  @override
  String get postContactSomeoneElse => 'Someone else';

  @override
  String get postContactNameLabel => 'Contact name';

  @override
  String get postContactNameHint => 'Enter contact name';

  @override
  String get postContactNumberLabel => 'Contact number';

  @override
  String get postContactNumberHint => '10-digit mobile number';

  @override
  String get postContactNumberError => 'Enter a valid 10-digit mobile number';

  @override
  String get postEditTitle => 'Edit truck post';

  @override
  String get postSaveChangesButton => 'Save Changes';

  @override
  String get postSuccessTitle => 'Your truck is posted!';

  @override
  String get postSuccessSubtitle =>
      'Load owners near you can now see it and call you directly.';

  @override
  String get postSuccessTruckTypeLabel => 'Truck type';

  @override
  String get postSuccessPickupLabel => 'Pickup location';

  @override
  String get postSuccessGoToDashboard => 'Go to Dashboard';

  @override
  String get postSuccessPostAnother => 'Post another truck';

  @override
  String get myTrucksTitle => 'My Trucks';

  @override
  String get myTrucksDeleteTitle => 'Delete truck';

  @override
  String myTrucksDeleteMessage(String vehicleNumber) {
    return 'Remove $vehicleNumber from your trucks? This cannot be undone.';
  }

  @override
  String get myTrucksNoTrucks => 'No trucks added yet';

  @override
  String get tripsTitle => 'My Trips';

  @override
  String get tripsNoTrips => 'No trips posted yet';

  @override
  String get tripsActiveLabel => 'Active Trip';

  @override
  String get tripsExpiredLabel => 'Expired';

  @override
  String get tripsEdit => 'Edit';

  @override
  String get tripsReactivate => 'Reactivate';

  @override
  String get tripsDeleteTitle => 'Delete trip';

  @override
  String get tripsDeleteMessage =>
      'Delete this trip permanently? This cannot be undone.';

  @override
  String tripsMoreDestinations(int count) {
    return '+$count more';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLogoutTitle => 'Logout';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profileKycLabel => 'KYC';

  @override
  String get profileKycVerified => 'Verified';

  @override
  String get profileKycInReview => 'In Review';

  @override
  String get profileKycRejected => 'Rejected';

  @override
  String get profileKycPending => 'Pending';

  @override
  String get profileMyVehicles => 'My Vehicles';

  @override
  String profileVehicleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles added',
      one: '1 vehicle added',
    );
    return '$_temp0';
  }

  @override
  String get profileTerms => 'Terms & Conditions';

  @override
  String get profilePrivacy => 'Privacy & Policy';

  @override
  String get profileHelp => 'Help & Support';

  @override
  String get profileHelpSubtitle => 'Chat, call or email us';

  @override
  String profileAccountStatusPrefix(String status) {
    return 'Account $status';
  }

  @override
  String get profileAccountSuspended => 'suspended';

  @override
  String get profileAccountBlocked => 'blocked';

  @override
  String get profileAccountInactive => 'inactive';

  @override
  String get searchTitle => 'Search Trucks';

  @override
  String get searchSubtitle => 'Find the right truck for your load';

  @override
  String get searchOriginLabel => 'Origin';

  @override
  String get searchOriginHint => 'Select Origin';

  @override
  String get searchDestinationLabel => 'Destination';

  @override
  String get searchDestinationHint => 'Select Destination';

  @override
  String get searchTruckTypeLabel => 'Truck Type';

  @override
  String get searchSelectTruckHint => 'Select Truck';

  @override
  String get searchCapacityLabel => 'Capacity';

  @override
  String get searchSelectHint => 'Select';

  @override
  String get searchFindTrucksButton => 'Find Trucks';

  @override
  String get resultsTitle => 'Search Results';

  @override
  String get resultsSearching => 'Searching…';

  @override
  String resultsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trucks found',
      one: '1 truck found',
    );
    return '$_temp0';
  }

  @override
  String get resultsYourResults => 'Your search results';

  @override
  String get resultsRunSearch => 'Run a search to see results';

  @override
  String get resultsNoneNearby => 'No trucks found nearby';

  @override
  String get resultsAnyOrigin => 'Any origin';

  @override
  String get resultsAnyDestination => 'Any destination';

  @override
  String get resultsOriginLabel => 'ORIGIN';

  @override
  String get resultsDestinationLabel => 'DESTINATION';

  @override
  String get resultsDateLabel => 'Date';

  @override
  String get resultsAny => 'Any';

  @override
  String get resultsCallDialerError => 'Could not open the phone dialer';

  @override
  String get resultsCallNow => 'Call Now';

  @override
  String resultsPageOf(int page, int totalPages) {
    return 'Page $page of $totalPages';
  }

  @override
  String resultsMutualCount(int count) {
    return '$count mutual';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'Profile';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count more';
  }

  @override
  String capacityTon(int capacity) {
    return '$capacity Ton';
  }
}
