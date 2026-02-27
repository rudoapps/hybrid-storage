# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2026-02-27

### Changed

- Removed the constructor log in `HybridHiveStorageImpl`, moved `init()` directly under the constructor for clarity, and now log only after `init()` completes so Hive emits a single initialization message (@lib/src/hive/hybrid_hive_storage_impl.dart)

### Migration Guide

No action required. Update to `hybrid_storage: ^2.0.2`.

## [2.0.1] - 2026-02-19

### Changed

- Updated `shared_preferences` from `^2.5.0` to `^2.5.4`
- Updated `hive_ce_flutter` from `^2.0.2` to `^2.3.4`
- Updated `injectable` constraint from `>=2.3.2 <3.0.0` to `^2.7.1+4`
- Updated `get_it` to explicit `^9.2.0` constraint
- Updated `hive_ce_generator` (dev) from `^1.6.0` to `^1.11.0`
- Updated `build_runner` (dev) from `^2.4.0` to `^2.11.1`

### Documentation

- Improved installation section in README: split into **Without DI** and **With DI (injectable/get_it)** to prevent dependency resolution conflicts when consumers declare `injectable`/`get_it` with incompatible versions
- With DI section now also documents the required `dev_dependencies` (`build_runner`, `hive_ce_generator`, `injectable_generator`) in one place
- Updated all dependency version references in README to match current constraints

### Migration Guide

No code changes required. Update your `pubspec.yaml`:

```yaml
dependencies:
  hybrid_storage: ^2.0.1
```

If you use `injectable` and `get_it` in your project, ensure your versions are compatible:

```yaml
  injectable: ^2.7.1+4
  get_it: ^9.2.0
```

Then run `flutter pub get`.

## [2.0.0] - 2026-02-12

### Changed - BREAKING CHANGES

- **Renamed all public classes and interfaces with "Hybrid" prefix** to avoid naming conflicts when consuming the package
  - `StorageService` → `HybridStorageService`
  - `HiveService` → `HybridHiveService`
  - `SecureStorageImpl` → `HybridSecureStorageImpl`
  - `PreferencesStorageImpl` → `HybridPreferencesStorageImpl`
  - `HiveStorageImpl` → `HybridHiveStorageImpl`
- **Renamed all source files** to match new class names:
  - `storage_service.dart` → `hybrid_storage_service.dart`
  - `hive_service.dart` → `hybrid_hive_service.dart`
  - `secure_storage_impl.dart` → `hybrid_secure_storage_impl.dart`
  - `preferences_storage_impl.dart` → `hybrid_preferences_storage_impl.dart`
  - `hive_storage_impl.dart` → `hybrid_hive_storage_impl.dart`
- **Renamed all test files** to match implementation files with "hybrid" prefix
- Updated all documentation, examples, and code comments to reflect new naming convention
- Directory structure remains unchanged (generic technology names without prefix)

### Migration Guide

If you're updating from 1.x, update your imports and class references:

```dart
// Before (1.x)
final storage = SecureStorageImpl();
final prefs = PreferencesStorageImpl();
final hive = HiveStorageImpl();

// After (2.0.0)
final storage = HybridSecureStorageImpl();
final prefs = HybridPreferencesStorageImpl();
final hive = HybridHiveStorageImpl();
```

**Rationale:** This change allows projects to use standard naming (`StorageService`, `SecureStorageImpl`, etc.) for their own implementations while consuming the hybrid-storage package without conflicts.

## [1.3.0] - 2026-02-04

### Major Update: Full Hive implementation

### Added

- **HybridHiveStorage integration with Hive CE** - New `HybridHiveService` interface for complex object storage
- **HybridHiveStorageImpl** - Complete Hive CE implementation with box-based organization
- Support for storing and retrieving complex objects using TypeAdapters
- `HybridHiveService` interface with methods: `init()`, `registerAdapter()`, `openBox()`, `put()`, `get()`, `getAll()`, `delete()`, `clear()`, `containsKey()`, `getAllBoxes()`, `deleteBox()`, `deleteAllBoxes()`
- Default box (`app_data`) automatically opened during `init()` for convenience
- Support for storing primitive types (String, bool, int, etc.) alongside complex objects
- Comprehensive unit tests for HiveStorageImpl (27 test cases)
- Full example app integration demonstrating Hive CE usage:
  - Task model with CRUD operations using GenerateAdapters
  - Simple note storage (primitive String values)
  - Box management UI (create, list, delete boxes)
  - "Without DI" example with direct instantiation
  - "With DI" example using repository pattern and injectable
- Updated README with Hive CE usage examples and GenerateAdapters documentation
- Platform support table for HiveStorageImpl (all platforms including Web/WASM)

### Changed

- **Uses Hive CE** - Built with `hive_ce` and `hive_ce_flutter` packages (maintained community fork)
- **Modern GenerateAdapters approach** - Example app uses `@GenerateAdapters` instead of legacy `@HiveType`/`@HiveField` annotations
  - Cleaner model classes without annotations
  - Centralized adapter registration with `Hive.registerAdapters()`
  - Better schema management with `hive_adapters.g.yaml`
  - Improved support for model evolution and migrations
- Updated architecture diagram to include Hive implementation
- Enhanced example app with task management features
- Updated DI module to support HiveStorage with `@preResolve`
- Improved library description to mention Hive alongside other storage types

### Dependencies

- Added `hive_ce_flutter: ^2.0.2` for local database functionality
- Added `path_provider: ^2.1.5` for accessing app directory to list all boxes
- Example app uses `hive_ce: ^2.6.0` and `hive_ce_generator: ^1.6.0`

### Usage Guide

Add to your `pubspec.yaml`:
```yaml
dependencies:
  hybrid_storage: ^1.3.0
  hive_ce_flutter: ^2.0.2  # Required for HiveStorage

dev_dependencies:
  hive_ce_generator: ^1.6.0  # For TypeAdapter generation
  build_runner: ^2.4.0
```

Using GenerateAdapters (recommended):
1. Create `lib/hive/hive_adapters.dart`:
   ```dart
   import 'package:hive_ce/hive_ce.dart';
   import '../models/your_model.dart';
   
   @GenerateAdapters([
     AdapterSpec<YourModel>(),
   ])
   part 'hive_adapters.g.dart';
   ```

2. Register adapters in `main.dart`:
   ```dart
   import 'package:hive_ce/hive_ce.dart';
   import 'hive/hive_registrar.g.dart';
   
   void main() {
     Hive.registerAdapters();
     runApp(MyApp());
   }
   ```

3. Generate adapters:
   ```bash
   flutter pub run build_runner build
   ```

### Testing

- All 87 unit tests passing (60 existing + 27 new Hive tests)
- 80.5% test coverage for HiveStorageImpl (66 of 82 lines covered)
- Overall storage implementations coverage: 88.7% (165 of 186 lines)
- Example app verified with Hive CE and GenerateAdapters

### Notes

- **Hive CE** is a maintained community fork with active development
- **No migration needed** - This is the first release with Hive support
- HiveStorage is **not encrypted** - use SecureStorage for sensitive data
- Requires calling `init()` before use (similar to PreferencesStorage)
- **iOS and Android only** - Web/WASM NOT supported (use PreferencesStorage or SecureStorage for web)
- Desktop platforms (macOS, Linux, Windows) not tested yet

## [1.2.0]

### Major Update: Full WASM Support & Enhanced Security

This release brings full WebAssembly compatibility and updates all dependencies to their latest stable versions, improving security and performance across all platforms.

### Added

- **Full WASM compatibility** - Library now compiles successfully for Flutter Web with WebAssembly
- **WebCrypto encryption on Web** - Upgraded to `flutter_secure_storage` 10.0.0 with experimental WebCrypto API encryption
- **Enhanced platform support** - All storage implementations now work seamlessly on WASM-compiled web apps
- **Comprehensive web security documentation** - Added detailed section explaining encryption behavior on web platforms

### Changed

- Updated `flutter_secure_storage` from ^9.2.2 to ^10.0.0 (WASM compatible with WebCrypto API)
- Updated `shared_preferences` from ^2.3.3 to ^2.5.0
- Updated `injectable` constraint from ^2.3.2 to >=2.3.2 <3.0.0 for better compatibility
- Improved package description (reduced from 204 to 112 characters for pub.dev compliance)
- Updated README with accurate web encryption information
- Clarified that web storage uses **WebCrypto API** (not unencrypted as previously stated)

### Security Improvements

- Web platforms now use **WebCrypto API** for encryption (experimental)
  - Browser generates private encryption keys automatically
  - Data is encrypted in LocalStorage (previously was unencrypted)
  - Keys are non-portable (tied to browser + domain for security)
- Added security warnings and best practices for web storage
- Documented HTTPS requirements and security headers needed for web deployment

### Breaking Changes

- None - Fully backward compatible

### Migration Guide

No code changes required. Simply update your `pubspec.yaml`:

```yaml
dependencies:
  hybrid_storage: ^1.2.0
```

Then run `flutter pub get`

### Platform Support

| Platform | Status | Encryption |
|----------|--------|------------|
| Android | Production Ready | AES Native (KeyStore) |
| iOS | Production Ready | Native (Keychain) |
| macOS | Production Ready | Native (Keychain) |
| Linux | Production Ready | Native (libsecret) |
| Windows | Production Ready | Native (Credential Storage) |
| Web (JS) | Production Ready | WebCrypto API (Experimental) |
| Web (WASM) | Production Ready | WebCrypto API (Experimental) |

### Testing

- All 45 unit tests passing
- Successfully builds for WASM target
- Verified on Flutter 3.27.0 with Dart 3.10.3

### Notes

- Web encryption uses WebCrypto API and requires HTTPS in production
- Encrypted web data is not portable between browsers or domains (security feature)
- For maximum security on web, consider using HttpOnly cookies for critical tokens
- Minimum Flutter version: 3.24+ for WASM support

## [1.1.0]

### Added

- Complete functional example project in `example/` folder
- Example screen demonstrating usage WITHOUT dependency injection (direct instantiation)
- Example screen demonstrating usage WITH dependency injection (get_it + injectable)
- Reference implementation of `StorageModule` for injectable users
- Injectable dependency (optional) for dependency injection support
- Documentation on DI setup patterns and best practices
- Runnable Flutter example app showcasing all library features

### Removed

- Simple `example/example.dart` file (replaced by complete example app)

### Changed

- Improved example documentation with clear DI vs non-DI patterns
- Enhanced README with links to example implementations

## [1.0.0]

### Added

- Initial release of Hybrid Storage library
- `HybridStorageService` interface with basic storage operations
- `HybridSecureStorageImpl` implementation using `flutter_secure_storage`
- `HybridPreferencesStorageImpl` implementation using `shared_preferences`
- Integrated logging with `hybrid_logger`
- Support for String, bool, int, and double types
- `containsKey` method to verify key existence
- Automatic initialization logging
- Automatic error logging with detailed context
- Complete documentation in README.md
- Usage examples in example/example.dart
- DI-agnostic design (removed injectable dependency)
- Comprehensive unit tests with 45 test cases

### Features

- ✅ Encrypted secure storage (Android, iOS, macOS, Linux, Windows)
- ✅ Unencrypted preferences storage (all platforms)
- ✅ Unified interface for both types
- ✅ Colored logs with contextual information
- ✅ Robust error handling
- ✅ Complete documentation and examples
- ✅ Cross-platform support (Android, iOS, Web, Linux, macOS, Windows)

### Security Notes

- ⚠️ **Web Platform**: `SecureStorageImpl` uses unencrypted LocalStorage on Web
- ⚠️ Do not use `SecureStorageImpl` for sensitive data on Web platforms
- ✅ All other platforms use native encrypted storage (Keychain, KeyStore, etc.)

[1.3.0]: https://github.com/rudoapps/hybrid-storage/releases/tag/v1.3.0
[1.1.1]: https://github.com/rudoapps/hybrid-storage/releases/tag/v1.1.1
[1.1.0]: https://github.com/rudoapps/hybrid-storage/releases/tag/v1.1.0
[1.0.0]: https://github.com/rudoapps/hybrid-storage/releases/tag/v1.0.0
