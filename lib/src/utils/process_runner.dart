import 'dart:io';

/// Runs [executable] with [args] in [workingDirectory]. Returns the process
/// exit code.
typedef ProcessRunner =
    Future<int> Function(
      String executable,
      List<String> args, {
      String? workingDirectory,
      ProcessStartMode mode,
    });

/// Default implementation that delegates to `Process.start`.
Future<int> defaultProcessRunner(
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
