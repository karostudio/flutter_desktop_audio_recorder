import Cocoa
import FlutterMacOS
import AVFoundation

public class FlutterDesktopAudioRecorderPlugin: NSObject, FlutterPlugin {
    
    var recorder: Recording = Recording()
    var flutterResult: FlutterResult?
    
    let unknownError = FlutterError( code: "unknownError",
                                     message: "Unknown error",
                                     details: "")
    
    let permissionError = FlutterError( code: "permissionError",
                      message: "Missing mic permission",
                      details: "Mic permission isn't granted")
    
    let minimumVersionError = FlutterError( code: "minimumVersionError",
                      message: "Minimum macos target: 10.14",
                      details: "")
    
    let channel: FlutterMethodChannel
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_desktop_audio_recorder", binaryMessenger: registrar.messenger)
        
        let instance = FlutterDesktopAudioRecorderPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterResult = result
        recorder.flutterResult = result
        switch call.method {
        case "start_audio_record":
            handleStartAudioRecord(call, result: result)
        case "stop_audio_record":
            handleStopAudioRecord(call, result: result)
        case "request_mic_permission":
            handleRequestMicPermission(call, result: result)
        case "has_mic_permission":
            handleHasMicPermission(call, result: result)
        case "is_recording":
            handleIsRecording(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleIsRecording(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isrecording = recorder.isRecording()
        result(isrecording)
    }

    private func handleHasMicPermission(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let hasPermission = recorder.hasMicPermission()
        result(hasPermission)
    }
    
    private func handleRequestMicPermission(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            try recorder.requestMicPermission(
                permissionGranted: {
                    self.channel.invokeMethod("mic_permission_granted", arguments: nil)
                })
        } catch {
            result(minimumVersionError)
        }
    }
    
    private func handleStopAudioRecord(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        recorder.stop()
        result(nil)
    }
    
    private func handleStartAudioRecord(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("start_audio_record method called via methodchannel")
        guard let methodArgs = call.arguments,
              let myArgs = methodArgs as? [String: Any],
              let path = myArgs["path"] as? String else {
                  /// path argument is null
                  result(
                    FlutterError( code: "invalidArgs",
                                  message: "Missing arg path",
                                  details: "Expected 1 String arg." ))
                  return
              }
        do {
            try recorder.startRecordingIfPermissionGranted(path: path)
            result(nil)
        } catch let e {
            if let error = e as? Errors {
                self.handleCustomError(error: error)
            } else {
                result(unknownError)
            }
        }
    }
    
    func handleCustomError(error: Errors) {
        switch error {
        case Errors.permissionError:
            flutterResult?(permissionError)
        case Errors.minimumVersion:
            flutterResult?(minimumVersionError)
        default:
            flutterResult?(unknownError)
        }
    }
}
