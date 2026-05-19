import 'dart:io';

import 'package:fox_sdk/src/command_runner.dart';
import 'package:fox_sdk/src/commands/run_command.dart';
import 'package:test/test.dart';

class FakeProcessRunner {
  FakeProcessRunner({this.exitCodeToReturn = 0});

  late String executable;
  late List<String> args;
  String? workingDirectory;
  ProcessStartMode? mode;
  final int exitCodeToReturn;

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
      final tmp = await Directory.systemTemp.createTemp('fox_sdk_test_');
      try {
        // Create a dummy pubspec and lib/main.dart so RunCommand finds them
        File('${tmp.path}/pubspec.yaml').writeAsStringSync('name: test_app');

        final libDir = Directory('${tmp.path}/lib')..createSync();
        File('${libDir.path}/main.dart').writeAsStringSync('// main');

        final fake = FakeProcessRunner();
        final runCmd = RunCommand(processRunner: fake.run);
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
