import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:acontainer/app/utils/logger.dart';
import 'package:get/get.dart';

/// Type of command output
enum OutputType { stdout, stderr, exitCode }

/// Single line of output with type
class CommandOutput {
  final OutputType type;
  final String line;

  CommandOutput(this.type, this.line);

  @override
  String toString() => '[${type.name}] $line';
}

/// Non-streaming command result with outputs and exit code
class CommandResult {
  final List<CommandOutput> outputs;
  final int exitCode;

  CommandResult({required this.outputs, required this.exitCode});
}

/// Controller to run commands safely with logging
class CommandController extends GetxController {
  static final Logger logger = Logger('Command');

  /// Split command into executable + args
  static List<String> _splitCommand(String command) {
    final parts = command
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) throw ArgumentError('Command cannot be empty');
    return parts;
  }

  /// Run a command and get outputs + exit code
  static Future<CommandResult> run(String command) async {
    final parts = _splitCommand(command);
    final executable = parts.first;
    final args = parts.skip(1).toList();

    logger.i('Running command: $command');

    try {
      final result = await Process.run(executable, args);

      final outputs = <CommandOutput>[];

      final stdoutText = result.stdout.toString().trim();
      final stderrText = result.stderr.toString().trim();

      if (stdoutText.isNotEmpty) {
        outputs.addAll(
          stdoutText
              .split('\n')
              .map((line) => CommandOutput(OutputType.stdout, line)),
        );
        logger.d('STDOUT:\n$stdoutText');
      }

      if (stderrText.isNotEmpty) {
        outputs.addAll(
          stderrText
              .split('\n')
              .map((line) => CommandOutput(OutputType.stderr, line)),
        );
        logger.e('STDERR:\n$stderrText');
      }

      logger.i('Exit code: ${result.exitCode}');
      return CommandResult(outputs: outputs, exitCode: result.exitCode);
    } catch (e, st) {
      logger.e('Failed to run command', e, st);
      rethrow;
    }
  }

  /// Run a root command and get outputs + exit code
  static Future<CommandResult> runRoot(String command) async {
    logger.i('Running root command: $command');

    try {
      final result = await Process.run('su', ['-c', command]);

      final outputs = <CommandOutput>[];

      final stdoutText = result.stdout.toString().trim();
      final stderrText = result.stderr.toString().trim();

      if (stdoutText.isNotEmpty) {
        outputs.addAll(
          stdoutText
              .split('\n')
              .map((line) => CommandOutput(OutputType.stdout, line)),
        );
        logger.d('ROOT STDOUT:\n$stdoutText');
      }

      if (stderrText.isNotEmpty) {
        outputs.addAll(
          stderrText
              .split('\n')
              .map((line) => CommandOutput(OutputType.stderr, line)),
        );
        logger.e('ROOT STDERR:\n$stderrText');
      }

      logger.i('Exit code: ${result.exitCode}');
      return CommandResult(outputs: outputs, exitCode: result.exitCode);
    } catch (e, st) {
      logger.e('Failed to run root command', e, st);
      rethrow;
    }
  }

  /// Run a command and yield outputs as stream, including exit code
  static Stream<CommandOutput> runStream(String command) async* {
    final parts = _splitCommand(command);
    final executable = parts.first;
    final args = parts.skip(1).toList();

    logger.i('Running command (stream): $command');

    try {
      final process = await Process.start(executable, args, runInShell: false);
      final controller = StreamController<CommandOutput>();

      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            logger.d('[stdout] $line');
            controller.add(CommandOutput(OutputType.stdout, line));
          }, onError: controller.addError);

      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            logger.e('[stderr] $line');
            controller.add(CommandOutput(OutputType.stderr, line));
          }, onError: controller.addError);

      process.exitCode.then((code) {
        logger.i('Process exited with code: $code');
        controller.add(CommandOutput(OutputType.exitCode, code.toString()));
        controller.close();
      });

      yield* controller.stream;
    } catch (e, st) {
      logger.e('Error running command (stream)', e, st);
      rethrow;
    }
  }

  /// Run a root command and yield outputs as stream, including exit code
  static Stream<CommandOutput> runRootStream(String command) async* {
    logger.i('Running root command (stream): $command');

    try {
      final process = await Process.start('su', ['-c', command]);
      final controller = StreamController<CommandOutput>();

      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            logger.d('[root stdout] $line');
            controller.add(CommandOutput(OutputType.stdout, line));
          }, onError: controller.addError);

      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            logger.e('[root stderr] $line');
            controller.add(CommandOutput(OutputType.stderr, line));
          }, onError: controller.addError);

      process.exitCode.then((code) {
        logger.i('Root process exited with code: $code');
        controller.add(CommandOutput(OutputType.exitCode, code.toString()));
        controller.close();
      });

      yield* controller.stream;
    } catch (e, st) {
      logger.e('Error running root stream command', e, st);
      rethrow;
    }
  }
}
