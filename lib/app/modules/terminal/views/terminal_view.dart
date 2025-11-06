import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../controllers/terminal_controller.dart';

class TerminalView extends GetView<TerminalController> {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final terminalTheme = controller.terminalThemeController.terminalTheme;

      // Apply system UI styling to match terminal theme after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyTerminalSystemUiStyle(terminalTheme);
      });

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.disconnect();
            // Reset system UI styling when leaving terminal
            _resetSystemUiStyle();
          }
        },
        child: Scaffold(
          backgroundColor: terminalTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                // Output paused indicator
                Obx(
                  () => controller.isOutputPaused.value
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.orange,
                          child: Text(
                            'OUTPUT PAUSED (Press Ctrl+Q to resume)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                Expanded(
                  child: GestureDetector(
                    onScaleStart: (details) {
                      controller.initialFontSize =
                          controller.fontSizeNotifier.value;
                    },
                    onScaleUpdate: (details) {
                      final newFontSize =
                          controller.initialFontSize * details.scale;
                      controller.fontSizeNotifier.value = newFontSize.clamp(
                        8.0,
                        24.0,
                      );
                    },
                    child: xterm.TerminalView(
                      key: Key('term'),
                      controller.terminal,
                      controller: controller.terminalController,
                      simulateScroll: false,
                      backgroundOpacity: 1.0,
                      theme: controller.terminalThemeController.terminalTheme,
                      textStyle: xterm.TerminalStyle(
                        fontSize: controller.fontSizeNotifier.value,
                        fontFamily: 'JetBrains Mono',
                      ),
                      onSecondaryTapDown: (details, offset) async {
                        final selection =
                            controller.terminalController.selection;
                        if (selection != null) {
                          final text = controller.terminal.buffer.getText(
                            selection,
                          );
                          controller.terminalController.clearSelection();
                          await Clipboard.setData(ClipboardData(text: text));
                        } else {
                          final data = await Clipboard.getData('text/plain');
                          final text = data?.text;
                          if (text != null) {
                            controller.terminal.paste(text);
                          }
                        }
                      },
                    ),
                  ),
                ),
                // Extra keys row
                Container(
                  color: terminalTheme.background,
                  child: Column(
                    children: [
                      _buildExtraKeysRow([
                        'ESC',
                        '/',
                        '-',
                        'HOME',
                        'UP',
                        'END',
                        'PGUP',
                      ], terminalTheme),
                      _buildExtraKeysRow([
                        'TAB',
                        'CTRL',
                        'ALT',
                        'LEFT',
                        'DOWN',
                        'RIGHT',
                        'PGDN',
                      ], terminalTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExtraKeysRow(
    List<String> keys,
    xterm.TerminalTheme terminalTheme,
  ) {
    return Row(
      children: keys.map((key) => _buildExtraKey(key, terminalTheme)).toList(),
    );
  }

  Widget _buildExtraKey(String key, xterm.TerminalTheme terminalTheme) {
    return Obx(() {
      final isCtrlActive = controller.ctrlPressed.value;
      final isAltActive = controller.altPressed.value;
      bool isActive = false;

      if (key == 'CTRL') {
        isActive = isCtrlActive;
      } else if (key == 'ALT') {
        isActive = isAltActive;
      }

      // Convert key names to display symbols
      String displayKey = key;
      switch (key) {
        case 'UP':
          displayKey = '↑';
          break;
        case 'DOWN':
          displayKey = '↓';
          break;
        case 'LEFT':
          displayKey = '←';
          break;
        case 'RIGHT':
          displayKey = '→';
          break;
      }

      // Use terminal theme colors dynamically
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: GestureDetector(
            onTap: () => _handleKeyPress(key),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? terminalTheme.red : terminalTheme.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                displayKey,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? terminalTheme.background
                      : terminalTheme.foreground,
                  fontFamily: 'monospace',
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _handleKeyPress(String key) {
    controller.handleModifierKey(key);
  }

  void _applyTerminalSystemUiStyle(xterm.TerminalTheme terminalTheme) {
    // Determine if the terminal theme is dark or light based on background brightness
    final isDarkTheme = terminalTheme.background.computeLuminance() < 0.5;
    Logger.dS('terminal dark theme $isDarkTheme');

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: terminalTheme.background,
        statusBarIconBrightness: isDarkTheme
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: terminalTheme.background,
        systemNavigationBarIconBrightness: isDarkTheme
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void _resetSystemUiStyle() {
    // Reset to default system UI styling based on current app theme
    final brightness = Theme.of(Get.context!).brightness;
    final surfaceColor = Theme.of(Get.context!).colorScheme.surface;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}
