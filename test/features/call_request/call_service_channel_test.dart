import 'package:convoynew/features/call_request/presentation/call/call_foreground_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel(AndroidCallForegroundService.channelName);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  Object? failWith;

  setUp(() {
    calls.clear();
    failWith = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          if (failWith != null) throw failWith!;
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('start passes the notification text and whether the camera is needed', () async {
    await AndroidCallForegroundService().start(
      title: 'Call in progress',
      text: 'Tap to return',
      withCamera: true,
    );
    expect(calls.single.method, 'start');
    expect(calls.single.arguments, {
      'title': 'Call in progress',
      'text': 'Tap to return',
      'video': true,
    });
  });

  test('stop asks the native side to stop', () async {
    await AndroidCallForegroundService().stop();
    expect(calls.single.method, 'stop');
  });

  test('a native refusal never breaks the call (it just will not survive the background)', () async {
    failWith = PlatformException(code: 'start_failed', message: 'not allowed');
    await AndroidCallForegroundService().start(title: 't', text: 'x', withCamera: false);
    await AndroidCallForegroundService().stop();
    expect(calls, hasLength(2));
  });

  test('with no native side at all it quietly does nothing', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    await AndroidCallForegroundService().start(title: 't', text: 'x', withCamera: false);
    await const NoCallForegroundService().start(title: 't', text: 'x', withCamera: false);
    await const NoCallForegroundService().stop();
  });
}
