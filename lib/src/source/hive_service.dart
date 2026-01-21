/// Abstract interface for local database storage services.
///
/// Defines operations for storing complex objects and entities, not just primitives.
/// Unlike [StorageService], this interface supports generic types and box-based organization.
abstract interface class HiveService {
  /// Initializes the local database service.
  Future<void> init();

  /// Opens a storage box with the given name.
  Future<void> openBox(String boxName);

  /// Stores a value of type [T] in the specified box.
  Future<void> put<T>(
      {required String boxName, required String key, required T value});

  /// Retrieves a value of type [T] from the specified box.
  /// Returns `null` if the key doesn't exist.
  Future<T?> get<T>({required String boxName, required String key});

  /// Retrieves all values of type [T] from the specified box.
  Future<List<T>> getAll<T>({required String boxName});

  /// Deletes a value from the specified box using its key.
  Future<void> delete({required String boxName, required String key});

  /// Clears all data from the specified box.
  Future<void> clear({required String boxName});

  /// Checks if a key exists in the specified box.
  Future<bool> containsKey({required String boxName, required String key});
}
