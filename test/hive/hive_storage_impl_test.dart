import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hybrid_storage/src/hive/hive_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

// Import centralized fake data and constants
import 'mocks/hive_mocks.dart';

// Mock classes (always inline in test file)
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
      final value = createFakeMapData();
      when(() => mockBox.put(testKey, value))
          .thenAnswer((_) async => Future.value());

      // ACT
      await hiveStorage.put<Map>(
          boxName: testBoxName, key: testKey, value: value);

      // ASSERT
      verify(() => mockBox.put(testKey, value)).called(1);
    });

    test('should throw exception when put fails', () async {
      // ARRANGE
      final value = createFakeMapData();
      when(() => mockBox.put(testKey, value))
          .thenThrow(Exception(errorMessagePutFailed));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.put<Map>(boxName: testBoxName, key: testKey, value: value),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - get', () {
    test('should return value when key exists', () async {
      // ARRANGE
      final expectedValue = createFakeMapData();
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.get(testKey)).thenReturn(expectedValue);

      // ACT
      final result =
          await hiveStorage.get<Map>(boxName: testBoxName, key: testKey);

      // ASSERT
      expect(result, equals(expectedValue));
    });

    test('should return null when key does not exist', () async {
      // ARRANGE
      const key = 'non_existent_key';
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.get(key)).thenReturn(null);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: testBoxName, key: key);

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
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.get(testKey))
          .thenThrow(Exception(errorMessageGetFailed));

      // ACT + ASSERT
      expect(
        () => hiveStorage.get<Map>(boxName: testBoxName, key: testKey),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HiveStorageImpl - getAll', () {
    test('should return all values of correct type', () async {
      // ARRANGE
      final values = createFakeMapList(count: 2);
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.values).thenReturn(values);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: testBoxName);

      // ASSERT
      expect(result, equals(values));
    });

    test('should return empty list when box is empty', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.values).thenReturn([]);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: testBoxName);

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
      final mixedValues = createMixedTypeValues();
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.values).thenReturn(mixedValues);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: testBoxName);

      // ASSERT
      expect(result.length, equals(3)); // 3 maps in mixed values
      expect(result, everyElement(isA<Map>()));
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
      await hiveStorage.openBox(boxName: testBox1);
      await hiveStorage.openBox(boxName: testBox2);

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
