import 'package:convoynew/features/call_request/domain/call_amounts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // These must give the same numbers as the backend's compute_hold
  // (tests/test_call_hold.py): the form explains the money before the server
  // does the maths for real.
  group('callHoldAmountText (max(25%, ₹25), never above the offer)', () {
    const expected = {
      50: '25.00', // 25% = 12.50, the ₹25 floor wins
      100: '25.00',
      101: '25.25',
      150: '37.50',
      200: '50.00',
      1000: '250.00',
      10000: '2500.00',
    };
    expected.forEach((amount, hold) {
      test('₹$amount freezes ₹$hold', () {
        expect(callHoldAmountText(amount), hold);
      });
    });

    test('never freezes more than the offer', () {
      expect(callHoldPaise(20), 2000);
    });
  });

  group('isValidCallAmount', () {
    test('accepts the limits', () {
      expect(isValidCallAmount(callMinAmountRupees), isTrue);
      expect(isValidCallAmount(callMaxAmountRupees), isTrue);
    });

    test('rejects outside the limits', () {
      expect(isValidCallAmount(callMinAmountRupees - 1), isFalse);
      expect(isValidCallAmount(callMaxAmountRupees + 1), isFalse);
      expect(isValidCallAmount(0), isFalse);
    });
  });

  test('the offered durations and quick amounts are valid', () {
    expect(callDurationOptionsMinutes, [10, 15, 30]);
    expect(callQuickAmountsRupees.every(isValidCallAmount), isTrue);
  });
}
