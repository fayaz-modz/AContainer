import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;

class TerminalController extends GetxController {
  final DboxController dbox = Get.find<DboxController>();
  final logger = Logger('TerminalController');

  final terminal = xterm.Terminal(
    maxLines: 10000,
    platform: xterm.TerminalTargetPlatform.linux,
  );
  final terminalController = xterm.TerminalController();
  final containerName = ''.obs;
  final pty = ''.obs;
  final isConnected = false.obs;
  final isConnecting = false.obs;
  final errorMessage = ''.obs;
  final terminalSize = Rx<TerminalSize>(TerminalSize(80, 24));

  Pty? _pty;
  String _outputBuffer = '';
  final ctrlPressed = false.obs;
  final altPressed = false.obs;

  @override
  InternalFinalCallback<void> get onDelete {
    // Ensure cleanup when controller is deleted
    return super.onDelete;
  }

  Future<void> connectToContainer() async {
    if (pty.value.isEmpty && containerName.value.isEmpty) {
      errorMessage.value = 'No PTY command or container name provided';
      return;
    }

    if (isConnected.value || isConnecting.value) {
      return;
    }

    isConnecting.value = true;
    errorMessage.value = '';

    try {
      logger.i('Connecting to container: ${containerName.value}');

      // Clear terminal and show connection message
      terminal.buffer.clear();
      if (pty.value.isNotEmpty) {
        terminal.write('Starting PTY: ${pty.value}...\r\n');
      } else {
        terminal.write('Connecting to container ${containerName.value}...\r\n');
      }

      // Start PTY - prioritize custom PTY over container name
      if (pty.value.isNotEmpty) {
        // Use dbox attach method with empty container name and custom shell
        _pty = dbox.attach('', shell: pty.value);
      } else {
        _pty = dbox.attach(containerName.value);
      }

      // Set up terminal output handling
      terminal.onOutput = (data) {
        // Apply modifiers to soft keyboard input
        if (ctrlPressed.value || altPressed.value) {
          String modifiedData = _applyModifiersToInput(data);
          _pty?.write(const Utf8Encoder().convert(modifiedData));
        } else {
          _pty?.write(const Utf8Encoder().convert(data));
        }
      };

      // Set up terminal resize handling
      terminal.onResize = (w, h, pw, ph) {
        _pty?.resize(h, w);
        updateTerminalSize(w, h);
      };

      // Handle PTY output
      _pty!.output
          .cast<List<int>>()
          .transform(Utf8Decoder())
          .listen(
            (data) {
              _interceptClearCommand(data);
              terminal.write(data);
            },
            onError: (error) {
              logger.e('PTY output error: $error');
              terminal.write('\x1b[31mPTY error: $error\x1b[0m\r\n');
            },
          );

      // Handle PTY exit
      _pty!.exitCode
          .then((code) {
            logger.i('PTY exited with code: $code');
            terminal.write(
              '\r\n\x1b[32mConnection closed (exit code: $code)\x1b[0m\r\n',
            );
            isConnected.value = false;
            _pty = null;
          })
          .catchError((error) {
            logger.e('PTY exit error: $error');
            terminal.write('\r\n\x1b[31mConnection error: $error\x1b[0m\r\n');
            isConnected.value = false;
            _pty = null;
          });

      isConnected.value = true;
      isConnecting.value = false;
      terminal.buffer.clear();
      if (pty.value.isNotEmpty) {
        terminal.write(
          '\x1b[32mStarted PTY: ${pty.value}\x1b[0m\r\n',
        );
      } else {
        terminal.write(
          '\x1b[32mConnected to container ${containerName.value}\x1b[0m\r\n',
        );
      }
      terminal.write('Type your commands and press Enter\r\n');
      terminal.write('Use Ctrl+C to exit\r\n\r\n');
    } catch (e, stackTrace) {
      logger.e('Failed to connect to container: $e', e, stackTrace);
      errorMessage.value = 'Failed to connect: $e';
      terminal.write('\r\n\x1b[31mFailed to connect: $e\x1b[0m\r\n');
      isConnecting.value = false;
      isConnected.value = false;
      _pty = null;
    }
  }

  Future<void> disconnect() async {
    if (pty.value.isNotEmpty) {
      logger.i('Closing PTY: ${pty.value}');
    } else if (containerName.value.isNotEmpty) {
      logger.i('Disconnecting from container: ${containerName.value}');
    }

    // Kill PTY gracefully
    if (_pty != null) {
      try {
        _pty!.kill(ProcessSignal.sigkill);
        _pty = null;
      } catch (e) {
        logger.e('Error killing PTY: $e');
      }
    }

    isConnected.value = false;
    isConnecting.value = false;

    terminal.write('\r\n\x1b[33mDisconnected from container\x1b[0m\r\n');
  }

  void handleModifierKey(String key) {
    switch (key) {
      case 'CTRL':
        ctrlPressed.value = !ctrlPressed.value;
        logger.d('CTRL ${ctrlPressed.value ? 'pressed' : 'released'}');
        break;
      case 'ALT':
        altPressed.value = !altPressed.value;
        logger.d('ALT ${altPressed.value ? 'pressed' : 'released'}');
        break;
      default:
        _sendKeyWithModifiers(key);
        break;
    }
  }

  @override
  void onClose() {
    disconnect();
    terminalController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    try {
      // Get container name and PTY command from arguments
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null) {
        containerName.value = args['containerName'] as String? ?? '';
        pty.value = args['pty'] as String? ?? '';
      }

      logger.i(
        'TerminalController initialized for container: ${containerName.value}, PTY: ${pty.value}',
      );

      // Initialize terminal after the frame is rendered
      WidgetsBinding.instance.endOfFrame.then((_) {
        if (pty.value.isNotEmpty || containerName.value.isNotEmpty) {
          connectToContainer();
        } else {
          errorMessage.value = 'No PTY command or container name provided';
          terminal.write(
            '\x1b[31mError: No PTY command or container name provided\x1b[0m\r\n',
          );
        }
      });
    } catch (e) {
      logger.e('Error initializing TerminalController: $e');
      errorMessage.value = 'Initialization error: $e';
      terminal.write('\x1b[31mInitialization error: $e\x1b[0m\r\n');
    }
  }

  void reconnect() {
    disconnect();
    Future.delayed(const Duration(milliseconds: 500), () {
      connectToContainer();
    });
  }

  void updateTerminalSize(int columns, int rows) {
    final newSize = TerminalSize(columns, rows);
    if (terminalSize.value.columns != columns ||
        terminalSize.value.rows != rows) {
      terminalSize.value = newSize;
      terminal.resize(columns, rows);

      // PTY resize is handled by the onResize callback
      logger.i('Terminal resized to ${columns}x$rows');
    }
  }

  String _applyModifiersToInput(String data) {
    if (data.isEmpty) return data;

    String result = '';
    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      int charCode = char.codeUnitAt(0);

      if (ctrlPressed.value && altPressed.value) {
        // Ctrl+Alt combinations
        if (charCode >= 97 && charCode <= 122) {
          // a-z
          charCode = charCode - 96;
          result += String.fromCharCode(charCode);
        } else {
          result += char;
        }
      } else if (ctrlPressed.value) {
        // Ctrl combinations
        if (charCode >= 97 && charCode <= 122) {
          // a-z
          charCode = charCode - 96;
          result += String.fromCharCode(charCode);
        } else if (charCode >= 64 && charCode <= 95) {
          // @ to _
          charCode = charCode - 64;
          result += String.fromCharCode(charCode);
        } else {
          result += char;
        }
      } else if (altPressed.value) {
        // Alt combinations - send ESC prefix
        result += '\x1b$char';
      } else {
        result += char;
      }
    }

    logger.d(
      'Soft keyboard input: "$data" -> modified: "$result" (CTRL:${ctrlPressed.value}, ALT:${altPressed.value})',
    );
    return result;
  }

  void _interceptClearCommand(String data) {
    _outputBuffer += data;

    final clearPattern = RegExp(r'\x1b\[H\x1b\[J');
    final match = clearPattern.firstMatch(_outputBuffer);

    if (match != null) {
      logger.d('CLEAR DETECTED! Sending enhanced clear command');
      terminal.write('\x1b[H\x1b[2J\x1b[3J');
      _outputBuffer = '';
    } else if (_outputBuffer.length > 200) {
      _outputBuffer = _outputBuffer.substring(_outputBuffer.length - 100);
    }
  }

  void _sendKeyWithModifiers(String key) {
    String input = '';

    if (key.length == 1) {
      // Single character with modifiers
      int charCode = key.codeUnitAt(0);

      if (ctrlPressed.value && altPressed.value) {
        // Ctrl+Alt combinations
        if (charCode >= 97 && charCode <= 122) {
          // a-z
          charCode = charCode - 96; // Ctrl+Alt+letter = Ctrl+letter
          input = String.fromCharCode(charCode);
        }
      } else if (ctrlPressed.value) {
        // Ctrl combinations
        if (charCode >= 97 && charCode <= 122) {
          // a-z
          charCode = charCode - 96; // Ctrl+a = 1, Ctrl+b = 2, etc.
          input = String.fromCharCode(charCode);
        } else if (charCode >= 64 && charCode <= 95) {
          // @ to _
          charCode = charCode - 64;
          input = String.fromCharCode(charCode);
        }
      } else if (altPressed.value) {
        // Alt combinations - send ESC prefix
        input = '\x1b$key';
      } else {
        input = key;
      }

      logger.d(
        'Character input: $key (charCode: $charCode) -> input: $input (CTRL:${ctrlPressed.value}, ALT:${altPressed.value})',
      );
    } else {
      // Special keys with modifiers
      switch (key) {
        case 'UP':
          if (ctrlPressed.value) {
            input = '\x1b[1;5A'; // Ctrl+Up
          } else if (altPressed.value) {
            input = '\x1b[1;3A'; // Alt+Up
          } else {
            input = '\x1b[A'; // Up
          }
          break;
        case 'DOWN':
          if (ctrlPressed.value) {
            input = '\x1b[1;5B'; // Ctrl+Down
          } else if (altPressed.value) {
            input = '\x1b[1;3B'; // Alt+Down
          } else {
            input = '\x1b[B'; // Down
          }
          break;
        case 'LEFT':
          if (ctrlPressed.value) {
            input = '\x1b[1;5D'; // Ctrl+Left
          } else if (altPressed.value) {
            input = '\x1b[1;3D'; // Alt+Left
          } else {
            input = '\x1b[D'; // Left
          }
          break;
        case 'RIGHT':
          if (ctrlPressed.value) {
            input = '\x1b[1;5C'; // Ctrl+Right
          } else if (altPressed.value) {
            input = '\x1b[1;3C'; // Alt+Right
          } else {
            input = '\x1b[C'; // Right
          }
          break;
        case 'HOME':
          if (ctrlPressed.value) {
            input = '\x1b[1;5H'; // Ctrl+Home
          } else if (altPressed.value) {
            input = '\x1b[1;3H'; // Alt+Home
          } else {
            input = '\x1b[H'; // Home
          }
          break;
        case 'END':
          if (ctrlPressed.value) {
            input = '\x1b[1;5F'; // Ctrl+End
          } else if (altPressed.value) {
            input = '\x1b[1;3F'; // Alt+End
          } else {
            input = '\x1b[F'; // End
          }
          break;
        case 'PGUP':
          if (ctrlPressed.value) {
            input = '\x1b[5;5~'; // Ctrl+PageUp
          } else if (altPressed.value) {
            input = '\x1b[5;3~'; // Alt+PageUp
          } else {
            input = '\x1b[5~'; // PageUp
          }
          break;
        case 'PGDN':
          if (ctrlPressed.value) {
            input = '\x1b[6;5~'; // Ctrl+PageDown
          } else if (altPressed.value) {
            input = '\x1b[6;3~'; // Alt+PageDown
          } else {
            input = '\x1b[6~'; // PageDown
          }
          break;
        case 'DEL':
          if (ctrlPressed.value) {
            input = '\x1b[3;5~'; // Ctrl+Delete
          } else if (altPressed.value) {
            input = '\x1b[3;3~'; // Alt+Delete
          } else {
            input = '\x1b[3~'; // Delete
          }
          break;
        case 'BKSP':
          if (ctrlPressed.value) {
            input = '\x08'; // Ctrl+Backspace
          } else if (altPressed.value) {
            input = '\x1b\x7f'; // Alt+Backspace
          } else {
            input = '\x7f'; // Backspace
          }
          break;
        case 'TAB':
          if (ctrlPressed.value) {
            input = '\x09'; // Ctrl+Tab
          } else if (altPressed.value) {
            input = '\x1b\t'; // Alt+Tab
          } else {
            input = '\t'; // Tab
          }
          break;
        case 'ENTER':
          if (ctrlPressed.value) {
            input = '\x0d'; // Ctrl+Enter
          } else if (altPressed.value) {
            input = '\x1b\x0d'; // Alt+Enter
          } else {
            input = '\r'; // Enter
          }
          break;
        case 'ESC':
          input = '\x1b'; // Escape
          break;
        default:
          input = key;
          break;
      }
    }

    if (input.isNotEmpty) {
      logger.d(
        'About to send: input="$input" (raw bytes: ${input.codeUnits.map((b) => '0x${b.toRadixString(16)}').join(' ')})',
      );
      terminal.textInput(input);
      logger.d(
        'Sent key: $key with modifiers (CTRL:${ctrlPressed.value}, ALT:${altPressed.value}) = $input',
      );
    }
  }
}

class TerminalSize {
  final int columns;
  final int rows;

  const TerminalSize(this.columns, this.rows);

  @override
  int get hashCode => columns.hashCode ^ rows.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TerminalSize &&
        other.columns == columns &&
        other.rows == rows;
  }

  @override
  String toString() => 'TerminalSize(${columns}x$rows)';
}
