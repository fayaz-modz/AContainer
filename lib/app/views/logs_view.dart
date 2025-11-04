import 'package:acontainer/app/controllers/logs_controller.dart';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;

import 'package:get/get.dart';

class LogsView extends GetView<LogsController> {
  final LogsController? customController;
  final VoidCallback? onClose;
  final VoidCallback? onClear;
  const LogsView({
    super.key,
    this.customController,
    this.onClose,
    this.onClear,
  });

  @override
  LogsController get controller => customController ?? super.controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header with loading indicator and controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Obx(
                () => controller.isLoading.value
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.terminal,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                'Terminal',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Clear button
              IconButton(
                icon: const Icon(Icons.cleaning_services_outlined),
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
                tooltip: 'Clear terminal',
                iconSize: 18,
                color: colorScheme.onSurfaceVariant,
                splashRadius: 16,
              ),
              // Stop button
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.stop_outlined),
                  onPressed: onClose,
                  tooltip: 'Stop logs process',
                  iconSize: 18,
                  color: colorScheme.onSurfaceVariant,
                  splashRadius: 16,
                ),
            ],
          ),
        ),

        // Error message
        Obx(
          () => controller.errorMessage.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Terminal view
        Expanded(
          child: ClipRect(
            child: xterm.TerminalView(
              controller.terminal,
              hardwareKeyboardOnly: true,
            ),
          ),
        ),
      ],
    );
  }
}
