import 'package:hybrid_storage/hybrid_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../models/task.dart';

/// Repository for user-related data operations.
///
/// Demonstrates dependency injection of StorageService.
/// This class doesn't know about the concrete implementations (PreferencesStorageImpl, SecureStorageImpl),
/// it only depends on the StorageService interface.
@lazySingleton
class UserRepository {
  final StorageService _preferencesStorage;
  final StorageService _secureStorage;
  final HiveService _hiveStorage;

  UserRepository(
    @Named('preferences') this._preferencesStorage,
    @Named('secure') this._secureStorage,
    @Named('hive') this._hiveStorage,
  );

  // ===== User Profile (PreferencesStorage) =====

  Future<void> saveUsername(String username) {
    return _preferencesStorage.write(key: 'username', value: username);
  }

  Future<String?> getUsername() {
    return _preferencesStorage.read(key: 'username');
  }

  Future<void> deleteUsername() {
    return _preferencesStorage.delete(key: 'username');
  }

  // ===== Settings (PreferencesStorage) =====

  Future<void> setDarkMode(bool enabled) {
    return _preferencesStorage.writeBool(key: 'dark_mode', value: enabled);
  }

  Future<bool> getDarkMode() {
    return _preferencesStorage.readBool(key: 'dark_mode');
  }

  Future<void> setLoginCount(int count) {
    return _preferencesStorage.writeInt(key: 'login_count', value: count);
  }

  Future<int?> getLoginCount() {
    return _preferencesStorage.readInt(key: 'login_count');
  }

  Future<void> incrementLoginCount() async {
    final current = await getLoginCount() ?? 0;
    await setLoginCount(current + 1);
  }

  Future<void> setAppVersion(double version) {
    return _preferencesStorage.writeDouble(key: 'app_version', value: version);
  }

  Future<double?> getAppVersion() {
    return _preferencesStorage.readDouble(key: 'app_version');
  }

  // ===== Auth (SecureStorage - Encrypted) =====

  Future<void> saveAuthToken(String token) {
    return _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() {
    return _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteAuthToken() {
    return _secureStorage.delete(key: 'auth_token');
  }

  Future<bool> hasAuthToken() {
    return _secureStorage.containsKey(key: 'auth_token');
  }

  // ===== Tasks (HiveStorage - Complex Objects) =====

  static const String _tasksBoxName = 'tasks';

  Future<List<Task>> getTasks() async {
    final tasksData = await _hiveStorage.getAll<Map>(boxName: _tasksBoxName);
    return tasksData
        .map((data) => Task.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> addTask({required Task task}) async {
    await _hiveStorage.put<Map>(
      boxName: _tasksBoxName,
      key: task.id,
      value: task.toJson(),
    );
  }

  Future<void> updateTask({required Task task}) async {
    await _hiveStorage.put<Map>(
      boxName: _tasksBoxName,
      key: task.id,
      value: task.toJson(),
    );
  }

  Future<void> deleteTask({required String taskId}) async {
    await _hiveStorage.delete(boxName: _tasksBoxName, key: taskId);
  }

  Future<void> clearAllTasks() async {
    await _hiveStorage.clear(boxName: _tasksBoxName);
  }

  // ===== Clear All Data =====

  Future<void> clearAllData() async {
    await _preferencesStorage.clear();
    await _secureStorage.clear();
    await clearAllTasks();
  }
}
