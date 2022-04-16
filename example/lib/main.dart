import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_desktop_audio_recorder/flutter_desktop_audio_recorder.dart';
import 'package:flutter_desktop_audio_recorder_example/utilities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasMicPermission = false;
  FlutterDesktopAudioRecorder recorder = FlutterDesktopAudioRecorder();
  String _fileName = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    recorder.permissionGrantedListener = () {
      if (!mounted) return;
      setState(() {
        _hasMicPermission = true;
      });
    };
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _hasMicPermission = await recorder.hasMicPermission();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Desktop Audio Recorder Example"),
        ),
        body: FutureBuilder<bool>(
            future: recorder.isRecording(),
            builder: (context, snapshot) {
              bool? isRecording = snapshot.data;
              return Center(
                child: Column(
                  children: [
                    startRecordingButton(snapshot, isRecording),
                    const SizedBox(
                      height: 48,
                    ),
                    Text((isRecording ?? false)
                        ? "Audio is recording"
                        : _fileName.isEmpty
                            ? ""
                            : "File Name: $_fileName.wav"),
                    Text(_hasMicPermission
                        ? "Permission Is Granted"
                        : "Permission Is Not Granted")
                  ],
                ),
              );
            }),
      ),
    );
  }

  TextButton startRecordingButton(
      AsyncSnapshot<bool> snapshot, bool? isRecording) {
    return TextButton(
        onPressed: () async {
          if (snapshot.data != null) {
            if (snapshot.data!) {
              await stopRecording();
              setState(() {});
            } else {
              startRecording().then((value) {
                recorder.isRecording().then((value) {
                  if (kDebugMode) {
                    print(value);
                  }
                });
                setState(() {});
              });
              setState(() {});
            }
          }
        },
        child: Text(isRecording == null
            ? "Initializing"
            : !_hasMicPermission
                ? "Request Mic Permission"
                : isRecording
                    ? "Stop"
                    : "Record"));
  }

  Future stopRecording() async {
    return recorder.stop();
  }

  Future startRecording() async {
    _fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String path = await Utilities.getVoiceFilePath();
    try {
      return await recorder.start(path: path, fileName: _fileName);
    } on PlatformException catch (e) {
      switch (e.code) {
        case "permissionError":
          recorder.requestMicPermission();
          break;
        default:
      }
      log(e.message ?? "Unhandled error");
    }
  }
}
