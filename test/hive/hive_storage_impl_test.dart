import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hybrid_storage/src/hive/hive_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

// Mock class inline (following the pattern)
class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox mockBox;
  late HiveStorageImpl hiveStorage;
  late Map<String, Box> mockBoxes;

  setUp(() {
    mockBox = MockBox();
    mockBoxes = {'test_box': mockBox};
    hiveStorage = HiveStorageImpl(mockBoxes);
  });

  group('HiveStorageImpl - initialization', () {
    test('should throw StateError when not initialized', () {
      // ARRANGE
      final uninitializedStorage = HiveStorageImpl();

      // ACT + ASSERT
      expect(
        () => uninitializedStorage.openBox('test'),
        throwsStateError,
      );
    });

    test('should not throw when initialized with injected boxes', () {
      // ARRANGE
      final initializedStorage = HiveStorageImpl(mockBoxes);

      // ACT + ASSERT
      expect(
        () => initializedStorage.openBox('test_box'),
        returnsNormally,
      );
    });
  });

  group('HiveStorageImpl - openBox', () {
    test('should not open box when already exists', () async {
      // ARRANGE
      const boxName = 'test_box';

      // ACT
      await hiveStorage.openBox(boxName);

      // ASSERT - no interactions because box already exists
      verifyNever(() => mockBox.put(any(), any()));
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
      verifyNoMoreInteractions(mockBox);
    });

    test('should throw exception when put fails', () {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      final value = {'id': '1', 'name': 'Test'};
      when(() => mockBox.put(key, value)).thenThrow(Exception('Put failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.put<Map>(boxName: boxName, key: key, value: value),
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
      when(() => mockBox.get(key)).thenReturn(expectedValue);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, equals(expectedValue));
      verify(() => mockBox.get(key)).called(1);
      verifyNoMoreInteractions(mockBox);
    });

    test('should return null when key does not exist', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'non_existent_key';
      when(() => mockBox.get(key)).thenReturn(null);

      // ACT
      final result = await hiveStorage.get<Map>(boxName: boxName, key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockBox.get(key)).called(1);
      verifyNoMoreInteractions(mockBox);
    });

    test('should throw exception when get fails', () {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      when(() => mockBox.get(key)).thenThrow(Exception('Get failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.get<Map>(boxName: boxName, key: key),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - getAll', () {
    test('should return all values from box', () async {
      // ARRANGE
      const boxName = 'test_box';
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
      verifyNoMoreInteractions(mockBox);
    });

    test('should return empty list when box is empty', () async {
      // ARRANGE
      const boxName = 'test_box';
      when(() => mockBox.values).thenReturn([]);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result, isEmpty);
      verify(() => mockBox.values).called(1);
      verifyNoMoreInteractions(mockBox);
    });

    test('should filter by type correctly', () async {
      // ARRANGE
      const boxName = 'test_box';
      final mixedValues = [
        {'id': '1', 'name': 'Test1'},
        'string_value',
        {'id': '2', 'name': 'Test2'},
      ];
      when(() => mockBox.values).thenReturn(mixedValues);

      // ACT
      final result = await hiveStorage.getAll<Map>(boxName: boxName);

      // ASSERT
      expect(result.length, equals(2));
      expect(result, everyElement(isA<Map>()));
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
      verifyNoMoreInteractions(mockBox);
    });

    test('should throw exception when delete fails', () {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      when(() => mockBox.delete(key)).thenThrow(Exception('Delete failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.delete(boxName: boxName, key: key),
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
      verifyNoMoreInteractions(mockBox);
    });

    test('should throw exception when clear fails', () {
      // ARRANGE
      const boxName = 'test_box';
      when(() => mockBox.clear()).thenThrow(Exception('Clear failed'));

      // ACT + ASSERT
      expect(
        () => hiveStorage.clear(boxName: boxName),
        throwsException,
      );
    });
  });

  group('HiveStorageImpl - containsKey', () {
    test('should return true when key exists', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      when(() => mockBox.containsKey(key)).thenReturn(true);

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isTrue);
      verify(() => mockBox.containsKey(key)).called(1);
      verifyNoMoreInteractions(mockBox);
    });

    test('should return false when key does not exist', () async {
      // ARRANGE
      const boxName = 'test_box';
      const key = 'test_key';
      when(() => mockBox.containsKey(key)).thenReturn(false);

      // ACT
      final result = await hiveStorage.containsKey(boxName: boxName, key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockBox.containsKey(key)).called(1);
      verifyNoMoreInteractions(mockBox);
    });
  });
}
