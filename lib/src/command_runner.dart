/// The main command runner for the vedla CLI application.
library;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:fox_sdk/src/commands/commands.dart';
import 'package:fox_sdk/src/utils/app_logger.dart';
import 'package:fox_sdk/src/version.dart';
import 'package:pub_updater/pub_updater.dart';

/// The executable name for the CLI.
const executableName = 'fox';

/// The pub package name.
const packageName = 'fox_sdk';

/// The top-level description shown in `fox --help`.
const description = 'Fox SDK for Flutter';

const int exitCodeSuccess = 0;
const int exitCodeUsage = 64;
const int exitCodeSoftware = 70;

/// {@template fox_sdk_command_runner}
/// A [CommandRunner] for the CLI.
///
/// ```bash
/// $ fox --version
/// ```
/// {@endtemplate}
class VedlaCliCommandRunner extends CompletionCommandRunner<int> {
  /// {@macro fox_sdk_command_runner}
  VedlaCliCommandRunner({
    AppLogger? logger,
    PubUpdater? pubUpdater,
    // Allow injecting command instances for testing
    Command<int>? runCommand,
    Command<int>? updateCommand,
  }) : _logger = logger ?? foxLogger,
       _pubUpdater = pubUpdater ?? PubUpdater(),
       super(executableName, description) {
    // Add root options and flags
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );

    // Add sub commands (allow injection for tests)
    addCommand(runCommand ?? RunCommand());
    addCommand(
      updateCommand ?? UpdateCommand(logger: _logger, pubUpdater: _pubUpdater),
    );
  }

  @override
  void printUsage() => _logger.info(usage);

  final AppLogger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = LogLevel.verbose;
      }
      return await runCommand(topLevelResults) ?? exitCodeSuccess;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..error(e.message)
        ..error('$stackTrace')
        ..info('')
        ..info(usage);
      return exitCodeUsage;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..error(e.message)
        ..info('')
        ..info(e.usage);
      return exitCodeUsage;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return exitCodeSuccess;
    }

    // Verbose logs
    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }
    }

    // Run the command or show version
    final int? exitCode;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = exitCodeSuccess;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    // Check for updates
    if (topLevelResults.command?.name != UpdateCommand.commandName) {
      await _checkForUpdates();
    }

    return exitCode;
  }

  /// Checks if the current version (set by the build runner on the
  /// version.dart file) is the most recent one. If not, show a prompt to the
  /// user.
  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate) {
        _logger
          ..info('')
          ..info(
            'Update available! $packageVersion -> $latestVersion\n'
            'Run $executableName update to update',
          );
      }
    } on Exception catch (_) {
      _logger.error('Failed to check for updates.');
    }
  }
}
