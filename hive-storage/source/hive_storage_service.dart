abstract interface class HiveStorageService {
  Future<void> init();
  Future<void> openBox(String boxName);
  Future<void> put<T>({required String boxName, required String key, required T value});
  Future<T?> get<T>({required String boxName, required String key});
  Future<List<T>> getAll<T>({required String boxName});
  Future<void> delete({required String boxName, required String key});
  Future<void> clear({required String boxName});
  Future<bool> containsKey({required String boxName, required String key});
}
