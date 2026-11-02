// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bonut';

  @override
  String get languageSelectTitle => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get languageKannada => 'ಕನ್ನಡ';

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
  String get locationServiceDisabledTitle => 'Location is turned off';

  @override
  String get locationServiceDisabledMessage =>
      'Turn on location services to auto-detect your current location.';

  @override
  String get locationEnableButton => 'Enable Location';

  @override
  String get locationPermissionDeniedTitle => 'Location permission needed';

  @override
  String get locationPermissionDeniedMessage =>
      'Allow Bonut to access your location from Settings to auto-detect your current location.';

  @override
  String get locationOpenSettingsButton => 'Open Settings';

  @override
  String get truckTypeOpenBody => 'Open Body';

  @override
  String get truckTypeClosedBody => 'Closed Body';

  @override
  String get truckTypeTipper => 'Tipper';

  @override
  String get truckTypeSidewallTrailer => 'Sidewall Trailer';

  @override
  String get truckTypeFlatBedTrailer => 'Flat Bed Trailer';

  @override
  String get truckTypeFlatBedTruck => 'Flat Bed Truck';

  @override
  String get truckTypeLowBedTrailer => 'Low Bed Trailer';

  @override
  String get truckTypeRefrigeratedTruck => 'Refrigerated Truck';

  @override
  String get truckTypeBulker => 'Bulker';

  @override
  String get truckTypeTanker => 'Tanker';

  @override
  String get truckTypePuller => 'Puller';

  @override
  String get truckTypeWindbladeTrailer => 'Windblade Trailer';

  @override
  String get truckTypePickupTruck => 'Pickup Truck/Tata Ace';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingTitle => 'Loads come\nto you, ~every day.~';

  @override
  String get onboardingSubtitle =>
      'Post your truck once. Verified transporters call you. No middlemen, no running around.';

  @override
  String get onboardingPage2Title => 'Ab koi truck ~Khaali nahi chalega~';

  @override
  String get onboardingPage2Subtitle =>
      'Apna truck list kijiye. Load owners aapko dhoondh lenge.';

  @override
  String get onboardingPage2Button => 'Aage Badhein';

  @override
  String get onboardingPage3Title => 'Verified Loads.\n~Seedha Connection.~';

  @override
  String get onboardingPage3Subtitle => 'Genuine Loads aapke har trip ke liye.';

  @override
  String get onboardingPage3Button => 'Shuru Karein';

  @override
  String get onboardingChangeLanguage => 'Change language';

  @override
  String get phoneEnterNumberHint => 'Enter Mobile Number';

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
  String get enterNameTitle => 'What should we call you?';

  @override
  String get enterNameSubtitle => 'Enter your name to continue';

  @override
  String get enterNameHint => 'Enter your name';

  @override
  String get enterNameButton => 'Continue';

  @override
  String get enterNameError => 'Couldn\'t save your name. Please try again.';

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
      'Bounut has no in-app calling. Tapping Call\nopens your phone dialer and logs it for your records.';

  @override
  String get homeHello => 'Hello';

  @override
  String get homeHeroTitle => 'Truck Ready Hai? Ab Kaam Shuru Karein.';

  @override
  String get homeHeroSubtitle =>
      'Verified load requests seedha aapke mobile par.';

  @override
  String get homeHeroButton => 'Truck List Karein';

  @override
  String get homeCarousel2Title => 'Aaj Ka Pehla Load Pakde?';

  @override
  String get homeCarousel2Subtitle =>
      '100% verified loads. No fraud, only fayda.';

  @override
  String get homeCarousel3Title => 'Khali Truck... Sabse Mehenga Hota Hai.';

  @override
  String get homeCarousel3Subtitle =>
      'Aaj hi list karo, verified loads pao turant.';

  @override
  String get homeCarousel4Title => 'Aapka Truck. Aapki Mehnat. Pakka Fayda.';

  @override
  String get homeCarousel4Subtitle =>
      'Verified loads. Sahi rate. Time pe payment.';

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
  String get profileRecentPostsSearches => 'Recent Post & Searches';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeRecentPosts => 'Recent Posts';

  @override
  String get homeRecentSearch => 'Recent Search';

  @override
  String get homeNoRecentPosts => 'No recent posts';

  @override
  String get homeNoRecentSearches => 'No recent searches';

  @override
  String get homeTrendingReels => 'Trending Road Reels';

  @override
  String get homeViewFeed => 'View Feed';

  @override
  String get homeNoReelsYet => 'No reels yet';

  @override
  String get reelRecordCameraError => 'Couldn\'t access the camera';

  @override
  String get reelRecordHint => 'Tap to record';

  @override
  String get reelTrimTitle => 'Trim Your Reel';

  @override
  String reelTrimSelectedDuration(String seconds) {
    return '${seconds}s selected';
  }

  @override
  String get reelTrimNext => 'Next';

  @override
  String get reelDetailsTitle => 'Reel Details';

  @override
  String get reelDetailsTitleLabel => 'Title';

  @override
  String get reelDetailsTitleHint => 'Give your reel a title';

  @override
  String get reelDetailsDescriptionLabel => 'Description (optional)';

  @override
  String get reelDetailsDescriptionHint => 'Add a description';

  @override
  String get reelDetailsTitleRequired => 'Please enter a title';

  @override
  String get reelPostButton => 'Post Reel';

  @override
  String get reelUploadingTitle => 'Uploading your reel…';

  @override
  String get reelUploadingSubtitle => 'Please don\'t close the app';

  @override
  String get reelUploadSuccessTitle => 'Reel Uploaded!';

  @override
  String get reelUploadSuccessSubtitle =>
      'Your reel is being processed and will appear in the feed shortly.';

  @override
  String get reelBackToReels => 'Back to Reels';

  @override
  String get kycVerifyTitle => 'Verify Aadhar Card';

  @override
  String get kycAadhaarHint => 'XXXX XXXX XXXX';

  @override
  String get kycVerifyButton => 'Verify Aadhar';

  @override
  String get kycOtpHelperText =>
      'OTP has been sent to your Aadhaar-linked mobile number. Please enter it to verify.';

  @override
  String get kycOtpVerifyButton => 'Verify OTP';

  @override
  String get kycCheckingAadhaar => 'Checking...';

  @override
  String get kycAadhaarUnavailable => 'This Aadhaar can\'t be used';

  @override
  String get kycAadhaarConflictSnackbar =>
      'This Aadhaar has already been verified with another account.';

  @override
  String get kycThankYou => 'Aadhaar Verified!';

  @override
  String get kycSuccessMessage =>
      'One more step — let\'s confirm your photo to complete verification.';

  @override
  String get faceReviewTitle => 'Use this photo?';

  @override
  String get faceReviewRetake => 'Retake';

  @override
  String get faceReviewConfirm => 'Use this photo';

  @override
  String get faceReviewVerifyingTitle => 'Verifying';

  @override
  String get faceReviewVerifyingMessage =>
      'Please wait, we\'re verifying your photo';

  @override
  String get faceReviewVerificationFailed =>
      'We couldn\'t confirm your verification. Please try again.';

  @override
  String get postScreenTitle => 'Post your truck';

  @override
  String get postRouteSectionLabel => 'ROUTE';

  @override
  String get postSelectTruckSectionLabel => 'SELECT TRUCK';

  @override
  String get postOriginLabel => 'From (current location)';

  @override
  String get postOriginHint => 'Locate Your Position';

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
  String get postSearchTruckHint => 'Search by truck number';

  @override
  String get postAddNewTruck => 'Add New Truck';

  @override
  String get postTruckSearchEmptyMessage =>
      'No truck with this number available. Type the number and tap Add New Truck below to add it.';

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
  String get postVerifyButton => 'Verify';

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
  String get profileAccountSection => 'ACCOUNT';

  @override
  String get profileVerifiedDriver => '✓ Verified';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLogoutTitle => 'Logout';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profileKycLabel => 'KYC Verification';

  @override
  String get profileKycVerified => '✓ Done';

  @override
  String get profileKycInReview => 'In Review';

  @override
  String get profileKycRejected => 'Rejected';

  @override
  String get profileKycPending => 'Pending';

  @override
  String get profileKycPhotoPending => 'Photo Pending';

  @override
  String get profileKycAlreadyVerified => 'Your KYC is already verified';

  @override
  String get profileMyVehicles => 'My Vehicles';

  @override
  String get profileTermsPrivacy => 'Terms & Privacy';

  @override
  String get profileHelp => '24×7 Driver Support';

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
  String get searchVehicleNumberLabel => 'Vehicle No.';

  @override
  String get searchSelectHint => 'Select';

  @override
  String get searchCapacityNotApplicable => 'Not applicable';

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
  String get resultsSortByLabel => 'Sort By:';

  @override
  String get resultsSortNearestOrigin => 'Nearest to Origin';

  @override
  String get resultsSortNearestDestination => 'Nearest to Destination';

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
  String get resultsViewAllMutuals => 'View All';

  @override
  String resultsPostedBy(String userName) {
    return 'Posted By: $userName';
  }

  @override
  String get resultsCallSheetTitle => 'Who would you like to call?';

  @override
  String get resultsContactLabel => 'Contact';

  @override
  String get resultsPostedByLabel => 'Posted By';

  @override
  String get mutualContactsSheetTitle => 'Mutual Contacts';

  @override
  String get mutualContactsEmpty => 'No mutual contacts found';

  @override
  String get mutualContactsNumberUnavailable => 'Number unavailable';

  @override
  String get contactsPermissionRationale =>
      'Bonut uses your contacts to show mutual connections with other users. Your contacts are never shared — only secure one-way hashes are synced.';

  @override
  String get contactsPermissionDeniedMessage =>
      'Contacts permission denied. Enable it in Settings to see mutual connections.';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navProfile => 'Profile';

  @override
  String get navReels => 'Reels';

  @override
  String truckCardMoreDestinations(int count) {
    return '+$count more';
  }

  @override
  String capacityTon(num capacity) {
    return '$capacity Ton';
  }

  @override
  String get networkOfflineBanner => 'No internet connection';

  @override
  String get truckMapPreviewTitle => 'Live Truck Map';

  @override
  String get truckMapPreviewSubtitle => 'Tap to view trucks near you';

  @override
  String get truckMapPreviewCta => 'View Live Map';

  @override
  String get truckMapAppBarTitle => 'Trucks Near You';

  @override
  String get truckMapLoading => 'Finding trucks near you…';

  @override
  String get truckMapNoTrucksNearby => 'No trucks found within 150 km';

  @override
  String get truckMapErrorGeneric => 'Couldn\'t load trucks';

  @override
  String get truckMapRetry => 'Retry';

  @override
  String truckMapCountFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trucks nearby',
      one: '1 truck nearby',
    );
    return '$_temp0';
  }

  @override
  String get truckMapDetailsTitle => 'Truck Details';

  @override
  String get truckDetailsRequestOneToOne => 'Request 1:1';

  @override
  String get truckDetailsCallDriver => 'Call Driver to Book';

  @override
  String get truckDetailsRequestSoon => '1:1 requests are coming soon';

  @override
  String get truckDetailsClose => 'Close';

  @override
  String truckMapViewList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'View List ($count)',
      one: 'View List (1)',
    );
    return '$_temp0';
  }

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletBalanceCardLabel => 'Total Rewards Earned';

  @override
  String walletPendingPayout(String amount) {
    return '$amount pending payout';
  }

  @override
  String get walletFrozenMessage => 'Wallet frozen — contact support';

  @override
  String get walletRedeemButton => 'Redeem';

  @override
  String get walletScratchCardsTab => 'Scratch Cards';

  @override
  String get walletTransactionsTab => 'Transactions';

  @override
  String get walletNoTransactions => 'No transactions yet';

  @override
  String get walletTxnCredit => 'Reward credited';

  @override
  String get walletTxnReserveRedeem => 'Redeem requested';

  @override
  String get walletTxnConfirmPayout => 'Payout sent';

  @override
  String get walletTxnReleaseReserve => 'Redeem rejected — refunded';

  @override
  String get walletRedeemSheetTitle => 'Redeem to UPI';

  @override
  String walletRedeemAvailableLabel(String amount) {
    return 'Available: $amount';
  }

  @override
  String get walletUpiIdLabel => 'UPI ID';

  @override
  String get walletUpiIdHint => 'yourname@bank';

  @override
  String get walletUpiIdRequired => 'Enter a UPI ID';

  @override
  String get walletUpiIdInvalid => 'Enter a valid UPI ID, e.g. name@bank';

  @override
  String get walletConfirmRedeemButton => 'Confirm Redeem';

  @override
  String get walletRedeemSuccessMessage => 'Redeem request submitted';

  @override
  String get walletScratchCardsEmpty =>
      'No scratch cards yet — post a truck to earn one!';

  @override
  String get walletScratchCardScratchHint => 'Scratch Here';

  @override
  String get walletScratchCardNoReward => 'No reward';

  @override
  String get walletScratchCardExpired => 'Expired';

  @override
  String get scratchCardRevealButton => 'Reveal';

  @override
  String get postScratchCardTitle => 'You\'ve Earned a Scratch Card!';

  @override
  String get postScratchCardSubtitle =>
      'Scratch the card to reveal your reward';

  @override
  String get postScratchCardWonTitle => '🎉 You Won!';

  @override
  String get postScratchCardNoRewardTitle => 'Better Luck Next Time!';

  @override
  String get postScratchCardNoRewardSubtitle =>
      'Keep posting daily for more chances to win';

  @override
  String get postScratchCardContinueButton => 'Continue';

  @override
  String get walletKycRequiredMessage =>
      'Please complete your KYC to access the wallet and rewards';

  @override
  String get walletKycCompleteButton => 'Complete KYC';

  @override
  String get wheelPickerDoneButton => 'Done';

  @override
  String get postLengthLabel => 'Length';

  @override
  String get postHeightLabel => 'Height';

  @override
  String get postSelectLengthHint => 'Select length';

  @override
  String get postSelectHeightHint => 'Select height';

  @override
  String feetValue(num value) {
    return '$value ft';
  }

  @override
  String get reelCommentsTitle => 'Comments';

  @override
  String get reelCommentsEmpty => 'No comments yet. Be the first!';

  @override
  String get reelCommentHint => 'Add a comment…';

  @override
  String get reelCommentPost => 'Post';

  @override
  String get reelCommentDelete => 'Delete';

  @override
  String get reelFollow => 'Follow';

  @override
  String get reelFollowing => 'Following';

  @override
  String reelShareText(String title) {
    return '$title — watch this reel on Convoy';
  }

  @override
  String get reelCategoryAll => 'All';

  @override
  String get reelDetailsCategoriesLabel => 'Categories';

  @override
  String get reelDetailsCategoriesHint => 'Pick 1 to 5';

  @override
  String get reelDetailsCategoriesRequired => 'Pick at least one category';

  @override
  String get reelDetailsHashtagsLabel => 'Hashtags (optional)';

  @override
  String get reelDetailsHashtagsHint => '#trucklife #nightrun';

  @override
  String get reelDetailsHashtagsMax => 'You can add up to 10 hashtags';

  @override
  String get profileMyUploads => 'My Uploads';

  @override
  String get uploadsCreatorInsights => 'Creator Insights';

  @override
  String get uploadsNewPost => 'New Post';

  @override
  String get uploadsStatReels => 'Reels';

  @override
  String get uploadsStatTotalViews => 'Total Views';

  @override
  String get uploadsStatAppreciation => 'Appreciation';

  @override
  String uploadsThisWeek(int count) {
    return '+$count this wk';
  }

  @override
  String uploadsAllReelsTab(int count) {
    return 'All Reels ($count)';
  }

  @override
  String uploadsCategoryTab(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get uploadsEmpty => 'You haven\'t uploaded any reels yet';

  @override
  String get uploadsRecordCta => 'Upload Reel';

  @override
  String get uploadsMenuDelete => 'Delete';

  @override
  String get uploadsDeleteConfirmTitle => 'Delete this reel?';

  @override
  String get uploadsDeleteConfirmBody =>
      'This permanently removes the reel along with its likes and comments. This can\'t be undone.';

  @override
  String get uploadsDeleteSuccess => 'Reel deleted';

  @override
  String get uploadsReelNotPlayable => 'This reel can\'t be played yet';

  @override
  String get uploadsStatusProcessing => 'Processing';

  @override
  String get uploadsStatusRejected => 'Rejected';

  @override
  String get uploadsStatusFailed => 'Failed';

  @override
  String get uploadsPostedToday => 'Today';

  @override
  String get uploadsPostedYesterday => 'Yesterday';

  @override
  String uploadsPostedDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String uploadsPostedWeeksAgo(int weeks) {
    return '${weeks}w ago';
  }

  @override
  String uploadsPostedMonthsAgo(int months) {
    return '${months}mo ago';
  }

  @override
  String get navHeatmap => 'Heatmap';

  @override
  String get heatmapTitle => 'Activity Heatmap';

  @override
  String get heatmapTabTrucks => 'Trucks';

  @override
  String get heatmapTabReels => 'Reels';

  @override
  String get heatmapLoading => 'Loading heatmap…';

  @override
  String get heatmapErrorGeneric => 'Couldn\'t load the heatmap';

  @override
  String get heatmapEmptyTrucks => 'No live trucks to show yet';

  @override
  String get heatmapEmptyReels => 'No recent reels with a location yet';

  @override
  String get heatmapZoomOutHint => 'Zoom out to see more activity';

  @override
  String get heatmapLegendLow => 'Fewer';

  @override
  String get heatmapLegendHigh => 'More';

  @override
  String get heatmapMyLocation => 'My location';

  @override
  String heatmapCellTrucks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trucks in this area',
      one: '1 truck in this area',
    );
    return '$_temp0';
  }

  @override
  String heatmapCellReels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reels in this area',
      one: '1 reel in this area',
    );
    return '$_temp0';
  }

  @override
  String get heatmapNoTrucksInView => 'No trucks in this area right now';

  @override
  String get heatmapPinsTruncated =>
      'Showing the trucks closest to the centre — zoom in to see more';

  @override
  String get heatmapPinsModeHint => 'Individual trucks · tap a pin for details';

  @override
  String get heatmapPinLoading => 'Loading truck details…';

  @override
  String get heatmapPinUnavailable => 'This truck post is no longer available';

  @override
  String get heatmapPinDetailError => 'Couldn\'t load truck details';

  @override
  String get reelsAreaThisArea => 'This area';

  @override
  String get reelsAreaShowAll => 'Show all reels';

  @override
  String get reelsAreaEmpty => 'No reels in this area right now';

  @override
  String get walletTxnCallHold => 'Held for 1:1 call';

  @override
  String get walletTxnCallRelease => '1:1 call hold released';

  @override
  String get walletTxnCallDebit => 'Paid for 1:1 call';

  @override
  String get walletTxnCallEarning => '1:1 call earning';

  @override
  String get oneToOneSheetTitle => 'Request 1:1 Live Session';

  @override
  String get oneToOneSheetBadge => 'DIRECT CONNECT';

  @override
  String oneToOneSheetSubtitle(String name) {
    return 'Talk to $name on a private live call about freight, route details and booking.';
  }

  @override
  String get oneToOneDriverFallback => 'the driver';

  @override
  String get oneToOneHowTitle => 'The driver confirms first';

  @override
  String get oneToOneHowBody =>
      'The driver reviews your request, then calls you. You see and hear them and speak through your microphone.';

  @override
  String get oneToOneTopicLabel => 'Session discussion topic';

  @override
  String get oneToOneRequiredTag => 'Required';

  @override
  String get oneToOneTopicHint =>
      'e.g. Route status, load negotiation, dispatch schedule';

  @override
  String get oneToOneTopicRequired =>
      'Tell the driver what you want to discuss';

  @override
  String get oneToOneDurationLabel => 'Session duration';

  @override
  String oneToOneDurationMinutes(int minutes) {
    return '$minutes mins';
  }

  @override
  String get oneToOneDurationQuick => 'Quick chat';

  @override
  String get oneToOneDurationReview => 'Route review';

  @override
  String get oneToOneDurationDeep => 'Deep booking';

  @override
  String get oneToOneOfferLabel => 'Your offer';

  @override
  String get oneToOneOfferHint => 'Amount in ₹';

  @override
  String oneToOneOfferRange(String min, String max) {
    return 'Offer between $min and $max';
  }

  @override
  String oneToOneHoldExplainer(String hold, String amount) {
    return '$hold is frozen now as the cost of connecting. After the call you choose: pay the full $amount if you\'re satisfied, otherwise only $hold.';
  }

  @override
  String oneToOneWalletAvailable(String amount) {
    return 'Wallet: $amount available';
  }

  @override
  String oneToOneNeedMoney(String amount) {
    return 'Add $amount to your wallet to send this request';
  }

  @override
  String get oneToOneAddMoneyButton => 'Add money';

  @override
  String get oneToOneMoneyAdded => 'Test money added';

  @override
  String get oneToOneRechargeSoon => 'Wallet recharge is coming soon';

  @override
  String get oneToOneSendButton => 'Send request';

  @override
  String get oneToOneStatusTitle => 'Your 1:1 request';

  @override
  String oneToOneStatusPending(String name) {
    return 'Waiting for $name to respond';
  }

  @override
  String oneToOneStatusAccepted(String name) {
    return '$name accepted. They will call you shortly';
  }

  @override
  String oneToOneStatusRinging(String name) {
    return '$name is calling you…';
  }

  @override
  String oneToOneStatusLive(String name) {
    return 'On a call with $name';
  }

  @override
  String get oneToOneStatusAwaitingFeedback =>
      'Call finished. Tell us how it went to complete payment';

  @override
  String oneToOneStatusCompleted(String amount) {
    return 'Call completed. You paid $amount';
  }

  @override
  String oneToOneStatusRejected(String name) {
    return '$name can\'t take your call right now. Your money has been released';
  }

  @override
  String get oneToOneStatusExpired =>
      'No response in time. Your money has been released';

  @override
  String get oneToOneStatusCancelled =>
      'Request cancelled. Your money has been released';

  @override
  String get oneToOneStatusFailed =>
      'The call didn\'t connect. Nothing was charged';

  @override
  String oneToOneOfferSummary(String amount, int minutes) {
    return 'Offer $amount · $minutes min';
  }

  @override
  String oneToOneFrozenSummary(String hold) {
    return '$hold is frozen until the request ends';
  }

  @override
  String oneToOneExpiresIn(String time) {
    return 'Expires in $time';
  }

  @override
  String get oneToOneCancelButton => 'Cancel request';

  @override
  String get oneToOneDoneButton => 'Done';

  @override
  String get oneToOneStatusLoadError => 'Couldn\'t load your request';

  @override
  String get oneToOneBannerTitle => '1:1 Video Request Pending';

  @override
  String oneToOneBannerOffered(String amount) {
    return '$amount offered';
  }

  @override
  String oneToOneBannerMore(int count) {
    return '+$count more';
  }

  @override
  String get oneToOneBannerReview => 'Review';

  @override
  String get oneToOneRequesterFallback => 'the requester';

  @override
  String get oneToOneIncomingTitle => '1:1 video request';

  @override
  String oneToOneIncomingFrom(String name) {
    return '$name wants a live 1:1 call with you';
  }

  @override
  String get oneToOneIncomingTopicLabel => 'They want to discuss';

  @override
  String get oneToOneEarningsTitle => 'What you earn';

  @override
  String oneToOneEarningsBody(String hold, String amount, String name) {
    return 'At least $hold once the call has been connected for 30 seconds. The full $amount if $name is satisfied afterwards.';
  }

  @override
  String get oneToOneAcceptButton => 'Accept';

  @override
  String get oneToOneRejectButton => 'Reject';

  @override
  String get oneToOneRejectConfirmTitle => 'Reject this request?';

  @override
  String oneToOneRejectConfirmBody(String name) {
    return '$name\'s money is released and the request is closed.';
  }

  @override
  String get oneToOneKeepButton => 'Keep it';

  @override
  String oneToOneIncomingAccepted(String name) {
    return 'You accepted $name\'s request';
  }

  @override
  String get oneToOneIncomingRejected => 'You declined this request';

  @override
  String get oneToOneIncomingExpired => 'This request expired';

  @override
  String oneToOneIncomingCancelled(String name) {
    return '$name cancelled this request';
  }

  @override
  String oneToOneIncomingFeedback(String name) {
    return 'Call finished. Waiting for $name\'s feedback';
  }

  @override
  String oneToOneIncomingCompleted(String amount) {
    return 'Call completed. You earned $amount';
  }

  @override
  String get oneToOneBannerReadyTitle => '1:1 call ready to start';

  @override
  String get oneToOneBannerStart => 'Start';

  @override
  String get oneToOneStartCallButton => 'Start call';

  @override
  String oneToOneStartCallHint(String name) {
    return '$name\'s phone will ring for 45 seconds. Park safely before you start.';
  }

  @override
  String callRingingTitle(String name) {
    return 'Calling $name…';
  }

  @override
  String get callRingingHint => 'Their phone is ringing';

  @override
  String callWaitingForPeer(String name) {
    return 'Waiting for $name to join…';
  }

  @override
  String callPeerDropped(String name) {
    return '$name lost connection. Waiting for them to come back…';
  }

  @override
  String get callYouDropped => 'Your connection dropped. Reconnecting…';

  @override
  String get callServerUnreachable =>
      'Can\'t reach the server. The call goes on, but its time may not be counted.';

  @override
  String get callReconnectButton => 'Reconnect';

  @override
  String callTimeLeft(String time) {
    return '$time left';
  }

  @override
  String get callCounted => 'Counts as a call';

  @override
  String callCountsAfter(int seconds) {
    return 'Counts as a call after ${seconds}s together';
  }

  @override
  String get callEndButton => 'End';

  @override
  String get callCancelRingButton => 'Cancel';

  @override
  String get callEndConfirmTitle => 'End the call?';

  @override
  String callEndConfirmCounted(String name) {
    return 'This call has counted. $name will be asked how it went.';
  }

  @override
  String get callEndConfirmNotCounted =>
      'This call hasn\'t counted yet. If you end it now, nothing is charged.';

  @override
  String get callKeepGoing => 'Keep going';

  @override
  String get callMute => 'Mute';

  @override
  String get callUnmute => 'Unmute';

  @override
  String get callCameraOff => 'Camera off';

  @override
  String get callCameraOn => 'Camera on';

  @override
  String get callFlip => 'Flip';

  @override
  String get callSpeaker => 'Speaker';

  @override
  String get callChat => 'Chat';

  @override
  String callAudioOnlyNote(String name) {
    return 'Only your microphone is on. $name can\'t see you.';
  }

  @override
  String get callSafetyTitle => 'Don\'t use the phone while driving';

  @override
  String get callSafetyBody =>
      'Park safely before taking this call. Never look at the screen or type while the vehicle is moving.';

  @override
  String get callSafetyOk => 'I\'m parked';

  @override
  String get callChatTitle => 'Chat';

  @override
  String get callChatHint => 'Type a message';

  @override
  String get callChatEmpty => 'Messages only last for this call.';

  @override
  String get callChatSendFailed => 'Couldn\'t send. Check your connection.';

  @override
  String get callStarting => 'Starting the call…';

  @override
  String get callPermissionMic =>
      'Allow the microphone to take part in the call.';

  @override
  String get callPermissionCamera =>
      'Allow the camera so the other person can see you.';

  @override
  String get callOpenSettings => 'Open settings';

  @override
  String get callClose => 'Close';

  @override
  String get callEndedTitle => 'Call ended';

  @override
  String callEndedDriverCounted(
    String duration,
    String name,
    String callAmount,
    String offer,
  ) {
    return 'You were on the call for $duration. $name will now say if they were satisfied. You earn $callAmount for sure, and $offer if they are.';
  }

  @override
  String callEndedRequesterCounted(String name) {
    return 'Thanks for your call with $name.';
  }

  @override
  String callEndedTooShort(int seconds) {
    return 'The call was too short to count (under $seconds seconds). Nothing was charged.';
  }

  @override
  String callEndedUnanswered(String name) {
    return '$name didn\'t pick up. You can try again until the request expires.';
  }

  @override
  String callEndedDeclined(String name) {
    return '$name declined the call. The request is closed.';
  }

  @override
  String get callEndedUnconfirmed =>
      'You left the call. We couldn\'t reach the server, so it will be settled shortly.';

  @override
  String get callEndedOther => 'The call has ended.';

  @override
  String get callDoneButton => 'Done';

  @override
  String callIncomingTitle(String name) {
    return '$name is calling you';
  }

  @override
  String callIncomingOffer(String amount, int minutes) {
    return '$amount offered · $minutes min';
  }

  @override
  String callIncomingHint(String name) {
    return 'You\'ll hear $name and see their camera. Only your microphone is on.';
  }

  @override
  String get callAnswer => 'Answer';

  @override
  String get callDecline => 'Decline';

  @override
  String get callDeclineHint =>
      'Declining cancels your request and releases your money.';

  @override
  String callRingSeconds(int seconds) {
    return 'Ringing · ${seconds}s';
  }

  @override
  String callMissed(String name) {
    return 'You missed the call. $name can try again, or you can cancel your request.';
  }

  @override
  String get callRejoinTitle => 'You\'re still in a call';

  @override
  String callRejoinBody(String name) {
    return 'Your call with $name is still going. Rejoin to carry on.';
  }

  @override
  String get callRejoinButton => 'Rejoin';

  @override
  String get callRejoinEndButton => 'End call';

  @override
  String get callFeedbackTitle => 'Were you satisfied with the call?';

  @override
  String callFeedbackBody(String name) {
    return 'Your answer decides what $name is paid.';
  }

  @override
  String callFeedbackYes(String amount) {
    return 'Yes, pay $amount';
  }

  @override
  String callFeedbackNo(String amount) {
    return 'No, pay only $amount';
  }

  @override
  String callFeedbackNoNote(String amount) {
    return '$amount is the cost of connecting the call.';
  }

  @override
  String get callFeedbackLater => 'Decide later';

  @override
  String callFeedbackLaterNote(String amount) {
    return 'If you don\'t answer within 24 hours, only $amount is paid.';
  }

  @override
  String callFeedbackThanks(String amount) {
    return 'Thanks! You paid $amount.';
  }

  @override
  String get callDeclineFailed =>
      'Couldn\'t reach the server. Check your connection and try again.';

  @override
  String get callOngoingTitle => 'Call in progress';

  @override
  String callOngoingText(String name) {
    return 'Tap to return to your call with $name';
  }

  @override
  String get rechargeTitle => 'Add money to your wallet';

  @override
  String get rechargeAmountLabel => 'Amount to add (₹)';

  @override
  String rechargeRange(String min, String max) {
    return 'Between ₹$min and ₹$max at a time';
  }

  @override
  String rechargeInvalidAmount(String min, String max) {
    return 'Enter an amount between ₹$min and ₹$max';
  }

  @override
  String get rechargeAddedToWallet => 'Added to your wallet';

  @override
  String get rechargeGatewayFee => 'Payment gateway fee';

  @override
  String get rechargeYouPay => 'You pay';

  @override
  String rechargePayButton(String amount) {
    return 'Pay $amount';
  }

  @override
  String get rechargeUnavailable => 'Adding money isn\'t available right now';

  @override
  String get rechargeCreating => 'Getting your payment ready…';

  @override
  String get rechargePaying => 'Complete the payment in the payment window';

  @override
  String get rechargeConfirming => 'Confirming your payment…';

  @override
  String rechargeDone(String amount) {
    return '$amount added to your wallet';
  }

  @override
  String get rechargePending =>
      'We\'re still confirming your payment. Your balance will update shortly. You don\'t need to pay again.';

  @override
  String get rechargeFailedGeneric =>
      'The payment didn\'t go through. You haven\'t been charged.';

  @override
  String get rechargeClose => 'Close';
}
