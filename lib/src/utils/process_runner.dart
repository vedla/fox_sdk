import 'dart:io';

/// Abstraction over starting external processes so tests can inject fakes.
abstract class ProcessRunner {
  /// Runs [executable] with [args] in [workingDirectory]. Returns the
  /// process exit code.
  Future<int> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    ProcessStartMode mode = ProcessStartMode.normal,
  });
}

/// Default implementation that delegates to `Process.start`.
class DefaultProcessRunner implements ProcessRunner {
  const DefaultProcessRunner();

  @override
  Future<int> run(
    String executable,
    List<String> args, {
    String? workingDirectory,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    final process = await Process.start(
      executable,
      args,
      mode: mode,
      workingDirectory: workingDirectory,
    );

    return process.exitCode;
  }
}
