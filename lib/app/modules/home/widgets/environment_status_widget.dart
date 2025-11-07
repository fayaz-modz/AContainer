import 'package:flutter/material.dart';

class EnvironmentStatusWidget extends StatelessWidget {
  final bool isOk;
  final String? errorMessage;

  const EnvironmentStatusWidget({
    super.key,
    required this.isOk,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isOk ? colorScheme.primaryContainer : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isOk ? Icons.check_circle : Icons.error,
              color: isOk
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOk ? 'Environment OK' : 'Environment Check Failed',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isOk
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
