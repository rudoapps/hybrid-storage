import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// GetIt instance - service locator
final getIt = GetIt.instance;

/// Configures all dependencies using injectable code generation.
///
/// This uses the local StorageModule (in storage_module.dart) which provides:
/// - @Named('preferences') HybridStorageService - HybridPreferencesStorageImpl
/// - @Named('secure') HybridStorageService - HybridSecureStorageImpl
///
/// Note: The library provides a similar module in `package:hybrid_storage/di.dart`
/// that can be used as a reference or copied to your project.
///
/// Must be called before accessing any dependencies.
/// This is async because some dependencies (like PreferencesStorage) require initialization.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
}
