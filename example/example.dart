import 'package:hybrid_storage/hybrid_storage.dart';

void main() async {
  // Example 1: SecureStorageImpl
  print('=== Example 1: SecureStorageImpl ===\n');

  final secureStorage = SecureStorageImpl();

  // Write and read authentication token
  await secureStorage.write(key: 'auth_token', value: 'eyJhbGc...');
  final token = await secureStorage.read(key: 'auth_token');
  print('Saved token: $token');

  // Save user credentials
  await secureStorage.write(key: 'username', value: 'john_doe');
  await secureStorage.write(key: 'password', value: 'super_secret_password');

  // Check if key exists
  final hasToken = await secureStorage.containsKey(key: 'auth_token');
  print('Has token saved? $hasToken');

  // Example 2: PreferencesStorageImpl
  print('\n=== Example 2: PreferencesStorageImpl ===\n');

  final prefsStorage = PreferencesStorageImpl();
  await prefsStorage.init(); // Must be initialized before use

  // Save user preferences
  await prefsStorage.writeBool(key: 'dark_mode', value: true);
  await prefsStorage.writeInt(key: 'notifications_count', value: 5);
  await prefsStorage.writeDouble(key: 'app_rating', value: 4.5);
  await prefsStorage.write(key: 'language', value: 'es');

  // Read preferences
  final isDarkMode = await prefsStorage.readBool(key: 'dark_mode');
  final notificationsCount = await prefsStorage.readInt(key: 'notifications_count');
  final rating = await prefsStorage.readDouble(key: 'app_rating');
  final language = await prefsStorage.read(key: 'language');

  print('Dark mode: $isDarkMode');
  print('Notifications: $notificationsCount');
  print('Rating: $rating');
  print('Language: $language');

  // Example 3: Error handling with logs
  print('\n=== Example 3: Error handling ===\n');

  try {
    final uninitializedStorage = PreferencesStorageImpl();
    await uninitializedStorage.read(key: 'some_key');
  } catch (e) {
    print('Error caught: $e');
  }

  // Example 4: Cleanup operations
  print('\n=== Example 4: Cleanup operations ===\n');

  // Delete specific key
  await secureStorage.delete(key: 'password');
  print('Password deleted');

  // Verify it was deleted
  final hasPassword = await secureStorage.containsKey(key: 'password');
  print('Has password saved? $hasPassword');

  print('\nExamples completed!');
}
