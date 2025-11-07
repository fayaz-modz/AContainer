import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/general_settings_controller.dart';


class GeneralSettingsView extends GetView<GeneralSettingsController> {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: const Text('General Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_outlined),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'App Theme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => RadioGroup<ThemeMode>(
                groupValue: controller.themeMode,
                onChanged: (value) => controller.setThemeMode(value!),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System'),
                      subtitle: const Text('Follow device theme'),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      subtitle: const Text('Always use light theme'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      subtitle: const Text('Always use dark theme'),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.resetToDefaults();
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}