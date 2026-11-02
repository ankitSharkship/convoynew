/// Rules for a paid 1:1 call offer. The server is the authority on all of
/// these (and re-checks them); the app mirrors them only so the form can
/// explain the money before anything is sent. Amounts are whole rupees in the
/// UI, handled in paise here to avoid floating-point drift.
const callMinAmountRupees = 50;
const callMaxAmountRupees = 10000;
const callDurationOptionsMinutes = [10, 15, 30];
const callQuickAmountsRupees = [50, 100, 200, 500];

/// Seconds a call must stay connected before the up-front hold is owed.
const callConnectThresholdSeconds = 30;

const _holdMinPaise = 2500; // ₹25

/// The "call amount": max(25% of the offer, ₹25), never more than the offer.
/// It is what is frozen when the request is sent and what the driver is owed
/// once the call connects, whatever the requester thinks of it afterwards.
int callHoldPaise(int amountRupees) {
  final paise = amountRupees * 100;
  final quarter = (paise * 25 + 50) ~/ 100; // 25%, rounded half up
  final hold = quarter < _holdMinPaise ? _holdMinPaise : quarter;
  return hold > paise ? paise : hold;
}

/// [callHoldPaise] as a "37.50" style string, ready for formatRupees.
String callHoldAmountText(int amountRupees) =>
    (callHoldPaise(amountRupees) / 100).toStringAsFixed(2);

bool isValidCallAmount(int amountRupees) =>
    amountRupees >= callMinAmountRupees && amountRupees <= callMaxAmountRupees;
