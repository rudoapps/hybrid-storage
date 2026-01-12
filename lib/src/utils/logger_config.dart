import 'package:hybrid_logger/hybrid_logger.dart';

/// Logger configuration for hybrid_storage library.
class StorageLogger {
  static final HybridLogger _instance = HybridLogger(
    settings: HybridSettings(
      colors: {
        LogTypeEntity.error: AnsiPen()..red(),
        LogTypeEntity.info: AnsiPen()..blue(),
        LogTypeEntity.warning: AnsiPen()..yellow(),
      },
      type: LogTypeEntity.info,
      lineSymbol: '-',
      maxLineWidth: 80,
      showLines: true,
      showHeaders: true,
      maxLogLength: 1000,
    ),
    formatter: const LineStyleLogger(),
    filter: const LogTypeFilter(LogTypeEntity.info),
  );

  static HybridLogger get instance => _instance;

  static void logInit(String storageType) {
    _instance.info(
      'Storage initialized successfully',
      header: storageType,
    );
  }

  static void logError(String message, {String? header, Object? error}) {
    _instance.error(
      '$message${error != null ? '\nError: $error' : ''}',
      header: header ?? 'Storage Error',
    );
  }

  static void logWarning(String message, {String? header}) {
    _instance.warning(
      message,
      header: header ?? 'Storage Warning',
    );
  }
}
