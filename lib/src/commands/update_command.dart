import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fox_sdk/src/command_runner.dart';
import 'package:fox_sdk/src/utils/app_logger.dart';
import 'package:fox_sdk/src/version.dart';
import 'package:pub_updater/pub_updater.dart';

/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({required AppLogger logger, PubUpdater? pubUpdater})
    : _logger = logger,
      _pubUpdater = pubUpdater ?? PubUpdater();

  final AppLogger _logger;
  final PubUpdater _pubUpdater;

  @override
  String get description => 'Update the CLI.';

  /// The name of the command.
  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final updateCheckProgress = _logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(packageName);
    } on Exception catch (error) {
      updateCheckProgress.fail();
      _logger.error('$error');
      return exitCodeSoftware;
    }
    updateCheckProgress.complete('Checked for updates');

    final isUpToDate = packageVersion == latestVersion;
    if (isUpToDate) {
      _logger.info('CLI is already at the latest version.');
      return exitCodeSuccess;
    }

    final updateProgress = _logger.progress('Updating to $latestVersion');

    late final ProcessResult result;
    try {
      result = await _pubUpdater.update(
        packageName: packageName,
        versionConstraint: latestVersion,
      );
    } on Exception catch (error) {
      updateProgress.fail();
      _logger.error('$error');
      return exitCodeSoftware;
    }

    if (result.exitCode != exitCodeSuccess) {
      updateProgress.fail();
      _logger.error('Error updating CLI: ${result.stderr}');
      return exitCodeSoftware;
    }

    updateProgress.complete('Updated to $latestVersion');

    return exitCodeSuccess;
  }
}
