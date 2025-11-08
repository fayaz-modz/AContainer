import 'package:acontainer/app/modules/terminal/views/terminal_view.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/controllers/terminal_session_controller.dart';
import 'package:acontainer/app/views/logs_view.dart';
import 'package:acontainer/app/widgets/exec_presets_dialog.dart';
import 'package:acontainer/app/modules/terminal/controllers/terminal_controller.dart';

import '../controllers/container_detail_controller.dart';

class ContainerDetailView extends GetView<ContainerDetailController> {
  const ContainerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final dboxController = Get.find<DboxController>();
    // final logger = Logger('ContainerDetailView');

    // Debug: Check if controller is properly initialized
    // logger.d(
    //   'ContainerDetailView - build: controller.containerName = ${controller.containerName.value}',
    // );
    // logger.d('ContainerDetailView - build: Get.arguments = ${Get.arguments}');

    // Manually initialize the controller if it hasn't been initialized
    if (controller.containerName.value.isEmpty && Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      controller.containerName.value = args['containerName'] as String? ?? '';
      controller.containerInfo.value = args['container'] as ContainerInfo?;
      controller.showCreationLogs.value =
          args['showCreationLogs'] as bool? ?? false;

      // logger.d('ContainerDetailView - manual initialization:');
      // logger.d('  containerName: ${controller.containerName.value}');
      // logger.d('  containerInfo: ${controller.containerInfo.value}');
      // logger.d('  containerInfo.name: ${controller.containerInfo.value?.name}');
      // logger.d('  containerInfo.image: ${controller.containerInfo.value?.image}');
      // logger.d('  containerInfo.state: ${controller.containerInfo.value?.state}');

      if (controller.containerName.value.isNotEmpty) {
        controller.loadContainerStatus();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.containerName.value.isEmpty
                ? 'Container Details'
                : controller.containerName.value,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final containerInfo = controller.containerInfo.value;
            final status = controller.containerStatus.value;
            final currentState =
                status?.status ??
                containerInfo?.state ??
                ContainerState.stopped;

            return IconButton(
              onPressed: currentState != ContainerState.creating
                  ? controller.editContainer
                  : null,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Container',
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(dboxController, context),
            const SizedBox(height: 24),
            _buildActionsHeader(context),
            const SizedBox(height: 24),
            _buildLogsHeader(context),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
    DboxController dboxController,
    BuildContext context,
  ) {
    final logger = Logger('ContainerDetailView');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Container Status',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final containerInfo = controller.containerInfo.value;
          final status = controller.containerStatus.value;
          final isLoading = controller.isLoading.value;

          // Debug logging
          logger.d('ContainerDetailView - _buildStatusHeader:');
          logger.d('  containerInfo: $containerInfo');
          logger.d('  status: $status');
          logger.d('  isLoading: $isLoading');

          // Use refreshed status for current state, fall back to container info
          final displayName =
              status?.name ??
              containerInfo?.name ??
              controller.containerName.value;
          final displayImage =
              status?.image ?? containerInfo?.image ?? 'Unknown';
          final displayState =
              status?.status ?? containerInfo?.state ?? ContainerState.stopped;

          logger.d('  displayName: $displayName');
          logger.d('  displayImage: $displayImage');
          logger.d('  displayState: $displayState');

          if (isLoading && status == null && containerInfo == null) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(displayState, colorScheme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayState.displayName.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getStatusColor(
                                  displayState,
                                  colorScheme,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 12),

                  // Status details
                  _buildStatusDetailRow('Image', displayImage, context),
                  if (status?.logFile != null)
                    _buildStatusDetailRow(
                      'Log File',
                      status!.logFile!,
                      context,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusDetailRow(
    String label,
    String value,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final containerInfo = controller.containerInfo.value;
          final status = controller.containerStatus.value;
          final isLoading = controller.isLoading.value;

          // Use container info for current state, fall back to status if available
          final currentState =
              status?.status ?? containerInfo?.state ?? ContainerState.stopped;
          final isRunning = currentState == ContainerState.running;

          return Column(
            children: [
              // Primary action button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isRunning) {
                            controller.stopContainer();
                          } else {
                            controller.startContainer();
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: isRunning ? colorScheme.error : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isRunning ? Icons.stop : Icons.play_arrow, size: 18),
                      const SizedBox(width: 8),
                      Text(isRunning ? 'Stop Container' : 'Start Container'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Secondary actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.refreshStatus,
                      child: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isRunning
                          ? () {
                              final sessionController =
                                  Get.find<TerminalSessionController>();
                              final containerInfo =
                                  controller.containerInfo.value ??
                                  ContainerInfo(
                                    name: controller.containerName.value,
                                    image: 'unknown',
                                    state: currentState,
                                    created: DateTime.now().toIso8601String(),
                                  );

                              final session = sessionController
                                  .getOrCreateSession(containerInfo);

                              Get.to(
                                () => TerminalView(
                                  terminalController: session.controller,
                                ),
                                transition: Transition.rightToLeft,
                              );
                            }
                          : null,
                      child: Text(
                        'Attach',
                        style: TextStyle(
                          color: isRunning
                              ? null
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showExecDialog(context),
                      icon: const Icon(Icons.code, size: 16),
                      label: const Text('Exec'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => controller.recreateContainer(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Recreate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => controller.deleteContainer(),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Info text
              Card(
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isRunning
                              ? 'Click Attach to open a full-screen terminal connection'
                              : 'Start container to enable terminal attachment',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _showExecDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExecPresetsDialog(
        containerName: controller.containerName.value,
        onExecSelected: (command) => _executeCommand(command),
      ),
    );
  }

  void _executeCommand(String command) {
    final sessionController = Get.find<TerminalSessionController>();
    final containerInfo =
        controller.containerInfo.value ??
        ContainerInfo(
          name: controller.containerName.value,
          image: controller.containerInfo.value?.image ?? 'unknown',
          state: ContainerState.running,
          created: DateTime.now().toIso8601String(),
        );

    // Create a new terminal controller for this exec session
    final terminalController = TerminalController();
    terminalController.closeOnPageClose.value = false;

    // Set the container name and PTY command BEFORE initialization
    terminalController.containerName.value = containerInfo.name;
    terminalController.pty.value = command;
    Logger.eS('Executing command: $command ${terminalController.pty.value}');

    // Create a session for this exec command
    final session = TerminalSession(
      id: DateTime.now().millisecondsSinceEpoch % 256,
      container: containerInfo,
      controller: terminalController,
    );

    // Add to sessions and navigate to terminal
    sessionController.sessions[session.id] = session;

    // Initialize controller after setting values
    terminalController.onInit();

    controller.logger.d(
      'Navigating to terminal view for exec command: $command',
    );
    Get.to(
      () => TerminalView(terminalController: terminalController),
      transition: Transition.rightToLeft,
    )?.then((_) {
      controller.logger.d('Returned from terminal view');
    });
  }

  Color _getStatusColor(ContainerState state, ColorScheme colorScheme) {
    switch (state) {
      case ContainerState.running:
        return Colors.green;
      case ContainerState.stopped:
        return colorScheme.error;
      case ContainerState.exited:
        return colorScheme.error;
      case ContainerState.creating:
        return Colors.orange;
      case ContainerState.ready:
        return Colors.blue;
      case ContainerState.created:
        return colorScheme.secondary;
      case ContainerState.unknown:
        return colorScheme.outline;
    }
  }

  Widget _buildLogsHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logs',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Error message
        Obx(
          () => controller.errorMessage.value.isNotEmpty
              ? Card(
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                          size: 18,
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
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Logs view with fixed height
        Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: 400,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LogsView(
                customController: controller.logsController,
                onClose: () {
                  controller.killLogsProcess();
                  controller.logsController.write(
                    '\x1b[33m--- Logs process stopped ---\x1b[0m\n',
                  );
                },
                onClear: () {
                  // Additional clear logic if needed
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
