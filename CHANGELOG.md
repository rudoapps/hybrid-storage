# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/rudoapps/hybrid-storage/releases/tag/v1.0.0
