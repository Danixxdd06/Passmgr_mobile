import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/config_model.dart';

class ConfigService {
  static const _fileName = 'config.json';

  static Future<String> _path() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_fileName';
  }

  static Future<ConfigModel> loadConfig() async {
    final p = await _path();
    final f = File(p);
    if (!await f.exists()) {
      return ConfigModel(masterPassword: '', theme: 'dark');
    }
    final jsonStr = await f.readAsString();
    return ConfigModel.fromJson(jsonDecode(jsonStr));
  }

  static Future<void> saveConfig(ConfigModel cfg) async {
    final p = await _path();
    final f = File(p);
    await f.writeAsString(jsonEncode(cfg.toJson()));
  }
}
