import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger_config.dart';
import '../source/storage_service.dart';

/// Implementation of [StorageService] using FlutterSecureStorage.
///
/// Provides encrypted secure storage for sensitive data like tokens and passwords.
class SecureStorageImpl implements StorageService {
  final FlutterSecureStorage _storage;

  SecureStorageImpl([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage() {
    StorageLogger.logInit('SecureStorage');
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      StorageLogger.logError(
        'Error reading key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      StorageLogger.logError(
        'Error writing key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> writeBool({required String key, required bool value}) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      StorageLogger.logError(
        'Error writing bool with key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> readBool({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      return value == 'true';
    } catch (e) {
      StorageLogger.logError(
        'Error reading bool with key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> writeInt({required String key, required int value}) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      StorageLogger.logError(
        'Error writing int with key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<int?> readInt({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) return null;
      return int.tryParse(value);
    } catch (e) {
      StorageLogger.logError(
        'Error reading int with key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> writeDouble({required String key, required double value}) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      StorageLogger.logError(
        'Error writing double with key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<double?> readDouble({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) return null;
      return double.tryParse(value);
    } catch (e) {
      StorageLogger.logError(
        'Error reading double with key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      StorageLogger.logError(
        'Error checking key existence: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      StorageLogger.logError(
        'Error deleting key: $key',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      StorageLogger.logError(
        'Error clearing storage',
        header: 'SecureStorage',
        error: e,
      );
      rethrow;
    }
  }
}
