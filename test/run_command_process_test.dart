import 'dart:io';

import 'package:test/test.dart';
import 'package:vedla_cli/src/command_runner.dart';
import 'package:vedla_cli/src/commands/run_command.dart';
import 'package:vedla_cli/src/utils/process_runner.dart';

class FakeProcessRunner implements ProcessRunner {
  late String executable;
  late List<String> args;
  String? workingDirectory;
  ProcessStartMode? mode;
  final int exitCodeToReturn;

  FakeProcessRunner({this.exitCodeToReturn = 0});

  @override
  Future<int> run(
    String exe,
    List<String> a, {
    String? workingDirectory,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    executable = exe;
    args = List<String>.from(a);
    this.workingDirectory = workingDirectory;
    this.mode = mode;
    return exitCodeToReturn;
  }
}

void main() {
  group('RunCommand integration (fake process)', () {
    test('constructs flutter args and uses working directory', () async {
      final tmp = await Directory.systemTemp.createTemp('vedla_cli_test_');
      try {
        // Create a dummy pubspec and lib/main.dart so RunCommand finds them
        final pubspec = File('${tmp.path}/pubspec.yaml');
        pubspec.writeAsStringSync('name: test_app');

        final libDir = Directory('${tmp.path}/lib')..createSync();
        final mainFile = File('${libDir.path}/main.dart');
        mainFile.writeAsStringSync('// main');

        final fake = FakeProcessRunner();
        final runCmd = RunCommand(processRunner: fake);
        final runner = VedlaCliCommandRunner(runCommand: runCmd);

        final exit = await runner.run([
          'run',
          '--path',
          tmp.path,
          '--flavour',
          'dev',
          '--platform',
          'web',
        ]);

        expect(exit, equals(0));
        expect(fake.executable, equals('flutter'));
        // Expect args to include run, -d, chrome, --flavor, dev and --target lib/main.dart
        expect(
          fake.args,
          containsAll([
            'run',
            '-d',
            'chrome',
            '--flavor',
            'dev',
            '--target',
            'lib/main.dart',
          ]),
        );
        expect(fake.workingDirectory, equals(tmp.path));
        expect(fake.mode, equals(ProcessStartMode.inheritStdio));
      } finally {
        await tmp.delete(recursive: true);
      }
    });
  });
}
