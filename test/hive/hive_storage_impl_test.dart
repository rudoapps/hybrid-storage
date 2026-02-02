import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hybrid_storage/src/hive/hive_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockHiveInterface extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockHiveInterface mockHive;
  late MockBox mockBox;
  late HiveStorageImpl hiveStorage;

  setUp(() async {
    mockHive = MockHiveInterface();
    mockBox = MockBox();

    // Setup default mocks
    when(() => mockBox.isOpen).thenReturn(true);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
    when(() => mockBox.delete(any())).thenAnswer((_) async => {});
    when(() => mockBox.clear()).thenAnswer((_) async => 0);
    when(() => mockBox.close()).thenAnswer((_) async => {});
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.values).thenReturn([]);
    when(() => mockBox.containsKey(any())).thenReturn(false);

    when(() => mockHive.initFlutter()).thenAnswer((_) async => {});
    when(() => mockHive.openBox(any())).thenAnswer((_) async => mockBox);
    when(() => mockHive.deleteBoxFromDisk(any())).thenAnswer((_) async => {});

    hiveStorage = HiveStorageImpl(hive: mockHive);
    await hiveStorage.init();
  });

  group('HiveStorageImpl - initialization', () {
    test('should initialize successfully', () async {
      // ARRANGE
      //when(() => mockHive.openBox('app_data')).thenAnswer((_) async => mockBox);

      // ACT
      await hiveStorage.init();

      // ASSERT
      expectLater(mockHive.openBox(any()), mockBox);
      verify(() => mockHive.initFlutter()).called(1);
      verify(() => mockHive.openBox('app_data')).called(1);
    });

    test('should throw StateError when not initialized', () {
      // ARRANGE
      final uninitializedStorage = HiveStorageImpl(hive: mockHive);

      // ACT + ASSERT
      expect(
        () => uninitializedStorage.openBox(boxName: 'test'),
        throwsStateError,
      );
    });

    test('should not reinitialize if already initialized', () async {
      // ARRANGE
      final storage = HiveStorageImpl(hive: mockHive);
      when(() => mockHive.initFlutter()).thenAnswer((_) async => {});
      when(() => mockHive.openBox('app_data')).thenAnswer((_) async => mockBox);
      await storage.init();

      // ACT
      await storage.init(); // Call init again

      // ASSERT
      verify(() => mockHive.initFlutter()).called(1); // Only called once
    });
  });

  group('HiveStorageImpl - openBox', () {
    test('should not open box when already exists', () async {
      // ARRANGE
      const boxName = 'test_box';

      // ACT
      await hiveStorage.openBox(boxName: boxName);

      // ASSERT - should not throw
    });
  });

  group('HiveStorageImpl - put', () {
    test('should put value successfully', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      final value = {'id': '1', 'name': 'Test'};
      when(() => mockBox.put(key, value))
          .thenAnswer((_) async => Future.value());

      // ACT
      await hiveStorage.put<Map>(boxName: boxName, key: key, value: value);

      // ASSERT
      verify(() => mockBox.put(key, value)).called(1);
    });

    test('should throw exception when put fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      final value = {'id': '1', 'name': 'Test'};
      when(() => mockBox.put(key, value)).thenThrow(Exception('Put failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.put<Map>(boxName: boxName, key: key, value: value),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - get', () {
    test('should return value when key exists', () async {
      // ARRANGE
      const boxName = 'app_data';
      const key = 'test_key';
      final expectedValue = {'id': '1', 'name': 'Test'};
      when(() => mockBox.get(key)).thenReturn(expectedValue);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, equals(expectedValue));
      verify(() => mockBox.get(key)).called(1);
    });

    test('should return null when key does not exist', () async {
      // ARRANGE
      const boxName = 'app_data';
      const key = 'non_existent_key';
      when(() => mockBox.get(key)).thenReturn(null);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockBox.get(key)).called(1);
    });

    test('should return null when box does not exist', () async {
      // ARRANGE
      const boxName = 'non_existent_box';
      const key = 'test_key';

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, isNull);
    });

    test('should throw exception when get fails', () async {
      // ARRANGE
      const boxName = 'app_data';
      const key = 'test_key';
      when(() => mockBox.get(key)).thenThrow(Exception('Get failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.get<Map>(boxName: boxName, key: key),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - getAll', () {
    test('should return all values of correct type', () async {
      // ARRANGE
      const boxName = 'app_data';
      final values = [
        {'id': '1', 'name': 'Test1'},
        {'id': '2', 'name': 'Test2'},
      ];
      when(() => mockBox.values).thenReturn(values);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result, equals(values));
      verify(() => mockBox.values).called(1);
    });

    test('should return empty list when box is empty', () async {
      // ARRANGE
      const boxName = 'app_data';
      when(() => mockBox.values).thenReturn([]);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result, isEmpty);
    });

    test('should return empty list when box does not exist', () async {
      // ARRANGE
      const boxName = 'non_existent_box';

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result, isEmpty);
    });

    test('should filter values by type', () async {
      // ARRANGE
      const boxName = 'app_data';
      final mixedValues = [
        {'id': '1', 'name': 'Test1'},
        'string_value',
        {'id': '2', 'name': 'Test2'},
        42,
      ];
      when(() => mockBox.values).thenReturn(mixedValues);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result.length, equals(2));
      expect(result[0], equals({'id': '1', 'name': 'Test1'}));
      expect(result[1], equals({'id': '2', 'name': 'Test2'}));
    });
  });

  group('HiveStorageImpl - delete', () {
    test('should delete key successfully', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      when(() => mockBox.delete(key)).thenAnswer((_) async => Future.value());

      // ACT
      await hiveStorage.delete(boxName: boxName, key: key);

      // ASSERT
      verify(() => mockBox.delete(key)).called(1);
    });

    test('should throw exception when delete fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      when(() => mockBox.delete(key)).thenThrow(Exception('Delete failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.delete(boxName: boxName, key: key),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - clear', () {
    test('should clear all keys successfully', () async {
      // ARRANGE
      const boxName = 'test_box';
      when(() => mockBox.clear()).thenAnswer((_) async => 0);

      // ACT
      await hiveStorage.clear(boxName: boxName);

      // ASSERT
      verify(() => mockBox.clear()).called(1);
    });

    test('should throw exception when clear fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      when(() => mockBox.clear()).thenThrow(Exception('Clear failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.clear(boxName: boxName),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - containsKey', () {
    test('should return true when key exists', () async {
      // ARRANGE
      const boxName = 'app_data';
      const key = 'test_key';
      when(() => mockBox.containsKey(key)).thenReturn(true);

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isTrue);
      verify(() => mockBox.containsKey(key)).called(1);
    });

    test('should return false when key does not exist', () async {
      // ARRANGE
      const boxName = 'app_data';
      const key = 'non_existent_key';
      when(() => mockBox.containsKey(key)).thenReturn(false);

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockBox.containsKey(key)).called(1);
    });

    test('should return false when box does not exist', () async {
      // ARRANGE
      const boxName = 'non_existent_box';
      const key = 'test_key';

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isFalse);
    });

    test('should throw exception when containsKey fails', () async {
      // ARRANGE
      const boxName = 'app_data';
      const key = 'test_key';
      when(() => mockBox.containsKey(key)).thenThrow(Exception('Check failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.containsKey(boxName: boxName, key: key),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - getAllBoxes', () {
    test('should return empty list when no boxes exist', () async {
      // ACT
      final result = await hiveStorage.getAllBoxes();

      // ASSERT
      expect(result, isA<List<String>>());
      expect(result, isEmpty);
    });
  });

  group('HiveStorageImpl - deleteBox', () {
    test('should delete box successfully', () async {
      // ARRANGE
      const boxName = 'test_box';

      // ACT
      await hiveStorage.deleteBox(boxName: boxName);

      // ASSERT
      verify(() => mockHive.deleteBoxFromDisk(boxName)).called(1);
    });

    test('should throw exception when deleteBox fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      when(() => mockHive.deleteBoxFromDisk(boxName))
          .thenThrow(Exception('Delete failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.deleteBox(boxName: boxName),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - deleteAllBoxes', () {
    test('should delete all boxes successfully', () async {
      // ACT
      await hiveStorage.deleteAllBoxes();

      // ASSERT
      verify(() => mockBox.close()).called(greaterThan(0));
      verify(() => mockHive.deleteBoxFromDisk(any())).called(greaterThan(0));
    });

    test('should throw exception when deleteAllBoxes fails', () async {
      // ARRANGE
      when(() => mockBox.close()).thenThrow(Exception('Close failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.deleteAllBoxes(),
        throwsException,
      );
    });
  });
}
