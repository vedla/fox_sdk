import 'package:fox_sdk/src/utils/app_logger.dart';

export 'src/utils/app_logger.dart';

final class FoxLogger {
  FoxLogger._();

  /// The shared logger instance used by the SDK and CLI.
  static final AppLogger instance = foxLogger;
}
