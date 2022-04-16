#include "include/flutter_desktop_audio_recorder/flutter_desktop_audio_recorder_plugin.h"
#include "voiceRecording.h"
#include <mmsystem.h>


// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <map>
#include <memory>
#include <sstream>
#include <string>

using namespace N;

namespace {
  VoiceRecording recorder;

class FlutterDesktopAudioRecorderPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterDesktopAudioRecorderPlugin();

  virtual ~FlutterDesktopAudioRecorderPlugin();

 private:

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void FlutterDesktopAudioRecorderPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_desktop_audio_recorder",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterDesktopAudioRecorderPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterDesktopAudioRecorderPlugin::FlutterDesktopAudioRecorderPlugin() {}

FlutterDesktopAudioRecorderPlugin::~FlutterDesktopAudioRecorderPlugin() {}

void FlutterDesktopAudioRecorderPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    
    if (method_call.method_name().compare("start_audio_record") == 0) {
      auto name_it = arguments->find(flutter::EncodableValue("fileName"));
      if (name_it != arguments->end())
      {
        std::string fileName = std::get<std::string>(name_it->second);
        result->Success(flutter:: EncodableValue(recorder.startRecording(fileName)));
      }
      result->Error("Error while parsing path");
    }
    else if (method_call.method_name().compare("stop_audio_record") == 0) {
      recorder.stopRecording();
      result-> Success(recorder._fileName);
    }
    else  if (method_call.method_name().compare("is_recording") == 0) {
      result->Success(flutter:: EncodableValue(recorder.isRecording));
    }
    else if (method_call.method_name().compare("has_mic_permission") == 0) {
      result->Success(flutter:: EncodableValue(true));
    } else {
      result->NotImplemented();
    }
}

}  // namespace

void FlutterDesktopAudioRecorderPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  FlutterDesktopAudioRecorderPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
