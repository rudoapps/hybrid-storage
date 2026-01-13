<p align="center">
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-storage/hybrid-storage-banner.png" alt="Hybrid Storage Banner" width="100%">
</p>

[![pub package](https://img.shields.io/pub/v/hybrid_storage.svg)](https://pub.dev/packages/hybrid_storage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible storage library for Flutter that provides a unified abstraction over Secure Storage and SharedPreferences, with integrated logging support.

## Features

- **Secure Storage**: Implementation with `flutter_secure_storage` for sensitive data (tokens, passwords, credentials)
  - Native encryption on mobile/desktop platforms
  - WebCrypto API encryption on web/WASM (experimental)
- **Shared Preferences**: Implementation with `shared_preferences` for non-sensitive data (user preferences, settings)
- **WASM Compatible**: Full support for Flutter Web with WebAssembly compilation ✅
- **Integrated Logging**: Automatic logging of initialization and errors using `hybrid_logger`
- **DI Agnostic**: Works with any dependency injection framework or none at all
- **Unified Interface**: Single interface for both storage types
- **Multiple Types**: Support for String, bool, int, and double
- **Well Tested**: Comprehensive unit tests included
- **Cross-platform**: Android, iOS, Linux, macOS, Windows, Web, WASM

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hybrid_storage: ^1.1.1
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
| Android | KeyStore | AES Native | Production Ready ✅ |
| iOS | Keychain | Native | Production Ready ✅ |
| macOS | Keychain | Native | Production Ready ✅ |
| Linux | libsecret | Native | Production Ready ✅ |
| Windows | Credential Storage | Native | Production Ready ✅ |
| Web/WASM | LocalStorage | WebCrypto API | Experimental ⚠️ |

### Web & WASM Support

**WASM Compatibility:** ✅ Fully supported since version 1.1.1 (requires Flutter 3.24+)

**Web Encryption (Experimental):**

`SecureStorageImpl` on web uses **WebCrypto API** for encryption:
- ✅ Data IS encrypted using Web Cryptography API
- 🔒 Browser generates a private key automatically
- ⚠️ Keys are NOT portable (only work on same browser + domain)
- ⚠️ Marked as **experimental** - use at your own risk
- 🔐 Requires **HTTPS** and proper security headers

**Security Requirements for Web:**
- Must use HTTPS (or localhost for development)
- Enable HTTP Strict Forward Secrecy
- Configure proper Content Security Policy (CSP)
- Protect against XSS attacks with security headers

**Web Encryption Limitations:**
- Encrypted data only works in the same browser on the same domain
- Users can still access LocalStorage via DevTools (but data is encrypted)
- Not as secure as native platform encryption
- Cannot transfer encrypted data between browsers

**For Web applications, we recommend:**
- ✅ Use `SecureStorageImpl` for short-lived tokens/data with HTTPS
- ✅ Implement proper server-side session management
- ✅ Use `PreferencesStorageImpl` for non-sensitive preferences
- ⚠️ Don't store long-term sensitive data in browser storage
- 🔒 Use HttpOnly cookies for critical authentication tokens

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
- **Native platforms:** Strong OS-level encryption (Keychain/KeyStore/libsecret)
- **Web/WASM:** Experimental WebCrypto API encryption
- Ideal for tokens, passwords, API keys, sensitive data
- No explicit initialization required
- Slower than SharedPreferences
- WASM compatible ✅

### PreferencesStorageImpl
- Fast and efficient
- Ideal for user preferences, UI settings, non-sensitive configurations
- Works consistently across all platforms including Web/WASM
- **Requires calling `init()` before use**
- **NOT encrypted on any platform** - never use for sensitive data
- WASM compatible ✅

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
