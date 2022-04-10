import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_desktop_audio_recorder/flutter_desktop_audio_recorder.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_desktop_audio_recorder');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterDesktopAudioRecorder.platformVersion, '42');
  });
}
