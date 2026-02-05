/// Abstract interface for local database storage services.
///
/// Defines operations for storing complex objects and entities, not just primitives.
/// Unlike [StorageService], this interface supports generic types and box-based organization.
abstract interface class HiveService {
  /// Initializes the local database service.
  Future<void> init();

  /// Opens a storage box with the given name.
  Future<void> openBox({required String boxName});

  /// Stores a value of type [T] in the specified box.
  /// If [boxName] is not provided, uses the default box.
  Future<void> put<T>({String? boxName, required String key, required T value});

  /// Retrieves a value of type [T] from the specified box.
  /// Returns `null` if the key doesn't exist.
  /// If [boxName] is not provided, uses the default box.
  Future<T?> get<T>({String? boxName, required String key});

  /// Retrieves all values of type [T] from the specified box.
  /// If [boxName] is not provided, uses the default box.
  Future<List<T>> getAll<T>({String? boxName});

  /// Deletes a value from the specified box using its key.
  /// If [boxName] is not provided, uses the default box.
  Future<void> delete({String? boxName, required String key});

  /// Clears all data from the specified box.
  /// If [boxName] is not provided, uses the default box.
  Future<void> clear({String? boxName});

  /// Checks if a key exists in the specified box.
  /// If [boxName] is not provided, uses the default box.
  Future<bool> containsKey({String? boxName, required String key});

  /// Returns a list of all box names that exist on disk (opened or closed).
  Future<List<String>> getAllBoxes();

  /// Deletes all boxes and their data from disk.
  Future<void> deleteAllBoxes();

  /// Deletes a specific box and its data from disk.
  Future<void> deleteBox({required String boxName});
}
