import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../controllers/terminal_controller.dart';

class TerminalView extends GetView<TerminalController> {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.disconnect();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Terminal
              Expanded(
                child: xterm.TerminalView(
                  controller.terminal,
                  controller: controller.terminalController,
                  autofocus: true,
                  backgroundOpacity: 0.7,
                  onSecondaryTapDown: (details, offset) async {
                    final selection = controller.terminalController.selection;
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
              // Extra keys row
              Container(
                color: colorScheme.surfaceContainerHighest,
                child: Column(
                  children: [
                    _buildExtraKeysRow(
                      ['ESC', '/', '-', 'HOME', 'UP', 'END', 'PGUP'],
                      theme,
                      colorScheme,
                    ),
                    _buildExtraKeysRow(
                      ['TAB', 'CTRL', 'ALT', 'LEFT', 'DOWN', 'RIGHT', 'PGDN'],
                      theme,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraKeysRow(
    List<String> keys,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        children: keys
            .map((key) => _buildExtraKey(key, theme, colorScheme))
            .toList(),
      ),
    );
  }

  Widget _buildExtraKey(String key, ThemeData theme, ColorScheme colorScheme) {
    return Obx(() {
      final isCtrlActive = controller.ctrlPressed.value;
      final isAltActive = controller.altPressed.value;
      bool isActive = false;
      
      if (key == 'CTRL') {
        isActive = isCtrlActive;
      } else if (key == 'ALT') {
        isActive = isAltActive;
      }
      
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: GestureDetector(
            onTap: () => _handleKeyPress(key),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive 
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isActive 
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Text(
                key,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive 
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
}
