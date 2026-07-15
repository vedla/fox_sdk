import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:fox_sdk/src/utils/flutter_platforms.dart';
// import 'package:fox_sdk/src/utils/platforms.dart';
import 'package:fox_sdk/src/utils/process_runner.dart';

/// {@template run_command}
/// A command which runs a Flutter app from either:
/// - the current directory
/// - a provided project path
/// - a monorepo app/package
/// {@endtemplate}
class RunCommand extends Command<int> {
  /// {@macro run_command}
  RunCommand({ProcessRunner? processRunner})
    : _processRunner = processRunner ?? defaultProcessRunner {
    argParser
      ..addOption('project', abbr: 'p')
      ..addOption('path')
      ..addOption(
        'target',
        help:
            'The main entrypoint file to run (e.g. lib/main_development.dart).',
      )
      ..addOption('flavor', aliases: ['flavour'], help: 'Build flavor.')
      ..addOption('profile', allowed: ['debug', 'profile', 'release'])
      ..addOption(
        'platform',

        allowed: [
          'macos',

          'windows',

          'linux',

          'android',

          'ios',

          'web',

          'desktop',
        ],
      );
  }

  String? get _projectName => argResults?['project'] as String?;
  String? get _projectPath => argResults?['path'] as String?;
  String? get _target => argResults?['target'] as String?;
  String? get _profile => argResults?['profile'] as String?;
  String? get _flavor => argResults?['flavor'] as String?;

  FlutterPlatforms? get _platform {
    final platformArg = argResults?['platform'] as String?;
    return platformArg == null
        ? null
        : FlutterPlatforms.values.byName(platformArg);
  }

  /// The name of the command.
  static const String commandName = 'run';

  @override
  String get name => commandName;

  @override
  String get description => 'Run the app on the project directory or monorepo.';

  @override
  Future<int> run() async {
    final platform = _platform ?? FlutterPlatforms.macos;

    final resolvedDevice = _resolveDevice(platform);

    final workingDirectory = await _resolveWorkingDirectory();
    final flavor = _flavor;
    final target = _target;
    final resolvedTarget = _resolveTarget(workingDirectory, flavor, target);
    final flavorArgs = flavor == null
        ? const <String>[]
        : <String>['--flavor', flavor];
    final targetArgs = resolvedTarget == null
        ? const <String>[]
        : <String>['--target', resolvedTarget];

    stdout
      ..writeln('Running Flutter app...')
      ..writeln('Directory: $workingDirectory')
      ..writeln('Device: $resolvedDevice');

    final flutterArgs = <String>[
      'run',
      '-d',
      resolvedDevice,
      if (_profile == 'profile') '--profile',
      if (_profile == 'release') '--release',
      ...flavorArgs,
      ...targetArgs,
    ];

    final exitCode = await _processRunner(
      'flutter',
      flutterArgs,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.inheritStdio,
    );

    return exitCode;
  }

  /// Resolves Flutter device identifier.
  String _resolveDevice(FlutterPlatforms platform) {
    if (platform != FlutterPlatforms.ios &&
        platform != FlutterPlatforms.android) {
      return switch (Platform.operatingSystem) {
        'macos' => FlutterPlatforms.macos.name,
        'windows' => FlutterPlatforms.windows.name,
        'linux' => FlutterPlatforms.linux.name,
        _ => throw UnsupportedError(
          'Unsupported desktop OS: ${Platform.operatingSystem}',
        ),
      };
    }

    if (platform == FlutterPlatforms.web) {
      return 'chrome';
    }

    return platform.name;
  }

  /// Attempts to resolve the Flutter working directory.
  ///
  /// Resolution order:
  /// 1. Explicit project path
  /// 2. Current directory (only if no project name specified)
  /// 3. Monorepo lookup
  Future<String> _resolveWorkingDirectory() async {
    if (_projectPath != null) {
      final explicitDirectory = Directory(_projectPath!);

      if (!explicitDirectory.existsSync()) {
        throw Exception(
          'Project path does not exist: ${explicitDirectory.path}',
        );
      }

      if (!_containsPubspec(explicitDirectory)) {
        throw Exception('No pubspec.yaml found in: ${explicitDirectory.path}');
      }

      return explicitDirectory.path;
    }

    final currentDirectory = Directory.current;

    // Single Flutter project (only if no project name specified)
    if (_projectName == null && _containsPubspec(currentDirectory)) {
      return currentDirectory.path;
    }

    // Monorepo support
    final monorepoPath = _findMonorepoProject(currentDirectory);

    if (monorepoPath != null) {
      return monorepoPath;
    }

    throw Exception(
      'Unable to locate a Flutter project from: ${currentDirectory.path}',
    );
  }

  /// Searches common monorepo locations.
  String? _findMonorepoProject(Directory start) {
    final candidates = <String>['apps', 'packages', 'examples', 'example'];

    var dir = start;

    // Walk up the directory tree looking for common monorepo candidate folders.
    while (true) {
      for (final candidate in candidates) {
        final candidateDir = Directory('${dir.path}/$candidate');

        if (!candidateDir.existsSync()) continue;

        final entities = candidateDir.listSync();

        for (final entity in entities) {
          if (entity is! Directory) continue;

          if (!_containsPubspec(entity)) continue;

          if (_projectName == null) return entity.path;

          final dirName = entity.uri.pathSegments.last;
          if (dirName == _projectName) return entity.path;

          final pubspecFile = File('${entity.path}/pubspec.yaml');
          try {
            final content = pubspecFile.readAsStringSync();
            for (final line in content.split('\n')) {
              final trimmed = line.trim();
              if (!trimmed.startsWith('name:')) continue;
              var nameValue = trimmed.substring('name:'.length).trim();
              if ((nameValue.startsWith('"') && nameValue.endsWith('"')) ||
                  (nameValue.startsWith("'") && nameValue.endsWith("'"))) {
                nameValue = nameValue.substring(1, nameValue.length - 1);
              }
              if (nameValue == _projectName) return entity.path;
              break;
            }
          } on FileSystemException {
            // ignore file system errors when reading pubspec
          }
        }
      }

      final parent = Directory(dir.parent.path);
      if (parent.path == dir.path) break;
      dir = parent;
    }

    return null;
  }

  /// Resolves the Dart entrypoint to run.
  ///
  /// If a flavor is provided, prefer `lib/main_<flavor>.dart`.
  /// Fall back to `lib/main.dart` when the flavor-specific file does not exist.
  String? _resolveTarget(
    String workingDirectory,
    String? flavor,
    String? explicitTarget,
  ) {
    if (explicitTarget != null) {
      return explicitTarget;
    }

    if (flavor == null) {
      return null;
    }

    final flavoredTarget = 'lib/main_$flavor.dart';
    final flavoredTargetFile = File('$workingDirectory/$flavoredTarget');

    if (flavoredTargetFile.existsSync()) {
      return flavoredTarget;
    }

    const defaultTarget = 'lib/main.dart';
    final defaultTargetFile = File('$workingDirectory/$defaultTarget');

    if (defaultTargetFile.existsSync()) {
      return defaultTarget;
    }

    return null;
  }

  /// Checks if a directory contains a Flutter pubspec.
  bool _containsPubspec(Directory directory) {
    final pubspec = File('${directory.path}/pubspec.yaml');

    return pubspec.existsSync();
  }

  final ProcessRunner _processRunner;
}
