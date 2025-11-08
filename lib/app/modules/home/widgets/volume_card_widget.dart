import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acontainer/app/models/volume.dart';
import 'package:acontainer/app/controllers/dbox_controller.dart';

class VolumeCardWidget extends StatelessWidget {
  final VolumeInfo volume;

  const VolumeCardWidget({
    super.key,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dboxController = Get.find<DboxController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          _showVolumeDetails(context, dboxController);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.storage,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volume.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          volume.driver,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'inspect':
                          _showVolumeDetails(context, dboxController);
                          break;
                        case 'remove':
                          _showRemoveDialog(context, dboxController);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'inspect',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('Inspect'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Remove', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            volume.mountpoint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          volume.createdAt,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  void _showVolumeDetails(BuildContext context, DboxController dboxController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Volume: ${volume.name}'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: dboxController.inspectVolume(volume.name),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Error loading volume details: ${snapshot.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('No details available')),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('Name:', data['name']?.toString() ?? ''),
                    _buildDetailRow('Driver:', data['driver']?.toString() ?? ''),
                    _buildDetailRow('Mountpoint:', data['mountpoint']?.toString() ?? ''),
                    _buildDetailRow('Created At:', data['created_at']?.toString() ?? ''),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, DboxController dboxController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Volume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove the volume "${volume.name}"?'),
            const SizedBox(height: 12),
            const Text(
              'This will permanently delete all data in this volume.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final theme = Theme.of(context);
              
              navigator.pop();
              
              final result = await dboxController.removeVolume(volume.name);
              
              if (result.exitCode == 0) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Volume "${volume.name}" removed successfully'),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove volume: ${result.outputs.map((o) => o.line).join(" ")}'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}