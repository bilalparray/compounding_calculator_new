import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setBool(String key, bool value) async {
    await _init();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _init();
    return _prefs!.getBool(key);
  }

  Future<void> setString(String key, String value) async {
    await _init();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _init();
    return _prefs!.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _init();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await _init();
    return _prefs!.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _init();
    await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _init();
    return _prefs!.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _init();
    await _prefs!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await _init();
    return _prefs!.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _init();
    await _prefs!.remove(key);
  }

  Future<void> clear() async {
    await _init();
    await _prefs!.clear();
  }

  Future<bool> containsKey(String key) async {
    await _init();
    return _prefs!.containsKey(key);
  }
}
