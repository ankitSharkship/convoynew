/// Features that are built but switched off for now. Flip to `true` to bring
/// them back — each flag gates every entry point (routes, nav items, API calls).
class FeatureFlags {
  /// Wallet tab/screen (balance, transactions, redeem).
  static const bool walletEnabled = false;

  /// Daily scratch-card reward after posting a truck.
  static const bool scratchCardsEnabled = false;

  /// Paid 1:1 live calls: the "Request 1:1" form on a truck's details sheet,
  /// the request status sheet, and the driver's incoming-request banner. Needs
  /// the backend's /api/call-requests endpoints (docs/ONE_TO_ONE_CALL_API.md).
  static const bool oneToOneEnabled = true;

  /// Adding real money to the wallet through Razorpay: an "Add money" button on
  /// the wallet card and in the 1:1 request form's "you need ₹X more" notice.
  /// Needs the backend's /api/wallet/.../recharges endpoints and Razorpay keys
  /// (my_task.md, Stage 7). Takes the place of the dev credit below.
  static const bool rechargeEnabled = false;

  /// DEV ONLY: shows an "Add money" button in the 1:1 request form that calls
  /// POST /api/wallet/{id}/dev-credit (test money; the server must run with
  /// DEV_WALLET_CREDIT_ENABLED=true). Ignored when [rechargeEnabled] is on.
  /// Never ship this as true against the production database.
  static const bool devWalletCreditEnabled = true;
}
