import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/routes/app_pages.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter/material.dart';
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
      child: InkWell(
        onTap: () {
          final args = {
            'containerName': container.name,
            'container': container,
          };
          _logger.d('Navigating to container detail with args: $args');
          _logger.d('Container name: ${container.name}');
          _logger.d('Container image: ${container.image}');
          _logger.d('Container state: ${container.state}');
          Get.toNamed(Routes.CONTAINER_DETAIL, arguments: args);
        },
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
    );
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

