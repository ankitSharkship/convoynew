/// Where the iPhone's VoIP push token (the one that lets a call wake a closed
/// phone) comes from. Only iPhones have one; everything else answers "none".
abstract class VoipTokenSource {
  /// The current token, or null (not an iPhone, or iOS has not handed one out yet).
  Future<String?> currentVoipToken();

  /// Fires when iOS gives out a new token (first launch, reinstall, rotation).
  Stream<String> get voipTokenChanges;

  /// True when this build's tokens belong to Apple's sandbox push server
  /// (builds installed from Xcode), false for production ones (TestFlight and
  /// the App Store). Each token must be sent to its own server.
  Future<bool> isVoipSandbox();
}

/// For platforms and tests without VoIP push.
class NoVoipTokenSource implements VoipTokenSource {
  const NoVoipTokenSource();

  @override
  Future<String?> currentVoipToken() async => null;

  @override
  Stream<String> get voipTokenChanges => const Stream.empty();

  @override
  Future<bool> isVoipSandbox() async => false;
}
