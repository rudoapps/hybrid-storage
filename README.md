<p align="center">
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-storage/hybrid-storage-banner.png" alt="Hybrid Storage Banner" width="100%">
</p>

[![pub package](https://img.shields.io/pub/v/hybrid_storage.svg)](https://pub.dev/packages/hybrid_storage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible storage library for Flutter that provides a unified abstraction over Secure Storage and SharedPreferences, with integrated logging support.

## Features

- **Secure Storage**: Implementation with `flutter_secure_storage` for sensitive data (tokens, passwords, credentials) - Native encryption on mobile/desktop
- **Shared Preferences**: Implementation with `shared_preferences` for non-sensitive data (user preferences, settings)
- **Integrated Logging**: Automatic logging of initialization and errors using `hybrid_logger`
- **DI Agnostic**: Works with any dependency injection framework or none at all
- **Unified Interface**: Single interface for both storage types
- **Multiple Types**: Support for String, bool, int, and double
- **Well Tested**: Comprehensive unit tests included
- **Cross-platform**: Android, iOS, Linux, macOS, Windows (production ready) | Web (with limitations)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hybrid_storage: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Support

### PreferencesStorageImpl
Fully supported on all platforms:
- Android (SharedPreferences)
- iOS (NSUserDefaults)
- macOS (NSUserDefaults)
- Linux (XDG_DATA_HOME)
- Windows (AppData roaming)
- Web (LocalStorage)

### SecureStorageImpl
Platform-specific implementations:

| Platform | Storage Backend | Encryption | Status |
|----------|----------------|------------|--------|
| Android | KeyStore | Native | Production Ready |
| iOS | Keychain | Native | Production Ready |
| macOS | Keychain | Native | Production Ready |
| Linux | libsecret | Native | Production Ready |
| Windows | Credential Storage | Native | Production Ready |
| Web | LocalStorage | ❌ NOT ENCRYPTED | ⚠️ Experimental |

### Web Security Warning

**IMPORTANT:** On Web platforms, `SecureStorageImpl` uses **unencrypted LocalStorage**:
- Data is NOT encrypted
- Accessible via browser JavaScript console
- Vulnerable to XSS attacks
- Only works on HTTPS or localhost
- DO NOT use for sensitive data on Web

**For Web applications:**
- Use `PreferencesStorageImpl` for non-sensitive data
- Avoid `SecureStorageImpl` or implement server-side encryption
- Store tokens/credentials on server with secure session management

## Quick Start

### Direct Usage (No DI)

```dart
import 'package:hybrid_storage/hybrid_storage.dart';

// Secure Storage - for sensitive data
final secureStorage = SecureStorageImpl();
await secureStorage.write(key: 'auth_token', value: 'abc123');
final token = await secureStorage.read(key: 'auth_token');

// Preferences Storage - for app settings
final prefsStorage = PreferencesStorageImpl();
await prefsStorage.init(); // Required!
await prefsStorage.writeBool(key: 'dark_mode', value: true);
final isDarkMode = await prefsStorage.readBool(key: 'dark_mode');
```

## Usage with Dependency Injection

The library is DI-agnostic and works with any framework:

### With Injectable

```dart
import 'package:injectable/injectable.dart';
import 'package:hybrid_storage/hybrid_storage.dart';

@module
abstract class StorageModule {
  @lazySingleton
  StorageService get secureStorage => SecureStorageImpl();

  @preResolve
  Future<StorageService> get preferencesStorage async {
    final prefs = PreferencesStorageImpl();
    await prefs.init();
    return prefs;
  }
}
```

### With get_it

```dart
import 'package:get_it/get_it.dart';
import 'package:hybrid_storage/hybrid_storage.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton<StorageService>(
    () => SecureStorageImpl(),
  );

  getIt.registerLazySingletonAsync<StorageService>(
    () async {
      final prefs = PreferencesStorageImpl();
      await prefs.init();
      return prefs;
    },
  );
}
```

### With Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_storage/hybrid_storage.dart';

final secureStorageProvider = Provider<StorageService>(
  (ref) => SecureStorageImpl(),
);

final preferencesStorageProvider = FutureProvider<StorageService>(
  (ref) async {
    final prefs = PreferencesStorageImpl();
    await prefs.init();
    return prefs;
  },
);
```

## Available Operations

```dart
// Strings
await storage.write(key: 'username', value: 'john_doe');
String? username = await storage.read(key: 'username');

// Booleans
await storage.writeBool(key: 'is_logged_in', value: true);
bool isLoggedIn = await storage.readBool(key: 'is_logged_in');

// Integers
await storage.writeInt(key: 'user_age', value: 25);
int? age = await storage.readInt(key: 'user_age');

// Doubles
await storage.writeDouble(key: 'rating', value: 4.5);
double? rating = await storage.readDouble(key: 'rating');

// Check existence
bool exists = await storage.containsKey(key: 'username');

// Delete key
await storage.delete(key: 'username');

// Clear all
await storage.clear();
```

## Logging

The library includes automatic logging for:

- **Successful initialization**: Logged when storage initializes correctly
- **Errors**: All errors are logged with detailed context

Logs use colors for easy identification:
- Info (blue): Initialization
- Error (red): Errors and exceptions
- Warning (yellow): Warnings

## Implementation Differences

### SecureStorageImpl
- Native OS encryption (Android, iOS, macOS, Linux, Windows)
- Ideal for tokens, passwords, sensitive data
- No explicit initialization required
- Slower than SharedPreferences
- **Web: NOT encrypted** - uses LocalStorage without encryption

### PreferencesStorageImpl
- Fast and efficient
- Ideal for user preferences, configurations
- Works consistently across all platforms including Web
- **Requires calling `init()` before use**
- Not encrypted on any platform - don't use for sensitive data

## Architecture

```
lib/
├── src/
│   ├── source/
│   │   └── storage_service.dart          # Abstract interface
│   ├── secure_storage/
│   │   └── secure_storage_impl.dart      # Secure implementation
│   ├── shared_preferences/
│   │   └── preferences_storage_impl.dart # Preferences implementation
│   └── utils/
│       └── logger_config.dart            # Logging configuration
└── hybrid_storage.dart                   # Public exports
```

## Testing

Run tests with:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Built with:
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [hybrid_logger](https://pub.dev/packages/hybrid_logger)

With ❤️ by RudoApps Flutter Team 😊

![Rudo Apps](https://rudo.es/wp-content/uploads/logo-rudo.svg)
