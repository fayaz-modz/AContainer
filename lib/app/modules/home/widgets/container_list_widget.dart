import 'package:acontainer/app/models/container.dart';
import 'package:flutter/material.dart';

import 'container_card_widget.dart';

class ContainerListWidget extends StatelessWidget {
  final List<ContainerInfo> containers;

  const ContainerListWidget({super.key, required this.containers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (containers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No containers found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else if (containers.every((c) => c.state == ContainerState.creating))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Containers are being created...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  'Check back in a moment or view creation logs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...containers.map(
            (container) => ContainerCardWidget(container: container),
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
