import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hybrid_storage/src/hive/hive_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockHiveInterface extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box<dynamic> {}

class MockTypeAdapter extends Mock implements TypeAdapter<dynamic> {}

void main() {
  late MockHiveInterface mockHive;
  late MockBox mockBox;
  late HiveStorageImpl hiveStorage;

  setUp(() {
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

    when(() => mockHive.openBox(any())).thenAnswer((_) async => mockBox);
    when(() => mockHive.deleteBoxFromDisk(any())).thenAnswer((_) async => {});

    hiveStorage = HiveStorageImpl(hive: mockHive);
  });

  group('HiveStorageImpl - registerAdapter', () {
    test('should register adapter when not already registered', () {
      // ARRANGE
      final mockAdapter = MockTypeAdapter();
      when(() => mockAdapter.typeId).thenReturn(1);
      when(() => mockHive.isAdapterRegistered(1)).thenReturn(false);
      when(() => mockHive.registerAdapter(mockAdapter)).thenReturn(null);

      // ACT
      hiveStorage.registerAdapter(mockAdapter);

      // ASSERT
      verify(() => mockHive.isAdapterRegistered(1)).called(1);
      verify(() => mockHive.registerAdapter(mockAdapter)).called(1);
    });

    test('should not register adapter when already registered', () {
      // ARRANGE
      final mockAdapter = MockTypeAdapter();
      when(() => mockAdapter.typeId).thenReturn(1);
      when(() => mockHive.isAdapterRegistered(1)).thenReturn(true);

      // ACT
      hiveStorage.registerAdapter(mockAdapter);

      // ASSERT
      verify(() => mockHive.isAdapterRegistered(1)).called(1);
      verifyNever(() => mockHive.registerAdapter(mockAdapter));
    });
  });

  group('HiveStorageImpl - openBox', () {
    test('should open box successfully', () async {
      // ARRANGE
      const boxName = 'test_box';

      // ACT
      await hiveStorage.openBox(boxName: boxName);

      // ASSERT
      verify(() => mockHive.openBox(boxName)).called(1);
    });

    test('should not open box when already opened', () async {
      // ARRANGE
      const boxName = 'test_box';
      await hiveStorage.openBox(boxName: boxName);

      // ACT
      await hiveStorage.openBox(boxName: boxName);

      // ASSERT
      verify(() => mockHive.openBox(boxName)).called(1); // Only once
    });

    test('should throw exception when openBox fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      when(() => mockHive.openBox(boxName)).thenThrow(Exception('Open failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.openBox(boxName: boxName),
        throwsException,
      );
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
      const boxName = 'test_box';
      const key = 'test_key';
      final expectedValue = {'id': '1', 'name': 'Test'};
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.get(key)).thenReturn(expectedValue);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, equals(expectedValue));
    });

    test('should return null when key does not exist', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'non_existent_key';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.get(key)).thenReturn(null);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, isNull);
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
      const boxName = 'test_box';
      const key = 'test_key';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.get(key)).thenThrow(Exception('Get failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.get<Map>(boxName: boxName, key: key),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HiveStorageImpl - getAll', () {
    test('should return all values of correct type', () async {
      // ARRANGE
      const boxName = 'test_box';
      final values = [
        {'id': '1', 'name': 'Test1'},
        {'id': '2', 'name': 'Test2'},
      ];
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.values).thenReturn(values);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result, equals(values));
    });

    test('should return empty list when box is empty', () async {
      // ARRANGE
      const boxName = 'test_box';
      await hiveStorage.openBox(boxName: boxName);
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
      const boxName = 'test_box';
      final mixedValues = [
        {'id': '1', 'name': 'Test1'},
        'string_value',
        {'id': '2', 'name': 'Test2'},
        42,
      ];
      await hiveStorage.openBox(boxName: boxName);
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
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.delete(key)).thenAnswer((_) async => Future.value());

      // ACT
      await hiveStorage.delete(boxName: boxName, key: key);

      // ASSERT - should not throw
    });

    test('should throw exception when delete fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.delete(key)).thenThrow(Exception('Delete failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.delete(boxName: boxName, key: key),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HiveStorageImpl - clear', () {
    test('should clear all keys successfully', () async {
      // ARRANGE
      const boxName = 'test_box';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.clear()).thenAnswer((_) async => 0);

      // ACT
      await hiveStorage.clear(boxName: boxName);

      // ASSERT - should not throw
    });

    test('should throw exception when clear fails', () async {
      // ARRANGE
      const boxName = 'test_box';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.clear()).thenThrow(Exception('Clear failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.clear(boxName: boxName),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HiveStorageImpl - containsKey', () {
    test('should return true when key exists', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.containsKey(key)).thenReturn(true);

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isTrue);
    });

    test('should return false when key does not exist', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'non_existent_key';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.containsKey(key)).thenReturn(false);

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isFalse);
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
      const boxName = 'test_box';
      const key = 'test_key';
      await hiveStorage.openBox(boxName: boxName);
      when(() => mockBox.containsKey(key)).thenThrow(Exception('Check failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.containsKey(boxName: boxName, key: key),
        throwsA(isA<Exception>()),
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
      // ARRANGE
      await hiveStorage.openBox(boxName: 'box1');
      await hiveStorage.openBox(boxName: 'box2');

      // ACT
      await hiveStorage.deleteAllBoxes();

      // ASSERT
      verify(() => mockBox.close()).called(greaterThanOrEqualTo(2));
    });

    test('should throw exception when deleteAllBoxes fails', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: 'test_box');
      when(() => mockBox.close()).thenThrow(Exception('Close failed'));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.deleteAllBoxes(),
        throwsException,
      );
    });
  });
}
