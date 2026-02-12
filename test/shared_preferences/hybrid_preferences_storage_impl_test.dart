import 'package:flutter_test/flutter_test.dart';
import 'package:hybrid_storage/src/shared_preferences/hybrid_preferences_storage_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes inline (NUNCA en carpeta mocks/)
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPreferences;
  late HybridPreferencesStorageImpl preferencesStorage;

  setUp(() {
    mockPreferences = MockSharedPreferences();
    preferencesStorage = HybridPreferencesStorageImpl(mockPreferences);
  });

  group('HybridPreferencesStorageImpl - initialization', () {
    test('should throw StateError when not initialized', () {
      // ARRANGE
      final uninitializedStorage = HybridPreferencesStorageImpl();

      // ACT + ASSERT
      expect(
        () => uninitializedStorage.read(key: 'test'),
        throwsStateError,
      );
    });
  });

  group('HybridPreferencesStorageImpl - read', () {
    test('should return value when key exists', () async {
      // ARRANGE
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockPreferences.getString(key)).thenReturn(value);

      // ACT
      final result = await preferencesStorage.read(key: key);

      // ASSERT
      expect(result, equals(value));
      verify(() => mockPreferences.getString(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should return null when key does not exist', () async {
      // ARRANGE
      const key = 'non_existent_key';
      when(() => mockPreferences.getString(key)).thenReturn(null);

      // ACT
      final result = await preferencesStorage.read(key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockPreferences.getString(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when read fails', () {
      // ARRANGE
      const key = 'test_key';
      when(() => mockPreferences.getString(key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.read(key: key),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - write', () {
    test('should write value successfully', () async {
      // ARRANGE
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockPreferences.setString(key, value))
          .thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.write(key: key, value: value);

      // ASSERT
      verify(() => mockPreferences.setString(key, value)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when write fails', () {
      // ARRANGE
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockPreferences.setString(key, value))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.write(key: key, value: value),
        throwsException,
      );

      // ASSERT
      verify(() => mockPreferences.setString(key, value)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });
  });

  group('HybridPreferencesStorageImpl - readBool', () {
    test('should return true when value is true', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.getBool(key)).thenReturn(true);

      // ACT
      final result = await preferencesStorage.readBool(key: key);

      // ASSERT
      expect(result, isTrue);
      verify(() => mockPreferences.getBool(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should return false when value is false', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.getBool(key)).thenReturn(false);

      // ACT
      final result = await preferencesStorage.readBool(key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockPreferences.getBool(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should return false when value is null', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.getBool(key)).thenReturn(null);

      // ACT
      final result = await preferencesStorage.readBool(key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockPreferences.getBool(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when readBool fails', () {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.getBool(key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.readBool(key: key),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - writeBool', () {
    test('should write true successfully', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.setBool(key, true))
          .thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.writeBool(key: key, value: true);

      // ASSERT
      verify(() => mockPreferences.setBool(key, true)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should write false successfully', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.setBool(key, false))
          .thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.writeBool(key: key, value: false);

      // ASSERT
      verify(() => mockPreferences.setBool(key, false)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when writeBool fails', () {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockPreferences.setBool(key, true))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.writeBool(key: key, value: true),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - readInt', () {
    test('should return int when value exists', () async {
      // ARRANGE
      const key = 'test_int';
      when(() => mockPreferences.getInt(key)).thenReturn(42);

      // ACT
      final result = await preferencesStorage.readInt(key: key);

      // ASSERT
      expect(result, equals(42));
      verify(() => mockPreferences.getInt(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should return null when value does not exist', () async {
      // ARRANGE
      const key = 'test_int';
      when(() => mockPreferences.getInt(key)).thenReturn(null);

      // ACT
      final result = await preferencesStorage.readInt(key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockPreferences.getInt(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when readInt fails', () {
      // ARRANGE
      const key = 'test_int';
      when(() => mockPreferences.getInt(key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.readInt(key: key),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - writeInt', () {
    test('should write int successfully', () async {
      // ARRANGE
      const key = 'test_int';
      const value = 42;
      when(() => mockPreferences.setInt(key, value))
          .thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.writeInt(key: key, value: value);

      // ASSERT
      verify(() => mockPreferences.setInt(key, value)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when writeInt fails', () {
      // ARRANGE
      const key = 'test_int';
      const value = 42;
      when(() => mockPreferences.setInt(key, value))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.writeInt(key: key, value: value),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - readDouble', () {
    test('should return double when value exists', () async {
      // ARRANGE
      const key = 'test_double';
      when(() => mockPreferences.getDouble(key)).thenReturn(3.14);

      // ACT
      final result = await preferencesStorage.readDouble(key: key);

      // ASSERT
      expect(result, equals(3.14));
      verify(() => mockPreferences.getDouble(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should return null when value does not exist', () async {
      // ARRANGE
      const key = 'test_double';
      when(() => mockPreferences.getDouble(key)).thenReturn(null);

      // ACT
      final result = await preferencesStorage.readDouble(key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockPreferences.getDouble(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when readDouble fails', () {
      // ARRANGE
      const key = 'test_double';
      when(() => mockPreferences.getDouble(key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.readDouble(key: key),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - writeDouble', () {
    test('should write double successfully', () async {
      // ARRANGE
      const key = 'test_double';
      const value = 3.14;
      when(() => mockPreferences.setDouble(key, value))
          .thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.writeDouble(key: key, value: value);

      // ASSERT
      verify(() => mockPreferences.setDouble(key, value)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when writeDouble fails', () {
      // ARRANGE
      const key = 'test_double';
      const value = 3.14;
      when(() => mockPreferences.setDouble(key, value))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.writeDouble(key: key, value: value),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - containsKey', () {
    test('should return true when key exists', () async {
      // ARRANGE
      const key = 'test_key';
      when(() => mockPreferences.containsKey(key)).thenReturn(true);

      // ACT
      final result = await preferencesStorage.containsKey(key: key);

      // ASSERT
      expect(result, isTrue);
      verify(() => mockPreferences.containsKey(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should return false when key does not exist', () async {
      // ARRANGE
      const key = 'test_key';
      when(() => mockPreferences.containsKey(key)).thenReturn(false);

      // ACT
      final result = await preferencesStorage.containsKey(key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockPreferences.containsKey(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when containsKey fails', () {
      // ARRANGE
      const key = 'test_key';
      when(() => mockPreferences.containsKey(key))
          .thenThrow(Exception('Check failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.containsKey(key: key),
        throwsException,
      );
    });
  });

  group('HybridPreferencesStorageImpl - delete', () {
    test('should delete key successfully', () async {
      // ARRANGE
      const key = 'test_key';
      when(() => mockPreferences.remove(key)).thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.delete(key: key);

      // ASSERT
      verify(() => mockPreferences.remove(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when delete fails', () {
      // ARRANGE
      const key = 'test_key';
      when(() => mockPreferences.remove(key))
          .thenThrow(Exception('Delete failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.delete(key: key),
        throwsException,
      );

      // ASSERT
      verify(() => mockPreferences.remove(key)).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });
  });

  group('HybridPreferencesStorageImpl - clear', () {
    test('should clear all keys successfully', () async {
      // ARRANGE
      when(() => mockPreferences.clear()).thenAnswer((_) async => true);

      // ACT
      await preferencesStorage.clear();

      // ASSERT
      verify(() => mockPreferences.clear()).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });

    test('should throw exception when clear fails', () {
      // ARRANGE
      when(() => mockPreferences.clear()).thenThrow(Exception('Clear failed'));

      // ACT + ASSERT
      expect(
        () => preferencesStorage.clear(),
        throwsException,
      );

      // ASSERT
      verify(() => mockPreferences.clear()).called(1);
      verifyNoMoreInteractions(mockPreferences);
    });
  });
}
