<p align="center">
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-storage/hybrid-storage-new-banner.png" alt="Hybrid Storage Banner" width="100%">
</p>

[![pub package](https://img.shields.io/pub/v/hybrid_storage.svg)](https://pub.dev/packages/hybrid_storage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible storage library for Flutter that provides unified abstractions over Secure Storage, SharedPreferences, and Hive, with integrated logging support for all your storage needs.

## Features

- **Secure Storage**: Implementation with `flutter_secure_storage` for sensitive data (tokens, passwords, credentials)
  - Native encryption on mobile/desktop platforms
  - WebCrypto API encryption on web/WASM (experimental)
- **Shared Preferences**: Implementation with `shared_preferences` for non-sensitive data (user preferences, settings)
- **Hive Storage**: Implementation with `hive_flutter` for complex objects and local database needs
  - **iOS and Android only** (web not supported, desktop platforms not tested yet)
- **WASM Compatible**: `SecureStorageImpl` and `PreferencesStorageImpl` fully support Flutter Web with WebAssembly compilation 
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
  hybrid_storage: ^1.3.0
  hive_ce_flutter: ^2.0.2  # Required for HiveStorage (Hive CE)
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

### HiveStorageImpl
Currently supported on mobile platforms only:
- ✅ Android (Hive native)
- ✅ iOS (Hive native)
- ⚠️ macOS (Not tested yet)
- ⚠️ Linux (Not tested yet)
- ⚠️ Windows (Not tested yet)
- ❌ **Web (NOT SUPPORTED)**

**Important:** `HiveStorageImpl` does **not** support web platforms due to fundamental differences between file system storage (native) and IndexedDB (web). Desktop platforms (macOS, Linux, Windows) have not been tested yet.

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

**WASM Compatibility:** ✅ Fully supported since version 1.2.0 (requires Flutter 3.24+)

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

## HiveStorage Usage
### Basic Usage

```dart
import 'package:hybrid_storage/hybrid_storage.dart';

// Initialize
final hiveStorage = HiveStorageImpl();
await hiveStorage.init();

// Open a box for your data type
await hiveStorage.openBox('tasks');

// Store complex objects (as JSON)
final task = {
  'id': '123',
  'title': 'My Task',
  'description': 'Task description',
  'isCompleted': false,
};

await hiveStorage.put<Map>(
  boxName: 'tasks',
  key: '123',
  value: task,
);

// Retrieve a single object
final retrievedTask = await hiveStorage.get<Map>(
  boxName: 'tasks',
  key: '123',
);

// Get all objects in a box
final allTasks = await hiveStorage.getAll<Map>(boxName: 'tasks');

// Delete an object
await hiveStorage.delete(boxName: 'tasks', key: '123');

// Clear all objects in a box
await hiveStorage.clear(boxName: 'tasks');

// Check if key exists
final exists = await hiveStorage.containsKey(boxName: 'tasks', key: '123');
```

### Using Custom TypeAdapters

For storing custom objects with better performance and type safety (instead of JSON Maps), use Hive CE's `GenerateAdapters` approach:

**1. Add dependencies to `pubspec.yaml`:**
```yaml
dependencies:
  hive_ce_flutter: ^2.0.2

dev_dependencies:
  hive_ce_generator: ^1.6.0
  build_runner: ^2.4.0
```

**2. Define your model class (no annotations needed):**
```dart
class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false, // Default values supported
  });
}
```

**3. Create `lib/hive/hive_adapters.dart`:**
```dart
import 'package:hive_ce/hive_ce.dart';
import '../models/task.dart';

@GenerateAdapters([
  AdapterSpec<Task>(),
])
part 'hive_adapters.g.dart';
```

**4. Generate the adapters:**
```bash
flutter pub run build_runner build
```

This creates:
- `lib/hive/hive_adapters.g.dart` - Generated adapter classes
- `lib/hive/hive_adapters.g.yaml` - Schema file (check into version control)
- `lib/hive/hive_registrar.g.dart` - Registration extension method

**5. Register adapters in `main.dart`:**
```dart
import 'package:hive_ce/hive_ce.dart';
import 'hive/hive_registrar.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register all adapters with one call
  Hive.registerAdapters();
  
  runApp(MyApp());
}
```

**6. Now you can store Task objects directly:**
```dart
await hiveStorage.put<Task>(
  boxName: 'tasks',
  key: 'task_1',
  value: Task(id: '1', title: 'My Task', isCompleted: false),
);

final task = await hiveStorage.get<Task>(boxName: 'tasks', key: 'task_1');
```

**Important Notes:**
- **Modern approach:** `GenerateAdapters` is the recommended way (replaces legacy `@HiveType`/`@HiveField` annotations)
- **Schema management:** The `.g.yaml` file tracks your schema and must be checked into version control
- **Adding fields:** Just add to your model and regenerate - old data still works with default values
- **Centralized registration:** Single `Hive.registerAdapters()` call registers all adapters
- **Better migrations:** Schema file enables safe model evolution
- Run `build_runner` whenever you modify your model classes
- **Note:** This library uses Hive CE (Community Edition), a maintained fork of the original Hive package

### Box Management

```dart
// Get all box names (opened or closed)
final allBoxes = await hiveStorage.getAllBoxes();

// Delete a specific box and its data
await hiveStorage.deleteBox(boxName: 'tasks');

// Delete all boxes
await hiveStorage.deleteAllBoxes();
```

**Important Notes:**
- **Default Box Behavior**: When using methods without specifying `boxName`, the default box (`app_data`) is used automatically
- **deleteAllBoxes()**: This method deletes ALL box files from disk. The default box (`app_data`) is immediately recreated empty after deletion, while other boxes are only recreated when accessed
- **Optional boxName Parameter**: All data methods (`put`, `get`, `getAll`, `delete`, `clear`, `containsKey`) have an optional `boxName` parameter. If not provided, they use the default box

```dart
// These are equivalent - both use the default 'app_data' box
await hiveStorage.put(key: 'user', value: userData);
await hiveStorage.put(boxName: 'app_data', key: 'user', value: userData);

// Use a specific box
await hiveStorage.put(boxName: 'cache', key: 'temp', value: data);
```

### With Dependency Injection

```dart
// With get_it
final getIt = GetIt.instance;

getIt.registerSingletonAsync<HiveService>(
  () async {
    final hive = HiveStorageImpl();
    await hive.init();
    return hive;
  },
);

// With injectable
@module
abstract class StorageModule {
  @Named('hive')
  @preResolve
  Future<HiveService> get hiveStorage async {
    final hive = HiveStorageImpl();
    await hive.init();
    return hive;
  }
}
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

### HiveStorageImpl
- Fast NoSQL database for complex objects
- Ideal for structured data, collections, local database needs
- Supports custom objects via TypeAdapters (recommended) or JSON serialization
- Box-based organization for different data types
- **Requires calling `init()` before use**
- **Requires registering TypeAdapters** for custom objects (see documentation above)
- **NOT encrypted** - use SecureStorage for sensitive data
- **iOS and Android only** (tested and production-ready)
- ⚠️ **Desktop platforms** (macOS, Linux, Windows) - not tested yet
- ❌ **Web/WASM NOT supported**

## Architecture

```
lib/
├── src/
│   ├── source/
│   │   ├── storage_service.dart          # Abstract interface (primitives)
│   │   └── hive_service.dart         # Abstract interface (complex objects)
│   ├── secure_storage/
│   │   └── secure_storage_impl.dart      # Secure implementation
│   ├── shared_preferences/
│   │   └── preferences_storage_impl.dart # Preferences implementation
│   ├── hive/
│   │   └── hive_storage_impl.dart        # Hive implementation
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
- [hive_flutter](https://pub.dev/packages/hive_flutter)
- [hybrid_logger](https://pub.dev/packages/hybrid_logger)

With ❤️ by Laberit Flutter Team 😊
