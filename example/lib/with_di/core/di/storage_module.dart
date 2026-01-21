import 'package:injectable/injectable.dart';
import 'package:hybrid_storage/hybrid_storage.dart';

/// Injectable module for storage services.
///
/// This module uses hybrid_storage implementations.
/// The library provides a similar module in `package:hybrid_storage/di.dart`,
/// but injectable requires modules to be in the local package.
///
/// ## PreferencesStorage initialization:
/// PreferencesStorage requires async init() before use.
/// We use @preResolve to handle this initialization during DI setup.
/// This ensures eager initialization for better error handling and predictable startup.
///
/// Users should copy this file to their project and customize as needed.
@module
abstract class StorageModule {
  /// Provides PreferencesStorage for non-sensitive data (settings, preferences).
  ///
  /// Uses @preResolve because PreferencesStorageImpl requires async init().
  /// The init() call is mandatory before using the storage.
  @Named('preferences')
  @preResolve
  Future<StorageService> get preferencesStorage async {
    final prefs = PreferencesStorageImpl();
    await prefs.init(); // Required initialization
    return prefs;
  }

  /// Provides SecureStorage for sensitive data (tokens, passwords).
  ///
  /// SecureStorage doesn't require init(), so this is synchronous.
  @Named('secure')
  @lazySingleton
  StorageService get secureStorage => SecureStorageImpl();

  /// Provides HiveStorage for complex objects and entities.
  ///
  /// Uses @preResolve because HiveStorageImpl requires async init().
  @Named('hive')
  @preResolve
  Future<HiveService> get hiveStorage async {
    final hive = HiveStorageImpl();
    await hive.init(); // Required initialization
    return hive;
  }
}
