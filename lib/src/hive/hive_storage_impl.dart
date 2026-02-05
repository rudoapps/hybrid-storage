import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger_config.dart';
import '../source/hive_service.dart';

/// Implementation of [HiveService] using Hive.
///
/// Provides local database storage for complex objects and entities.
/// Supports generic types and organizes data in named boxes.
class HiveStorageImpl implements HiveService {
  final Map<String, Box> _boxes = {};
  final HiveInterface _hive;

  static const String defaultBoxName = 'app_data';

  HiveStorageImpl({HiveInterface? hive}) : _hive = hive ?? Hive {
    StorageLogger.logInit('HiveStorage');
  }

  /// Register a custom TypeAdapter for storing complex objects.
  ///
  /// This method must be called BEFORE calling [init()] or opening any boxes
  /// that will store objects of type [T].
  ///
  /// **Note:** The example app uses the modern `@GenerateAdapters` approach with
  /// `Hive.registerAdapters()` instead of this method. This method is provided
  /// for users who need manual adapter registration or custom adapters.
  ///
  /// **Modern Approach (Recommended - used in example app):**
  /// ```dart
  /// import 'package:hive_ce/hive_ce.dart';
  /// import 'hive/hive_registrar.g.dart';
  ///
  /// void main() {
  ///   Hive.registerAdapters(); // Auto-registers all generated adapters
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Manual Approach (Alternative - for custom adapters):**
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   // Register adapters manually
  ///   final hiveStorage = HiveStorageImpl();
  ///   hiveStorage.registerAdapter(MyCustomAdapter());
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Adapters are registered globally in Hive, so you only need to register
  /// them once in your app's main() method.
  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!_hive.isAdapterRegistered(adapter.typeId)) {
      _hive.registerAdapter(adapter);
      StorageLogger.logInit(
        'HiveStorage - Registered adapter for typeId: ${adapter.typeId}',
      );
    } else {
      StorageLogger.logInit(
        'HiveStorage - Adapter for typeId: ${adapter.typeId} already registered',
      );
    }
  }

  @override
  Future<void> init() async {
    if (kIsWeb) {
      StorageLogger.logError(
          'HiveStorageImpl is not supported on web platforms. Use PreferencesStorageImpl or SecureStorageImpl instead.',
          header: 'HiveStorage');
    }

    try {
      await _hive.initFlutter();

      // Open default box
      await openBox(boxName: defaultBoxName);

      StorageLogger.logInit('HiveStorage - Flutter initialized');
    } catch (e) {
      StorageLogger.logError(
        'Error initializing _hive',
        header: 'HiveStorage',
        error: e,
      );
      rethrow;
    }
  }

  /// Checks if a box exists either in memory or on disk.
  /// Returns true if the box exists, false otherwise.
  Future<bool> _boxExists({required String boxName}) async {
    // Check if box is already opened in memory
    if (_boxes.containsKey(boxName)) {
      return true;
    }
    // Check if box exists on disk
    final allBoxes = await getAllBoxes();
    return allBoxes.contains(boxName);
  }

  @override
  Future<void> openBox({required String boxName}) async {
    try {
      _boxes[boxName] = await _hive.openBox(boxName);
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
      {String? boxName, required String key, required value}) async {
    try {
      final box = boxName ?? defaultBoxName;
      await openBox(boxName: box);

      await _boxes[box]?.put(key, value);
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

      await openBox(boxName: box);

      return _boxes[box]?.get(key) as T?;
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

      await openBox(boxName: box);

      return _boxes[box]?.values.whereType<T>().toList() ?? [];
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

      // Check if box exists before opening to avoid creating empty boxes
      if (!await _boxExists(boxName: box)) {
        return; // Return empty list if box doesn't exist
      }

      await _boxes[box]?.delete(key);
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

      // Check if box exists before opening to avoid creating empty boxes
      if (!await _boxExists(boxName: box)) {
        return; // Return empty list if box doesn't exist
      }

      await _boxes[box]?.clear();
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
      await openBox(boxName: box);

      return _boxes[box]?.containsKey(key) ?? false;
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
      for (final boxName in _boxes.keys.toList()) {
        await _boxes[boxName]?.close();
      }
      _boxes.clear();

      // Delete all box files
      for (final boxName in allBoxNames) {
        await _hive.deleteBoxFromDisk(boxName);
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
      if (_boxes.containsKey(boxName)) {
        await _boxes[boxName]?.close();
        _boxes.remove(boxName);
      }

      // Delete the box from disk
      await _hive.deleteBoxFromDisk(boxName);
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
