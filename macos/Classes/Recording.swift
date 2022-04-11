 import AVFoundation
 import QuartzCore
 import FlutterMacOS

enum Errors: Error {
    case permissionError
    case minimumVersion
    case unknownError
}

 public class Recording : NSObject, AVAudioRecorderDelegate {
    
     var flutterResult: FlutterResult?
     public private(set) var url: NSURL?
    
     public var bitRate = 192000
     public var sampleRate = 44100.0
     public var channels = 1
    
     private var recorder: AVAudioRecorder?
     //    private var player: AVAudioPlayer?
    
     // MARK: - Initializers
     public func startRecordingIfPermissionGranted(path: String)throws {
         do {
             if( hasMicPermission()) {
                 try record(path: path)
             } else {
                 throw Errors.permissionError
             }
             
         } catch let e as Errors {
             throw(e)
         }
     }
     
     func isRecording()-> Bool {
         return recorder?.isRecording ?? false
     }
    
     public func hasMicPermission() -> Bool {
         if #available(macOS 10.14, *) {
             switch AVCaptureDevice.authorizationStatus(for: .audio) {
             case .authorized: // The user has previously granted access to the camera.
                 // proceed with recording
                 return true
                
             case .notDetermined: // The user has not yet been asked for camera access.
                 break
                
             case .denied: // The user has previously denied access.
                 print("audio permission denied")
                 break
                
             case .restricted: // The user can't grant access due to restrictions.
                 break
                
             @unknown default:
                 fatalError()
             }
         } else {
             // Fallback on earlier versions
             print("Wrong minimum target")
             return false;
         }
         return false
     }
     
     func requestMicPermission(permissionGranted: @escaping ()-> Void) throws {
         if #available(macOS 10.14, *) {
             AVCaptureDevice.requestAccess(for: .audio) { granted in
                 if granted {
                     permissionGranted()
                 }
             }
         } else {
             // Fallback on earlier versions
             throw(Errors.minimumVersion)
         }
     }
     
     public func record(path: String) throws {
         url = NSURL(fileURLWithPath: path)
         do {
             try prepare()
             recorder?.record()
         } catch {
             throw(Errors.unknownError)
         }
     }
    
     // MARK: - Record
     private func prepare() throws {
         let settings: [String: AnyObject] = [
             AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
             // Change below to any quality your app requires
             AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue as AnyObject,
             AVEncoderBitRateKey: bitRate as AnyObject,
             AVNumberOfChannelsKey: channels as AnyObject,
             AVSampleRateKey: sampleRate as AnyObject
         ]
        
         do {
             recorder = try AVAudioRecorder(url: url! as URL, settings: settings)
             recorder?.delegate = self
             recorder?.prepareToRecord()
         } catch {
             throw(Errors.unknownError)
         }
     }
    
     // MARK: - Playback
     //    public func play() {
     //        do {
     //            player = try AVAudioPlayer(contentsOf: url as URL)
     //            player?.volume = 1.0
     //            player?.play()
     //            state = .Play
     //            print("played successfully")
     //        }
     //        catch {
     //            print("failed to play")
     //        }
     //    }
    
     public func stop() {
         recorder?.stop()
         recorder = nil
     }
    
     // MARK: - Delegates
     public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
         print("audioRecorderFinishedRecording")
     }
    
     public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
         print("audioRecorderEncodeErrorDidOccur \(String(describing: error?.localizedDescription))")
         flutterResult?(FlutterError( code: "unknownError",
                                     message: "Unknown error",
                                     details: "" ))
     }
 }
