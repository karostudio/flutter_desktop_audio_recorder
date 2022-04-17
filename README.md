# flutter_desktop_audio_recorder

This is a Flutter package allowing you to record audio for:
* macOS
* windows

## Output file type
* macOS: .m4a
* windows: .wav

## Usage
```javascript

  FlutterDesktopAudioRecorder recorder = FlutterDesktopAudioRecorder();

  @override
  void initState() {
    super.initState();
    
    _hasMicPermission = await recorder.hasMicPermission();
    
    recorder.permissionGrantedListener = () {
      if (!mounted) return;
      setState(() {
        _hasMicPermission = true;
      });
    };
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
  
  Future stopRecording() async {
    return recorder.stop();
  }
  
  Future isRecording() async {
    return recorder.isRecording();
  }
```

## macOS Permission 
    1. Add usage description to plist 
    ```
    <key>NSMicrophoneUsageDescription</key>
    <string>Can We Use Your Microphone Please</string>
    ```

