import 'package:acontainer/app/controllers/terminal_session_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:flutter/material.dart';

class TerminalTabWidget extends StatelessWidget {
  final TerminalSession session;
  final VoidCallback onClose;
  final VoidCallback onAttach;

  const TerminalTabWidget({
    super.key,
    required this.session,
    required this.onClose,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = session.container.state == ContainerState.running;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          'Session #${session.id} • ${session.container.name}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              session.container.image,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(
                  session.container.state.name,
                  colorScheme,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              session.container.state.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              TextButton.icon(
                onPressed: onAttach,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Attach'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            IconButton(
              icon: Icon(Icons.close, color: colorScheme.error, size: 20),
              onPressed: () {
                // If session has already exited, close directly without confirmation
                if (session.container.state == ContainerState.exited) {
                  onClose();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Close Session'),
                      content: Text(
                        'Close terminal session for "${session.container.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onClose();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.error,
                          ),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
              tooltip: 'Close session',
            ),
          ],
        ),
        onTap: isActive ? onAttach : null,
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'running':
        return colorScheme.primary;
      case 'stopped':
        return colorScheme.error;
      case 'exited':
        return colorScheme.error;
      case 'creating':
      case 'ready':
      case 'created':
        return colorScheme.secondary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
