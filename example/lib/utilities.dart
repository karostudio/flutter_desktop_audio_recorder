import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Utilities {
  static Future<String> getVoiceFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = appDocumentsPath; // 3

    return filePath;
  }
}
