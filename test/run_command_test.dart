import 'package:test/test.dart';
import 'package:vedla_cli/src/command_runner.dart';

void main() {
  group('VedlaCliCommandRunner', () {
    test('registers run and update commands', () {
      final runner = VedlaCliCommandRunner();

      expect(runner.commands.containsKey('run'), isTrue);
      expect(runner.commands.containsKey('update'), isTrue);
    });

    test('parses flavour alias into flavor option', () {
      final runner = VedlaCliCommandRunner();
      final results = runner.parse(['run', '--flavour', 'development']);

      final command = results.command!;
      expect(command['flavor'], equals('development'));
    });

    test('accepts explicit target option', () {
      final runner = VedlaCliCommandRunner();
      final results = runner.parse(['run', '--target', 'lib/main_dev.dart']);

      final command = results.command!;
      expect(command['target'], equals('lib/main_dev.dart'));
    });

    test('accepts platform desktop value', () {
      final runner = VedlaCliCommandRunner();
      final results = runner.parse(['run', '--platform', 'desktop']);

      final command = results.command!;
      expect(command['platform'], equals('desktop'));
    });
  });
}
