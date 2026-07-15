import 'dart:io';

import 'package:fox_sdk/src/utils/app_logger.dart';
import 'package:path/path.dart' as p;

/// Cross-package application helpers and logging shortcuts.
class AppUtils {
  static AppLogger _logger = foxLogger;

  /// Replaces the shared logger instance used by AppUtils.
  static void configureLogger({
    FoxLoggerSettings? settings,
    AppLogger? logger,
  }) {
    _logger = logger ?? AppLogger(settings: settings);
  }

  /// Returns the currently configured shared logger.
  static AppLogger get logger => _logger;

  /// Trace-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get trace =>
      _logger.trace;

  /// Debug-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get debug =>
      _logger.debug;

  /// Info-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get info =>
      _logger.info;

  /// Error-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get error =>
      _logger.error;

  /// Error/stack-trace handler callback.
  static void Function(Object, [StackTrace?]) get handle => _logger.handle;

  /// Warn-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get warn =>
      _logger.warn;

  /// Warn-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get warning =>
      _logger.warning;

  /// Fatal-level logger callback.
  static void Function(Object?, [Object?, StackTrace?]) get fatal =>
      _logger.fatal;

  /// Progress helper backed by the shared logger.
  static AppLoggerProgress progress(String message) =>
      _logger.progress(message);

  /// Logs a message at error level.
  static void err(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.err(message, error, stackTrace);
  }

  /// Resolves the packaged game resource path for the current executable.
  ///
  /// On macOS packaged builds this returns `Resources/game` inside the app
  /// bundle. On other platforms it currently returns the resolved executable
  /// path.
  ///
  /// Example:
  /// ```dart
  /// final gameRoot = AppUtils.getAppBundlePath();
  /// ```
  static String getAppBundlePath(String? subpath) {
    final execPath = Platform.resolvedExecutable;

    if (Platform.isMacOS) {
      final execDir = File(execPath).parent.path;
      final contentsDir = p.dirname(execDir);
      AppUtils.debug(execDir);
      final rootPath = p.join(contentsDir, subpath ?? '');

      AppUtils.debug('MacOS detected. Resolved executable path: $rootPath');
      return rootPath;
    }

    return execPath;
  }
}
