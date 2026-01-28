import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger_config.dart';
import '../source/hive_service.dart';

/// Implementation of [HiveService] using Hive.
///
/// Provides local database storage for complex objects and entities.
/// Supports generic types and organizes data in named boxes.
class HiveStorageImpl implements HiveService {
  Map<String, Box>? _boxes;
  final Map<String, Box>? _injectedBoxes;

  static const String defaultBoxName = 'app_data';

  HiveStorageImpl([this._injectedBoxes]) {
    if (_injectedBoxes != null) {
      _boxes = _injectedBoxes;
      StorageLogger.logInit('HiveStorage');
    }
  }

  @override
  Future<void> init() async {
    if (_boxes != null) return; // Already initialized with injected boxes

    if (kIsWeb) {
      StorageLogger.logError(
        'HiveStorageImpl is not supported on web platforms. Use PreferencesStorageImpl or SecureStorageImpl instead.',
        header: 'HiveStorage',
      );
    }

    try {
      await Hive.initFlutter();
      _boxes = {}; // Initialize empty map

      // Open default box
      await openBox(boxName: defaultBoxName);

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

  /// Checks if a box exists on disk without opening it.
  /// Returns true if the box exists, false otherwise.
  Future<bool> _boxExists({required String boxName}) async {
    final allBoxes = await getAllBoxes();
    return allBoxes.contains(boxName);
  }

  /// Ensures the box is open and ready to use.
  /// If the box is closed, removes it from the map and reopens it.
  Future<void> _ensureBoxIsOpen({required String boxName}) async {
    await openBox(boxName: boxName);

    final box = _boxMap[boxName];
    if (box == null || !box.isOpen) {
      _boxMap.remove(boxName);
      await openBox(boxName: boxName);
    }
  }

  @override
  Future<void> openBox({required String boxName}) async {
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
      {String? boxName, required String key, required T value}) async {
    try {
      final box = boxName ?? defaultBoxName;
      await _ensureBoxIsOpen(boxName: box);
      await _boxMap[box]?.put(key, value);
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
  Future<T?> get<T>({String? boxName, required String key}) async {
    try {
      final box = boxName ?? defaultBoxName;

      // Check if box exists before opening to avoid creating empty boxes
      if (!await _boxExists(boxName: box)) {
        return null; // Return null if box doesn't exist
      }

      await _ensureBoxIsOpen(boxName: box);
      return _boxMap[box]?.get(key) as T?;
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
  Future<List<T>> getAll<T>({String? boxName}) async {
    try {
      final box = boxName ?? defaultBoxName;

      // Check if box exists before opening to avoid creating empty boxes
      if (!await _boxExists(boxName: box)) {
        return []; // Return empty list if box doesn't exist
      }

      await _ensureBoxIsOpen(boxName: box);
      return _boxMap[box]?.values.whereType<T>().toList() ?? [];
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
  Future<void> delete({String? boxName, required String key}) async {
    try {
      final box = boxName ?? defaultBoxName;
      await _ensureBoxIsOpen(boxName: box);
      await _boxMap[box]?.delete(key);
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
  Future<void> clear({String? boxName}) async {
    try {
      final box = boxName ?? defaultBoxName;
      await _ensureBoxIsOpen(boxName: box);
      await _boxMap[box]?.clear();
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
  Future<bool> containsKey({String? boxName, required String key}) async {
    try {
      final box = boxName ?? defaultBoxName;

      // Check if box exists before opening to avoid creating empty boxes
      if (!await _boxExists(boxName: box)) {
        return false; // Return false if box doesn't exist
      }

      await _ensureBoxIsOpen(boxName: box);
      return _boxMap[box]?.containsKey(key) ?? false;
    } catch (e) {
      StorageLogger.logError(
        'Error checking key existence: $key in box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<String>> getAllBoxes() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory(appDir.path);
      final List<FileSystemEntity> entities = await directory.list().toList();
      final List<String> boxNames = entities
          .where((file) => file.path.endsWith('.hive'))
          .map((file) => file.path.split('/').last.split('.hive').first)
          .toList();
      return boxNames;
    } catch (e) {
      StorageLogger.logError(
        'Error getting all box names',
        header: 'HiveStorage',
        error: e,
      );
      return [];
    }
  }

  @override
  Future<void> deleteAllBoxes() async {
    try {
      final allBoxNames = await getAllBoxes();

      // Close all opened boxes first
      for (final boxName in _boxMap.keys.toList()) {
        await _boxMap[boxName]?.close();
      }
      _boxMap.clear();

      // Delete all box files
      for (final boxName in allBoxNames) {
        await Hive.deleteBoxFromDisk(boxName);
      }

      // Reinitialize default box after clearing
      await openBox(boxName: defaultBoxName);
    } catch (e) {
      StorageLogger.logError(
        'Error clearing all boxes',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteBox({required String boxName}) async {
    try {
      // Close the box if it's open
      if (_boxMap.containsKey(boxName)) {
        await _boxMap[boxName]?.close();
        _boxMap.remove(boxName);
      }

      // Delete the box from disk
      await Hive.deleteBoxFromDisk(boxName);
    } catch (e) {
      StorageLogger.logError(
        'Error deleting box: $boxName',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }
}
