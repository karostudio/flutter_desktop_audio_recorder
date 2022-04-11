import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterDesktopAudioRecorder {
  final MethodChannel _channel =
      MethodChannel('flutter_desktop_audio_recorder');
  Function? permissionGrantedListener;

  FlutterDesktopAudioRecorder() {
    _channel.setMethodCallHandler(_didRecieveTranscript);
  }

  Future<dynamic> _didRecieveTranscript(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    final String? utterance = call.arguments;
    switch (call.method) {
      case "mic_permission_granted":
        if (permissionGrantedListener != null) {
          permissionGrantedListener!();
        }
    }
  }

  Future<void> start({required String path, required String fileName}) async {
    String fullPath = "$path/$fileName";
    var aruments = <String, dynamic>{"path": fullPath};
    if (await Directory(path).exists()) {
      return _channel.invokeMethod('start_audio_record', aruments);
    }
    log("Audio recorder error: Path does not exist");
    return;
  }

  Future<bool> isRecording() async {
    return await _channel.invokeMethod('is_recording');
  }

  void stop() async {
    await _channel.invokeMethod('stop_audio_record');
  }

  void requestMicPermission() async {
    await _channel.invokeMethod('request_mic_permission');
  }

  Future<bool> hasMicPermission() async {
    return await _channel.invokeMethod('has_mic_permission');
  }
}
