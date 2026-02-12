/// Abstract interface for storage services.
///
/// Defines basic operations that any storage service must implement.
abstract interface class HybridStorageService {
  /// Reads a String value from storage. Returns `null` if key doesn't exist.
  Future<String?> read({required String key});

  /// Writes a String value to storage.
  Future<void> write({required String key, required String value});

  /// Deletes a value from storage using its key.
  Future<void> delete({required String key});

  /// Writes a boolean value to storage.
  Future<void> writeBool({required String key, required bool value});

  /// Reads a boolean value from storage. Returns `false` if key doesn't exist.
  Future<bool> readBool({required String key});

  /// Writes an integer value to storage.
  Future<void> writeInt({required String key, required int value});

  /// Reads an integer value from storage. Returns `null` if key doesn't exist.
  Future<int?> readInt({required String key});

  /// Writes a double value to storage.
  Future<void> writeDouble({required String key, required double value});

  /// Reads a double value from storage. Returns `null` if key doesn't exist.
  Future<double?> readDouble({required String key});

  /// Checks if a key exists in storage.
  Future<bool> containsKey({required String key});

  /// Clears all storage.
  Future<void> clear();
}
