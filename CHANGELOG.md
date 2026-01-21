# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-01-21

### Added

- **HiveStorage integration** - New `HiveService` interface for complex object storage
- **HiveStorageImpl** - Complete Hive implementation with box-based organization
- Support for storing and retrieving complex objects via JSON serialization
- `HiveService` interface with methods: `init()`, `openBox()`, `put()`, `get()`, `getAll()`, `delete()`, `clear()`, `containsKey()`, `getAllBoxes()`, `clearAllBoxes()`
- Default box (`app_data`) automatically opened during `init()` for convenience
- Support for storing primitive types (String, bool, int, etc.) alongside complex objects
- Comprehensive unit tests for HiveStorageImpl (21 test cases)
- Full example app integration demonstrating Hive usage:
  - Task model with CRUD operations (JSON serialization)
  - Simple note storage (primitive String values)
  - Box management UI (create, list, delete boxes)
  - "Without DI" example with direct instantiation
  - "With DI" example using repository pattern and injectable
- Updated README with Hive usage examples and documentation
- Platform support table for HiveStorageImpl (all platforms including Web/WASM)

### Changed

- Updated architecture diagram to include Hive implementation
- Enhanced example app with task management features
- Updated DI module to support HiveStorage with `@preResolve`
- Improved library description to mention Hive alongside other storage types

### Dependencies

- Added `hive_flutter: ^1.1.0` for local database functionality
- Added `path_provider: ^2.1.5` for accessing app directory to list all boxes

### Testing

- All 66 unit tests passing (45 existing + 21 new Hive tests)
- 74% test coverage for HiveStorageImpl with mocked dependencies
- Integration tests in example app verified

### Notes

- HiveStorage is **not encrypted** - use SecureStorage for sensitive data
- Requires calling `init()` before use (similar to PreferencesStorage)
- Works on all platforms including Web (uses IndexedDB)
- WASM compatible ✅

## [1.1.1]

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
  hybrid_storage: ^1.1.1
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

## [1.1.0] - 2025-12-01

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

## [1.0.0] - 2025-11-07

### Added

- Initial release of Hybrid Storage library
- `StorageService` interface with basic storage operations
- `SecureStorageImpl` implementation using `flutter_secure_storage`
- `PreferencesStorageImpl` implementation using `shared_preferences`
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
