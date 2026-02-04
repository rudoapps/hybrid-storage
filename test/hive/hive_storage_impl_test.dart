import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
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

      // ACT
      await hiveStorage.openBox(boxName: testBoxName);

      // ASSERT
      verify(() => mockHive.openBox(testBoxName)).called(1);
    });

    test('should throw exception when openBox fails', () async {
      // ARRANGE
      when(() => mockHive.openBox(testBoxName))
          .thenThrow(Exception(errorMessageOpenFailed));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.openBox(boxName: testBoxName),
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
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.get(nonExistentKey)).thenReturn(null);

      // ACT
      final result =
          await hiveStorage.get<Map>(boxName: testBoxName, key: nonExistentKey);

      // ASSERT
      expect(result, isNull);
    });

    test('should return null when box does not exist', () async {
      // ARRANGE

      // ACT
      final result =
          await hiveStorage.get<Map>(boxName: nonExistentBoxName, key: testKey);

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

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: nonExistentBoxName);

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
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.delete(testKey))
          .thenAnswer((_) async => Future.value());

      // ACT
      await hiveStorage.delete(boxName: testBoxName, key: testKey);

      // ASSERT - should not throw
    });

    test('should throw exception when delete fails', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.delete(testKey))
          .thenThrow(Exception(errorMessageDeleteFailed));

      // ACT + ASSERT
      expect(
        () => hiveStorage.delete(boxName: testBoxName, key: testKey),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HiveStorageImpl - clear', () {
    test('should clear all keys successfully', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.clear()).thenAnswer((_) async => 0);

      // ACT
      await hiveStorage.clear(boxName: testBoxName);

      // ASSERT - should not throw
    });

    test('should throw exception when clear fails', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.clear()).thenThrow(Exception(errorMessageClearFailed));

      // ACT + ASSERT
      expect(
        () => hiveStorage.clear(boxName: testBoxName),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HiveStorageImpl - containsKey', () {
    test('should return true when key exists', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.containsKey(testKey)).thenReturn(true);

      // ACT
      final result =
          await hiveStorage.containsKey(boxName: testBoxName, key: testKey);

      // ASSERT
      expect(result, isTrue);
    });

    test('should return false when key does not exist', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.containsKey(nonExistentKey)).thenReturn(false);

      // ACT
      final result = await hiveStorage.containsKey(
          boxName: testBoxName, key: nonExistentKey);

      // ASSERT
      expect(result, isFalse);
    });

    test('should return false when box does not exist', () async {
      // ARRANGE

      // ACT
      final result = await hiveStorage.containsKey(
          boxName: nonExistentBoxName, key: testKey);

      // ASSERT
      expect(result, isFalse);
    });

    test('should throw exception when containsKey fails', () async {
      // ARRANGE
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.containsKey(testKey))
          .thenThrow(Exception(errorMessageCheckFailed));

      // ACT + ASSERT
      expect(
        () => hiveStorage.containsKey(boxName: testBoxName, key: testKey),
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

      // ACT
      await hiveStorage.deleteBox(boxName: testBoxName);

      // ASSERT
      verify(() => mockHive.deleteBoxFromDisk(testBoxName)).called(1);
    });

    test('should throw exception when deleteBox fails', () async {
      // ARRANGE
      when(() => mockHive.deleteBoxFromDisk(testBoxName))
          .thenThrow(Exception(errorMessageDeleteFailed));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.deleteBox(boxName: testBoxName),
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
      await hiveStorage.openBox(boxName: testBoxName);
      when(() => mockBox.close()).thenThrow(Exception(errorMessageCloseFailed));

      // ACT + ASSERT
      await expectLater(
        hiveStorage.deleteAllBoxes(),
        throwsException,
      );
    });
  });
}
