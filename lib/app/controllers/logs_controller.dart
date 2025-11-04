import 'package:acontainer/app/controllers/command_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;

class LogsController extends GetxController {
  final terminal = xterm.Terminal();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void clear() {
    // Send clear screen and reset signals
    terminal.write('\x1b[2J'); // Clear screen
    terminal.write('\x1b[H'); // Reset cursor to top-left
    terminal.write('\x1bc'); // Reset terminal
    terminal.buffer.clear();
    terminal.resize(terminal.viewWidth, terminal.viewHeight);
    errorMessage.value = '';
  }

  void startCommandStream(
    Stream<CommandOutput> stream, {
    VoidCallback? onDone,
    Function(String)? onError,
  }) {
    isLoading.value = true;
    errorMessage.value = '';

    stream.listen(
      (output) {
        String line = output.line;

        if (output.type == OutputType.stdout) {
          // Write stdout normally
          write('$line\n');
        } else if (output.type == OutputType.stderr) {
          // Write stderr in red color
          write('\x1b[31m$line\x1b[0m\n');
        } else if (output.type == OutputType.exitCode) {
          write('\x1b[32mProcess exited with code: $line\x1b[0m\n');
        }
      },
      onError: (error) {
        errorMessage.value = 'Error: $error';
        write('\x1b[31mError: $error\x1b[0m\n');
        isLoading.value = false;
        onError?.call(error.toString());
        onDone?.call();
      },
      onDone: () {
        isLoading.value = false;
        write('\x1b[32m--- Process completed ---\x1b[0m\n');
        onDone?.call();
      },
    );
  }

  void startStream(Stream<String> stream) {
    isLoading.value = true;
    errorMessage.value = '';

    stream.listen(
      (line) {
        write('$line\n');
      },
      onError: (error) {
        errorMessage.value = 'Error: $error';
        isLoading.value = false;
      },
      onDone: () {
        isLoading.value = false;
      },
    );
  }

  void write(String line) {
    line = line.replaceAll('\n', '\r\n');
    terminal.write(line);
  }
}
