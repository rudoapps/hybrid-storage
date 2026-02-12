import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hybrid_storage/src/secure_storage/hybrid_secure_storage_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late FlutterSecureStorage mockStorage;
  late HybridSecureStorageImpl secureStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = HybridSecureStorageImpl(mockStorage);
  });

  group('HybridSecureStorageImpl - read', () {
    test('should return value when key exists', () async {
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => value);

      final result = await secureStorage.read(key: key);

      expect(result, equals(value));
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return null when key does not exist', () async {
      const key = 'non_existent_key';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

      final result = await secureStorage.read(key: key);

      expect(result, isNull);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when read fails', () {
      const key = 'test_key';
      when(() => mockStorage.read(key: key))
          .thenThrow(Exception('Read failed'));

      expect(() => secureStorage.read(key: key), throwsException);

      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });
  });

  group('HybridSecureStorageImpl - write', () {
    test('should write value successfully', () async {
      // ARRANGE
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockStorage.write(key: key, value: value))
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.write(key: key, value: value);

      // ASSERT
      verify(() => mockStorage.write(key: key, value: value)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when write fails', () {
      // ARRANGE
      const key = 'test_key';
      const value = 'test_value';
      when(() => mockStorage.write(key: key, value: value))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.write(key: key, value: value),
        throwsException,
      );

      // ASSERT
      verify(() => mockStorage.write(key: key, value: value)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });
  });

  group('HybridSecureStorageImpl - readBool', () {
    test('should return true when value is "true"', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => 'true');

      // ACT
      final result = await secureStorage.readBool(key: key);

      // ASSERT
      expect(result, isTrue);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return false when value is not "true"', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => 'false');

      // ACT
      final result = await secureStorage.readBool(key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return false when value is null', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

      // ACT
      final result = await secureStorage.readBool(key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when readBool fails', () {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.read(key: key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.readBool(key: key),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - writeBool', () {
    test('should write true as "true"', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.write(key: key, value: 'true'))
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.writeBool(key: key, value: true);

      // ASSERT
      verify(() => mockStorage.write(key: key, value: 'true')).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should write false as "false"', () async {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.write(key: key, value: 'false'))
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.writeBool(key: key, value: false);

      // ASSERT
      verify(() => mockStorage.write(key: key, value: 'false')).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when writeBool fails', () {
      // ARRANGE
      const key = 'test_bool';
      when(() => mockStorage.write(key: key, value: 'true'))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.writeBool(key: key, value: true),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - readInt', () {
    test('should return int when value is valid', () async {
      // ARRANGE
      const key = 'test_int';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => '42');

      // ACT
      final result = await secureStorage.readInt(key: key);

      // ASSERT
      expect(result, equals(42));
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return null when value is null', () async {
      // ARRANGE
      const key = 'test_int';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

      // ACT
      final result = await secureStorage.readInt(key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return null when value is not a valid int', () async {
      // ARRANGE
      const key = 'test_int';
      when(() => mockStorage.read(key: key))
          .thenAnswer((_) async => 'not_a_number');

      // ACT
      final result = await secureStorage.readInt(key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when readInt fails', () {
      // ARRANGE
      const key = 'test_int';
      when(() => mockStorage.read(key: key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.readInt(key: key),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - writeInt', () {
    test('should write int as string', () async {
      // ARRANGE
      const key = 'test_int';
      const value = 42;
      when(() => mockStorage.write(key: key, value: '42'))
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.writeInt(key: key, value: value);

      // ASSERT
      verify(() => mockStorage.write(key: key, value: '42')).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when writeInt fails', () {
      // ARRANGE
      const key = 'test_int';
      const value = 42;
      when(() => mockStorage.write(key: key, value: '42'))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.writeInt(key: key, value: value),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - readDouble', () {
    test('should return double when value is valid', () async {
      // ARRANGE
      const key = 'test_double';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => '3.14');

      // ACT
      final result = await secureStorage.readDouble(key: key);

      // ASSERT
      expect(result, equals(3.14));
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return null when value is null', () async {
      // ARRANGE
      const key = 'test_double';
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

      // ACT
      final result = await secureStorage.readDouble(key: key);

      // ASSERT
      expect(result, isNull);
      verify(() => mockStorage.read(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when readDouble fails', () {
      // ARRANGE
      const key = 'test_double';
      when(() => mockStorage.read(key: key))
          .thenThrow(Exception('Read failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.readDouble(key: key),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - writeDouble', () {
    test('should write double as string', () async {
      // ARRANGE
      const key = 'test_double';
      const value = 3.14;
      when(() => mockStorage.write(key: key, value: '3.14'))
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.writeDouble(key: key, value: value);

      // ASSERT
      verify(() => mockStorage.write(key: key, value: '3.14')).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when writeDouble fails', () {
      // ARRANGE
      const key = 'test_double';
      const value = 3.14;
      when(() => mockStorage.write(key: key, value: '3.14'))
          .thenThrow(Exception('Write failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.writeDouble(key: key, value: value),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - containsKey', () {
    test('should return true when key exists', () async {
      // ARRANGE
      const key = 'test_key';
      when(() => mockStorage.containsKey(key: key))
          .thenAnswer((_) async => true);

      // ACT
      final result = await secureStorage.containsKey(key: key);

      // ASSERT
      expect(result, isTrue);
      verify(() => mockStorage.containsKey(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should return false when key does not exist', () async {
      // ARRANGE
      const key = 'test_key';
      when(() => mockStorage.containsKey(key: key))
          .thenAnswer((_) async => false);

      // ACT
      final result = await secureStorage.containsKey(key: key);

      // ASSERT
      expect(result, isFalse);
      verify(() => mockStorage.containsKey(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when containsKey fails', () {
      // ARRANGE
      const key = 'test_key';
      when(() => mockStorage.containsKey(key: key))
          .thenThrow(Exception('Check failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.containsKey(key: key),
        throwsException,
      );
    });
  });

  group('HybridSecureStorageImpl - delete', () {
    test('should delete key successfully', () async {
      // ARRANGE
      const key = 'test_key';
      when(() => mockStorage.delete(key: key))
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.delete(key: key);

      // ASSERT
      verify(() => mockStorage.delete(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when delete fails', () {
      // ARRANGE
      const key = 'test_key';
      when(() => mockStorage.delete(key: key))
          .thenThrow(Exception('Delete failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.delete(key: key),
        throwsException,
      );

      // ASSERT
      verify(() => mockStorage.delete(key: key)).called(1);
      verifyNoMoreInteractions(mockStorage);
    });
  });

  group('HybridSecureStorageImpl - clear', () {
    test('should clear all keys successfully', () async {
      // ARRANGE
      when(() => mockStorage.deleteAll())
          .thenAnswer((_) async => Future.value());

      // ACT
      await secureStorage.clear();

      // ASSERT
      verify(() => mockStorage.deleteAll()).called(1);
      verifyNoMoreInteractions(mockStorage);
    });

    test('should throw exception when clear fails', () {
      // ARRANGE
      when(() => mockStorage.deleteAll()).thenThrow(Exception('Clear failed'));

      // ACT + ASSERT
      expect(
        () => secureStorage.clear(),
        throwsException,
      );

      // ASSERT
      verify(() => mockStorage.deleteAll()).called(1);
      verifyNoMoreInteractions(mockStorage);
    });
  });
}
