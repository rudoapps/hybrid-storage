import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger_config.dart';
import '../source/local_db_service.dart';

/// Implementation of [LocalDbService] using Hive.
///
/// Provides local database storage for complex objects and entities.
/// Supports generic types and organizes data in named boxes.
class HiveStorageImpl implements LocalDbService {
  final Map<String, Box> _boxes = {};

  HiveStorageImpl() {
    StorageLogger.logInit('HiveStorage');
  }

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      StorageLogger.logInit('HiveStorage - Flutter initialized');
    } catch (e) {
      StorageLogger.logError(
        'Error initializing Hive',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> openBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      return;
    }

    try {
      _boxes[boxName] = await Hive.openBox(boxName);
    } catch (e) {
      StorageLogger.logError(
        'Error opening box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> put<T>(
      {required String boxName, required String key, required T value}) async {
    try {
      await openBox(boxName);
      await _boxes[boxName]?.put(key, value);
    } catch (e) {
      StorageLogger.logError(
        'Error putting value with key: $key in box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<T?> get<T>({required String boxName, required String key}) async {
    try {
      await openBox(boxName);
      return _boxes[boxName]?.get(key) as T?;
    } catch (e) {
      StorageLogger.logError(
        'Error getting value with key: $key from box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<T>> getAll<T>({required String boxName}) async {
    try {
      await openBox(boxName);
      return _boxes[boxName]?.values.whereType<T>().toList() ?? [];
    } catch (e) {
      StorageLogger.logError(
        'Error getting all values from box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    try {
      await openBox(boxName);
      await _boxes[boxName]?.delete(key);
    } catch (e) {
      StorageLogger.logError(
        'Error deleting key: $key from box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> clear({required String boxName}) async {
    try {
      await openBox(boxName);
      await _boxes[boxName]?.clear();
    } catch (e) {
      StorageLogger.logError(
        'Error clearing box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> containsKey(
      {required String boxName, required String key}) async {
    try {
      await openBox(boxName);
      return _boxes[boxName]?.containsKey(key) ?? false;
    } catch (e) {
      StorageLogger.logError(
        'Error checking key existence: $key in box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }
}
