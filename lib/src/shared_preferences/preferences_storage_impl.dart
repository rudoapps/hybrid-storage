import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger_config.dart';
import '../source/storage_service.dart';

/// Implementation of [StorageService] using SharedPreferences.
///
/// Provides persistent but unencrypted storage for app preferences and settings.
class PreferencesStorageImpl implements StorageService {
  SharedPreferences? _preferences;
  final SharedPreferences? _injectedPreferences;

  PreferencesStorageImpl([this._injectedPreferences]) {
    if (_injectedPreferences != null) {
      _preferences = _injectedPreferences;
      StorageLogger.logInit('PreferencesStorage');
    }
  }

  /// Initializes SharedPreferences.
  ///
  /// Must be called before using other methods if an instance was not provided in the constructor.
  Future<void> init() async {
    if (_preferences != null) {
      return;
    }

    try {
      _preferences = await SharedPreferences.getInstance();
      StorageLogger.logInit('PreferencesStorage');
    } catch (e) {
      StorageLogger.logError(
        'Error initializing SharedPreferences',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  SharedPreferences get _prefs {
    if (_preferences == null) {
      final error = 'SharedPreferences not initialized. Call init() first.';
      StorageLogger.logError(error, header: 'PreferencesStorage');
      throw StateError(error);
    }
    return _preferences!;
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      StorageLogger.logError(
        'Error reading key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      StorageLogger.logError(
        'Error writing key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> readBool({required String key}) async {
    try {
      return _prefs.getBool(key) ?? false;
    } catch (e) {
      StorageLogger.logError(
        'Error reading bool with key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> writeBool({required String key, required bool value}) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      StorageLogger.logError(
        'Error writing bool with key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<int?> readInt({required String key}) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      StorageLogger.logError(
        'Error reading int with key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> writeInt({required String key, required int value}) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      StorageLogger.logError(
        'Error writing int with key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<double?> readDouble({required String key}) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      StorageLogger.logError(
        'Error reading double with key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> writeDouble({required String key, required double value}) async {
    try {
      await _prefs.setDouble(key, value);
    } catch (e) {
      StorageLogger.logError(
        'Error writing double with key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      StorageLogger.logError(
        'Error checking key existence: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      StorageLogger.logError(
        'Error deleting key: $key',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      StorageLogger.logError(
        'Error clearing storage',
        header: 'PreferencesStorage',
        error: e,
      );
      rethrow;
    }
  }
}
