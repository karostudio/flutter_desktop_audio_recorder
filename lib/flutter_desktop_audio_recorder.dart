
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterDesktopAudioRecorder {
  static const MethodChannel _channel = MethodChannel('flutter_desktop_audio_recorder');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
