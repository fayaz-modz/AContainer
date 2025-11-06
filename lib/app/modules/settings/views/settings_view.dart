import 'package:acontainer/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            context,
            title: 'Preferences',
            items: [
              _SettingsItem(
                icon: Icons.tune_outlined,
                title: 'General',
                subtitle: 'App preferences and settings',
                onTap: () => Get.toNamed(Routes.GENERAL_SETTINGS),
              ),
              _SettingsItem(
                icon: Icons.terminal_outlined,
                title: 'Terminal',
                subtitle: 'Terminal themes and customization',
                onTap: () => Get.toNamed(Routes.TERMINAL_SETTINGS),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: 'About',
            items: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App information and version',
                onTap: () => Get.toNamed(Routes.ABOUT),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
          ...items.map((item) => _buildSettingsItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, _SettingsItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(item.icon, color: colorScheme.onSurfaceVariant),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: item.onTap,
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
