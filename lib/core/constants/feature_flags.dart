/// Features that are built but switched off for now. Flip to `true` to bring
/// them back — each flag gates every entry point (routes, nav items, API calls).
class FeatureFlags {
  /// Wallet tab/screen (balance, transactions, redeem).
  static const bool walletEnabled = false;

  /// Daily scratch-card reward after posting a truck.
  static const bool scratchCardsEnabled = false;
}
