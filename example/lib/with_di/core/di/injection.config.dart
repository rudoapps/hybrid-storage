// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hybrid_storage/hybrid_storage.dart' as _i220;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/repositories/user_repository.dart' as _i517;
import 'storage_module.dart' as _i371;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    await gh.lazySingletonAsync<_i220.HybridHiveService>(
      () => storageModule.hiveStorage,
      instanceName: 'hive',
      preResolve: true,
    );
    gh.lazySingleton<_i220.HybridStorageService>(
      () => storageModule.secureStorage,
      instanceName: 'secure',
    );
    await gh.factoryAsync<_i220.HybridStorageService>(
      () => storageModule.preferencesStorage,
      instanceName: 'preferences',
      preResolve: true,
    );
    gh.lazySingleton<_i517.UserRepository>(
      () => _i517.UserRepository(
        gh<_i220.HybridStorageService>(instanceName: 'preferences'),
        gh<_i220.HybridStorageService>(instanceName: 'secure'),
        gh<_i220.HybridHiveService>(instanceName: 'hive'),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i371.StorageModule {}
