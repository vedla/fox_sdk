import 'dart:async';
import 'dart:io';

/// Shared application logger used by the SDK and CLI.
final foxLogger = AppLogger();

/// Default logger configuration used when no override is supplied.
const FoxLoggerSettings foxLoggerSettings = FoxLoggerSettings();

enum LogLevel {
  verbose(0, 'VERBOSE', '\x1B[90m'),
  debug(1, 'DEBUG', '\x1B[36m'),
  info(2, 'INFO', '\x1B[32m'),
  warning(3, 'WARNING', '\x1B[33m'),
  error(4, 'ERROR', '\x1B[31m'),
  critical(5, 'CRITICAL', '\x1B[35m');

  const LogLevel(this.priority, this.label, this.ansiColor);

  final int priority;
  final String label;
  final String ansiColor;
}

class FoxLoggerSettings {
  const FoxLoggerSettings({
    this.defaultTitle = 'FoxSDK',
    this.enable = true,
    this.level = LogLevel.verbose,
    this.lineSymbol = '─',
    this.maxLineWidth = 80,
    this.enableColors = true,
  });

  final String defaultTitle;
  final bool enable;
  final LogLevel level;
  final String lineSymbol;
  final int maxLineWidth;
  final bool enableColors;

  FoxLoggerSettings copyWith({
    String? defaultTitle,
    bool? enable,
    LogLevel? level,
    String? lineSymbol,
    int? maxLineWidth,
    bool? enableColors,
  }) {
    return FoxLoggerSettings(
      defaultTitle: defaultTitle ?? this.defaultTitle,
      enable: enable ?? this.enable,
      level: level ?? this.level,
      lineSymbol: lineSymbol ?? this.lineSymbol,
      maxLineWidth: maxLineWidth ?? this.maxLineWidth,
      enableColors: enableColors ?? this.enableColors,
    );
  }
}

class FoxLogRecord {
  const FoxLogRecord({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.source,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final String? source;

  String generateTextMessage() => message;
}

class AppLogger {
  AppLogger({FoxLoggerSettings? settings})
    : settings = settings ?? foxLoggerSettings;

  final StreamController<FoxLogRecord> _controller =
      StreamController<FoxLogRecord>.broadcast();

  /// Exposes the logger settings so consuming projects can customize them.
  FoxLoggerSettings settings;

  Stream<FoxLogRecord> get stream => _controller.stream;

  /// Current log level for this logger.
  LogLevel get level => settings.level;

  set level(LogLevel value) {
    settings = settings.copyWith(level: value);
  }

  DateTime get timestamp => DateTime.now();

  void verbose(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  void trace(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  void debug(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  void info(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  void warning(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void warn(Object? message, [Object? error, StackTrace? stackTrace]) {
    warning(message, error, stackTrace);
  }

  void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void handle(Object error, [StackTrace? stackTrace, String? source]) {
    _log(LogLevel.error, source ?? error, error, stackTrace, source: source);
  }

  void fatal(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.critical, message, error, stackTrace);
  }

  void detail(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  void err(Object? message, [Object? error, StackTrace? stackTrace]) {
    this.error(message, error, stackTrace);
  }

  AppLoggerProgress progress(String message) {
    return AppLoggerProgress(this, message);
  }

  void _log(
    LogLevel level,
    Object? message,
    Object? error,
    StackTrace? stackTrace, {
    String? source,
  }) {
    if (!settings.enable || level.priority < settings.level.priority) {
      return;
    }

    final record = FoxLogRecord(
      timestamp: DateTime.now(),
      level: level,
      message: _formatMessage(message, error, stackTrace),
      error: error,
      stackTrace: stackTrace,
      source: source,
    );
    _controller.add(record);
    stdout.writeln(_formatRecord(record));
  }

  String _formatRecord(FoxLogRecord record) {
    final title = record.source ?? settings.defaultTitle;
    final prefix = '[${record.level.label}] $title: ';
    final text = '$prefix${record.message}';

    if (!settings.enableColors) {
      return text;
    }

    return '${record.level.ansiColor}$text\x1B[0m';
  }

  String _formatMessage(
    Object? message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final buffer = StringBuffer();

    if (message != null) {
      buffer.write(message);
    }

    if (error != null && error != message) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(error);
    }

    if (stackTrace != null) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(stackTrace);
    }

    return buffer.toString();
  }
}

/// Minimal progress handle backed by [AppLogger].
class AppLoggerProgress {
  AppLoggerProgress(this._logger, String message) : _message = message {
    _logger.info(message);
  }

  final AppLogger _logger;
  final String _message;

  void complete([String? message]) {
    _logger.info(message ?? 'Completed: $_message');
  }

  void fail([String? message]) {
    _logger.error(message ?? 'Failed: $_message');
  }
}
