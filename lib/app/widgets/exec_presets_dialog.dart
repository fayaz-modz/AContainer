import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acontainer/app/controllers/exec_preset_controller.dart';
import 'package:acontainer/app/models/exec_preset.dart';

class ExecPresetsDialog extends StatefulWidget {
  final String containerName;
  final Function(String command) onExecSelected;

  const ExecPresetsDialog({
    super.key,
    required this.containerName,
    required this.onExecSelected,
  });

  @override
  State<ExecPresetsDialog> createState() => _ExecPresetsDialogState();
}

class _ExecPresetsDialogState extends State<ExecPresetsDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ExecPresetController presetController = Get.isRegistered<ExecPresetController>()
        ? Get.find<ExecPresetController>()
        : Get.put(ExecPresetController());

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exec Commands',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddPresetDialog(),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Custom Exec',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                  ),
                ],
              ),
            ),

            // Presets list
            Flexible(
              child: Obx(() {
                if (presetController.presets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.terminal_outlined,
                          size: 32,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No presets available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: presetController.presets.length,
                  itemBuilder: (context, index) {
                    final preset = presetController.presets[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        preset.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: preset.description.isNotEmpty
                          ? Text(
                              preset.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            )
                          : Text(
                              preset.command,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                      onTap: () {
                        Navigator.of(context).pop(); // Close dialog first
                        // Small delay to ensure dialog is fully closed
                        Future.delayed(const Duration(milliseconds: 100), () {
                          widget.onExecSelected(preset.command); // Then execute command
                        });
                      },
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddPresetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Exec'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Custom Command',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commandController,
                  decoration: const InputDecoration(
                    labelText: 'Command',
                    hintText: 'e.g., ls -la /app',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a command';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g., List files in app directory',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final preset = ExecPreset(
                  name: _nameController.text.trim(),
                  command: _commandController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
                
                final presetController = Get.isRegistered<ExecPresetController>()
                    ? Get.find<ExecPresetController>()
                    : Get.put(ExecPresetController());
                    
                presetController.addPreset(preset);
                _clearForm();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _commandController.clear();
    _descriptionController.clear();
  }
}