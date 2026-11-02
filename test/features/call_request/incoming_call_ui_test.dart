import 'package:convoynew/features/call_request/incoming_call/incoming_call_ui.dart';
import 'package:convoynew/features/call_request/incoming_call/ios_callkit_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel(IosCallKitUi.channelName);
const _codec = StandardMethodCodec();

/// Plays the native side: answers what Dart asks and can push events to it.
class FakeNative {
  final List<MethodCall> calls = [];
  final Map<String, Object?> answers = {};
  Object? errorFor;

  FakeNative() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          if (errorFor == call.method) {
            throw PlatformException(code: 'boom');
          }
          return answers[call.method];
        });
  }

  Future<void> send(String method, Object? args) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          IosCallKitUi.channelName,
          _codec.encodeMethodCall(MethodCall(method, args)),
          (_) {},
        );
  }

  List<String> get methods => calls.map((c) => c.method).toList();

  void dispose() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    _channel.setMethodCallHandler(null);
  }
}

Future<void> tick() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IncomingCallInfo.fromPushData', () {
    final data = {
      'type': 'call_incoming',
      'requestId': '9b2f0c3e-1111-4a4a-8888-0123456789ab',
      'callerName': 'Vikram',
      'topic': 'Route status',
      'ringEndsAt': '2029-01-01T12:00:45+00:00',
    };

    test('reads what the backend sends', () {
      final info = IncomingCallInfo.fromPushData(data)!;
      expect(info.requestId, '9b2f0c3e-1111-4a4a-8888-0123456789ab');
      expect(info.callerName, 'Vikram');
      expect(info.topic, 'Route status');
      expect(info.ringEndsAt, DateTime.utc(2029, 1, 1, 12, 0, 45));
    });

    test('a push that is not a call, or is broken, is not usable', () {
      expect(IncomingCallInfo.fromPushData({...data, 'type': 'call_cancelled'}), isNull);
      expect(IncomingCallInfo.fromPushData({...data, 'requestId': ''}), isNull);
      expect(IncomingCallInfo.fromPushData({...data}..remove('requestId')), isNull);
      expect(IncomingCallInfo.fromPushData({...data, 'ringEndsAt': 'soon'}), isNull);
      expect(IncomingCallInfo.fromPushData({...data}..remove('ringEndsAt')), isNull);
    });

    test('a missing name or topic never breaks the call screen', () {
      final info = IncomingCallInfo.fromPushData({...data}..remove('callerName')..remove('topic'))!;
      expect(info.callerName, 'Incoming call');
      expect(info.topic, '');
      expect(IncomingCallInfo.fromPushData({...data, 'callerName': '   '})!.callerName, 'Incoming call');
    });

    test('remaining time counts down and never goes negative', () {
      final info = IncomingCallInfo.fromPushData(data)!;
      expect(info.remaining(DateTime.utc(2029, 1, 1, 12)), const Duration(seconds: 45));
      expect(info.remaining(DateTime.utc(2029, 1, 1, 12, 0, 40)), const Duration(seconds: 5));
      expect(info.remaining(DateTime.utc(2029, 1, 1, 13)), Duration.zero);
    });
  });

  group('IosCallKitUi (the Dart end of the native CallKit layer)', () {
    late FakeNative native;
    late IosCallKitUi ui;

    setUp(() {
      native = FakeNative();
      ui = IosCallKitUi();
    });
    tearDown(() => native.dispose());

    test('attaching tells the native side to hand over what it queued', () async {
      await ui.prepare();
      expect(native.methods, ['attach']);
      await ui.prepare(); // twice is harmless
      expect(native.methods, ['attach']);
    });

    test('what the person does with the call arrives as events', () async {
      final seen = <IncomingCallEvent>[];
      final sub = ui.events.listen(seen.add);
      await tick();
      for (final type in ['shown', 'accepted', 'declined', 'ended', 'timedOut']) {
        await native.send('event', {'type': type, 'requestId': 'r1'});
      }
      expect(seen.map((e) => e.type), IncomingCallEventType.values);
      expect(seen.every((e) => e.requestId == 'r1'), isTrue);
      await sub.cancel();
    });

    test('an event it does not understand is ignored, not a crash', () async {
      final seen = <IncomingCallEvent>[];
      final sub = ui.events.listen(seen.add);
      await tick();
      await native.send('event', {'type': 'teleported', 'requestId': 'r1'});
      await native.send('event', {'type': 'accepted'});
      await native.send('event', {'type': 'accepted', 'requestId': ''});
      await native.send('event', 'garbage');
      await native.send('somethingElse', null);
      expect(seen, isEmpty);
      await sub.cancel();
    });

    test('VoIP tokens arrive as they are issued', () async {
      final tokens = <String>[];
      final sub = ui.voipTokenChanges.listen(tokens.add);
      await tick();
      await native.send('voipToken', 'abc123');
      await native.send('voipToken', '');
      await native.send('voipToken', 'def456');
      expect(tokens, ['abc123', 'def456']);
      await sub.cancel();
    });

    test('the current VoIP token is asked of the native side; empty means none', () async {
      native.answers['voipToken'] = 'abc123';
      expect(await ui.currentVoipToken(), 'abc123');
      native.answers['voipToken'] = '';
      expect(await ui.currentVoipToken(), isNull);
      native.answers['voipToken'] = null;
      expect(await ui.currentVoipToken(), isNull);
      native.errorFor = 'voipToken';
      expect(await ui.currentVoipToken(), isNull, reason: 'a native error is "no token"');
    });

    test('the push environment comes from the app\'s provisioning profile', () async {
      native.answers['pushEnvironment'] = 'sandbox';
      expect(await ui.isVoipSandbox(), isTrue);
      native.answers['pushEnvironment'] = 'production';
      expect(await ui.isVoipSandbox(), isFalse);
    });

    test('if the native side cannot say, tests (not a release build) count as sandbox', () async {
      native.answers['pushEnvironment'] = 'who knows';
      expect(await ui.isVoipSandbox(), isTrue);
      native.errorFor = 'pushEnvironment';
      expect(await ui.isVoipSandbox(), isTrue);
    });

    test('show / end / connected pass the request id along', () async {
      await ui.show(
        IncomingCallInfo(
          requestId: 'r1',
          callerName: 'Vikram',
          topic: 'Route',
          ringEndsAt: DateTime.utc(2029, 1, 1),
        ),
      );
      await ui.end('r1');
      await ui.setConnected('r1');

      expect(native.methods, ['show', 'end', 'connected']);
      expect(native.calls[0].arguments, {
        'requestId': 'r1',
        'callerName': 'Vikram',
        'topic': 'Route',
        'ringEndsAtMs': DateTime.utc(2029, 1, 1).millisecondsSinceEpoch,
      });
      expect(native.calls[1].arguments, {'requestId': 'r1'});
    });

    test('a failing native call is swallowed: a call screen problem must never crash the app', () async {
      native.errorFor = 'end';
      await ui.end('r1'); // does not throw
      expect(ui.showsWhileAppIsOpen, isTrue);
    });

    test('with no native side at all (not the real app) everything quietly does nothing', () async {
      native.dispose();
      final bare = IosCallKitUi();
      await bare.prepare();
      await bare.end('r1');
      expect(await bare.currentVoipToken(), isNull);
      expect(await bare.acceptedWhileAway(), isEmpty);
    });
  });
}
