import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../source/hive_storage_service.dart';

@Singleton()
class HiveStorageImpl implements HiveStorageService {
  final Map<String, Box> _boxes = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> openBox(String boxName) async {
    if (!_boxes.containsKey(boxName)) {
      _boxes[boxName] = await Hive.openBox(boxName);
    }
  }

  @override
  Future<void> put<T>({required String boxName, required String key, required T value}) async {
    await openBox(boxName);
    await _boxes[boxName]?.put(key, value);
  }

  @override
  Future<T?> get<T>({required String boxName, required String key}) async {
    await openBox(boxName);
    return _boxes[boxName]?.get(key) as T?;
  }

  @override
  Future<List<T>> getAll<T>({required String boxName}) async {
    await openBox(boxName);
    return _boxes[boxName]?.values.whereType<T>().toList() ?? [];
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    await openBox(boxName);
    await _boxes[boxName]?.delete(key);
  }

  @override
  Future<void> clear({required String boxName}) async {
    await openBox(boxName);
    await _boxes[boxName]?.clear();
  }

  @override
  Future<bool> containsKey({required String boxName, required String key}) async {
    await openBox(boxName);
    return _boxes[boxName]?.containsKey(key) ?? false;
  }
}
