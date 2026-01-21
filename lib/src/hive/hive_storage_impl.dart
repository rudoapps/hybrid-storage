import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger_config.dart';
import '../source/hive_service.dart';

/// Implementation of [HiveService] using Hive.
///
/// Provides local database storage for complex objects and entities.
/// Supports generic types and organizes data in named boxes.
class HiveStorageImpl implements HiveService {
  Map<String, Box>? _boxes;
  final Map<String, Box>? _injectedBoxes;

  HiveStorageImpl([this._injectedBoxes]) {
    if (_injectedBoxes != null) {
      _boxes = _injectedBoxes;
      StorageLogger.logInit('HiveStorage');
    }
  }

  @override
  Future<void> init() async {
    if (_boxes != null) return; // Already initialized with injected boxes

    try {
      await Hive.initFlutter();
      _boxes = {}; // Initialize empty map
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

  Map<String, Box> get _boxMap {
    if (_boxes == null) {
      final error = 'HiveStorage not initialized. Call init() first.';
      StorageLogger.logError(error, header: 'HiveStorage');
      throw StateError(error);
    }
    return _boxes!;
  }

  @override
  Future<void> openBox(String boxName) async {
    if (_boxMap.containsKey(boxName)) return;

    try {
      _boxMap[boxName] = await Hive.openBox(boxName);
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
      await _boxMap[boxName]?.put(key, value);
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
      return _boxMap[boxName]?.get(key) as T?;
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
      return _boxMap[boxName]?.values.whereType<T>().toList() ?? [];
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
      await _boxMap[boxName]?.delete(key);
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
      await _boxMap[boxName]?.clear();
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
      return _boxMap[boxName]?.containsKey(key) ?? false;
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
