import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterDesktopAudioRecorder {
  final MethodChannel _channel =
      MethodChannel('flutter_desktop_audio_recorder');
  Function? permissionGrantedListener;
  String macosFileExtension = "m4a";
  String windowsFileExtension = "wav";

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

  /// fileName without extension
  Future<void> start({required String path, required String fileName}) async {
    String fileExtension = Platform.isMacOS
        ? macosFileExtension
        : Platform.isWindows
            ? windowsFileExtension
            : "";
    String fileNameWithExtension = "$fileName.$fileExtension";
    String fullPath = "$path/$fileNameWithExtension";
    log("recording started with path: $fullPath");

    var aruments = <String, dynamic>{
      "path": fullPath,
      "fileName": fileNameWithExtension
    };
    if (await Directory(path).exists()) {
      bool? started =
          await _channel.invokeMethod('start_audio_record', aruments) ?? false;
      log("recording started: $started");
      return;
    }
    log("Audio recorder error: Path does not exist");
    return;
  }

  Future<bool> isRecording() async {
    bool isRecording = await _channel.invokeMethod('is_recording');
    print("isRecording: $isRecording");
    return isRecording;
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
