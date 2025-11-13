import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake classes para registerFallbackValue

class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {}

class FakeSharedPreferences extends Fake implements SharedPreferences {}
