import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/routes/app_pages.dart';
import 'package:acontainer/app/controllers/terminal_session_controller.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class ContainerCardWidget extends StatelessWidget {
  final ContainerInfo container;
  final Logger _logger = Logger('ContainerCardWidget');

  ContainerCardWidget({super.key, required this.container});

  Color _getStatusColor(ContainerState state, ColorScheme colorScheme) {
    switch (state) {
      case ContainerState.running:
        return Colors.green;
      case ContainerState.stopped:
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(container.name),
        
        // Left swipe - auto attach with elastic feel
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.8,
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (_) => _autoAttach(),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              icon: Icons.terminal,
              label: 'Pull to Attach',
              spacing: 0,
              autoClose: true,
            ),
          ],
        ),
        
        // Right swipe - action buttons
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.75,
          children: _buildActionButtons(context, theme, colorScheme),
        ),
        

        
        child: InkWell(
          onTap: _openDetail,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        container.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        container.image,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    container.state.displayName.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getChipTextColor(container.state, colorScheme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: _getChipBackgroundColor(container.state, colorScheme),
                  side: _getChipSide(container.state, colorScheme),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTerminal() {
    final sessionController = Get.find<TerminalSessionController>();
    final session = sessionController.getOrCreateSession(container);
    
    Get.toNamed(
      Routes.TERMINAL,
      arguments: {
        'controller': session.controller,
      },
    );
  }

  void _openDetail() {
    final args = {
      'containerName': container.name,
      'container': container,
    };
    _logger.d('Navigating to container detail with args: $args');
    _logger.d('Container name: ${container.name}');
    _logger.d('Container image: ${container.image}');
    _logger.d('Container state: ${container.state}');
    Get.toNamed(Routes.CONTAINER_DETAIL, arguments: args);
  }

  void _autoAttach() {
    _openTerminal();
  }

  List<Widget> _buildActionButtons(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final isRunning = container.state == ContainerState.running;
    
    if (isRunning) {
      // Running container: Stop, Attach, Edit
      return [
        SlidableAction(
          onPressed: (_) => _toggleContainerState(),
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          icon: Icons.stop,
          label: 'Stop',
          spacing: 0,
        ),
        SlidableAction(
          onPressed: (_) => _openTerminal(),
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          icon: Icons.terminal,
          label: 'Attach',
          spacing: 0,
        ),
        SlidableAction(
          onPressed: (_) => _editContainer(),
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
          icon: Icons.edit,
          label: 'Edit',
          spacing: 0,
        ),
      ];
    } else {
      // Stopped container: Start, Edit (wider buttons)
      return [
        SlidableAction(
          onPressed: (_) => _toggleContainerState(),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          icon: Icons.play_arrow,
          label: 'Start',
          spacing: 0,
          flex: 2,
        ),
        SlidableAction(
          onPressed: (_) => _editContainer(),
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
          icon: Icons.edit,
          label: 'Edit',
          spacing: 0,
          flex: 2,
        ),
      ];
    }
  }

  void _toggleContainerState() {
    // TODO: Implement start/stop functionality
    _logger.d('Toggle container state for ${container.name}');
  }

  void _editContainer() {
    final args = {
      'containerName': container.name,
      'container': container,
    };
    Get.toNamed(Routes.EDIT_CONTAINER, arguments: args);
  }

  Color _getChipTextColor(ContainerState state, ColorScheme colorScheme) {
    switch (state) {
      case ContainerState.running:
      case ContainerState.creating:
        return Colors.white;
      default:
        return _getStatusColor(state, colorScheme);
    }
  }

  Color _getChipBackgroundColor(ContainerState state, ColorScheme colorScheme) {
    switch (state) {
      case ContainerState.running:
      case ContainerState.creating:
        return _getStatusColor(state, colorScheme);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  BorderSide? _getChipSide(ContainerState state, ColorScheme colorScheme) {
    switch (state) {
      case ContainerState.running:
      case ContainerState.creating:
        return BorderSide.none;
      default:
        return BorderSide(
          color: _getStatusColor(state, colorScheme).withValues(alpha: 0.3),
          width: 1,
        );
    }
  }
}

