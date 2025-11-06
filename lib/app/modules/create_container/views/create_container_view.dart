import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/create_container_controller.dart';

class CreateContainerView extends GetView<CreateContainerController> {
  const CreateContainerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit Container' : 'Create Container',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearForm,
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Obx(() {
        // In edit mode, show single form based on current container type
        // In create mode, show tabbed view
        if (controller.isEditMode.value) {
          return _buildContainerForm(controller.containerType.value, context);
        } else {
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Service Container'),
                    Tab(text: 'VM Container'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildContainerForm(ContainerType.service, context),
                      _buildContainerForm(ContainerType.vm, context),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildContainerForm(ContainerType type, BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: type == ContainerType.service
              ? controller.serviceFormKey
              : controller.vmFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Settings Section
              Text(
                type == ContainerType.service
                    ? 'Service Container Settings'
                    : 'VM Container Settings',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Only show name field in create mode
              Obx(
                () => controller.isEditMode.value
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          TextFormField(
                            controller: controller.nameController,
                            decoration: const InputDecoration(
                              labelText: 'Container Name',
                              hintText: 'Enter container name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.storage),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a container name';
                              }
                              if (!RegExp(
                                r'^[a-zA-Z0-9_-]+$',
                              ).hasMatch(value)) {
                                return 'Container name can only contain letters, numbers, underscores, and hyphens';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),

              // Only show image field in create mode
              Obx(
                () => controller.isEditMode.value
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          TextFormField(
                            controller: controller.imageController,
                            decoration: const InputDecoration(
                              labelText: 'Image',
                              hintText: 'e.g., alpine:latest, ubuntu:22.04',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an image';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
              ),

              // Common Presets - Hide in edit mode
              Obx(
                () => controller.isEditMode.value
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Common ${type == ContainerType.vm ? 'VMs' : 'Services'}',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _buildPresetChips(type),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Network Dropdown
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.networkType.value,
                  decoration: const InputDecoration(
                    labelText: 'Network',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.network_check),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'host', child: Text('Host')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.networkType.value = value;
                    }
                  },
                ),
              ),

              // Custom Network Input (only shown when 'custom' is selected)
              Obx(
                () => controller.networkType.value == 'custom'
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.customNetworkController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Network',
                              hintText: 'e.g., none, container:name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.settings_ethernet),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Init Process for VM Container (moved before environment variables)
              if (type == ContainerType.vm) ...[
                Text(
                  'Init Process',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.vmInitType.value,
                    decoration: const InputDecoration(
                      labelText: 'Select Init Process',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.play_arrow),
                    ),
                     items: const [
                       DropdownMenuItem(value: 'none', child: Text('None')),
                       DropdownMenuItem(
                         value: 'systemd',
                         child: Text('systemd (/lib/systemd/systemd)'),
                       ),
                      DropdownMenuItem(
                        value: 'init',
                        child: Text('sysvinit (/sbin/init)'),
                      ),
                      DropdownMenuItem(
                        value: 'openrc',
                        child: Text('OpenRC (/sbin/openrc-init)'),
                      ),
                      DropdownMenuItem(
                        value: 'runit',
                        child: Text('runit (/sbin/runit-init)'),
                      ),
                      DropdownMenuItem(
                        value: 'bash',
                        child: Text('Bash (/bin/bash)'),
                      ),
                      DropdownMenuItem(
                        value: 'sh',
                        child: Text('Shell (/bin/sh)'),
                      ),
                      DropdownMenuItem(value: 'custom', child: Text('Custom')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.vmInitType.value = value;
                      }
                    },
                  ),
                ),

                // Custom init input (only shown when 'custom' is selected)
                Obx(
                  () => controller.currentInitType == 'custom'
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: controller.initController,
                              decoration: const InputDecoration(
                                labelText: 'Custom Init Path',
                                hintText: 'e.g., /usr/local/bin/custom-init',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.settings),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),
              ],

              // Environment Variables Section
              Text(
                'Environment Variables',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Environment Variables List
              Obx(
                () => Column(
                  children: [
                    for (int i = 0; i < controller.envVars.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: controller.envVars[i]['key'],
                                decoration: const InputDecoration(
                                  labelText: 'Key',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) =>
                                    controller.updateEnvKey(i, value),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: controller.envVars[i]['value'],
                                decoration: const InputDecoration(
                                  labelText: 'Value',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) =>
                                    controller.updateEnvValue(i, value),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => controller.removeEnvVar(i),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: controller.addEnvVar,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Environment Variable'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Volumes Section - Hide in edit mode (not supported by recreate)
              Obx(
                () => controller.isEditMode.value
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          Text(
                            'Volumes',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),

                          // Volumes List
                          Obx(
                            () => Column(
                              children: [
                                for (
                                  int i = 0;
                                  i < controller.volumes.length;
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue:
                                                controller.volumes[i]['host'],
                                            decoration: const InputDecoration(
                                              labelText: 'Host Path',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                              hintText: '/path/on/host',
                                            ),
                                            onChanged: (value) => controller
                                                .updateVolumeHost(i, value),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: controller
                                                .volumes[i]['container'],
                                            decoration: const InputDecoration(
                                              labelText: 'Container Path',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                              hintText: '/path/in/container',
                                            ),
                                            onChanged: (value) => controller
                                                .updateVolumeContainer(
                                                  i,
                                                  value,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              controller.removeVolume(i),
                                          tooltip: 'Remove',
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: controller.addVolume,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Volume'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),

              // Advanced/Override Settings Toggle
              Obx(
                () => ListTile(
                  title: Text(
                    type == ContainerType.service
                        ? 'Override Settings'
                        : 'Advanced Settings',
                  ),
                  trailing: Icon(
                    controller.showAdvanced.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  onTap: controller.showAdvanced.toggle,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const Divider(),

              // Advanced/Override Settings Section
              Obx(
                () => controller.showAdvanced.value
                    ? _buildAdvancedSettings(type, context)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Error Message
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Edit mode info card
              Obx(
                () => controller.isEditMode.value
                    ? Card(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Some options like volumes and overlayfs are not supported in edit mode',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 8),

              // Create/Edit Button
              Obx(
                () => FilledButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.containerType.value = type;
                          controller.createContainer();
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              controller.isEditMode.value
                                  ? 'Updating Container...'
                                  : 'Creating Container...',
                            ),
                          ],
                        )
                      : Text(
                          '${controller.isEditMode.value ? 'Update' : 'Create'} ${type == ContainerType.service ? 'Service' : 'VM'} Container',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPresetChips(ContainerType type) {
    if (type == ContainerType.vm) {
      return CreateContainerController.vmPresets.entries.map((entry) {
        return ActionChip(
          avatar: const Icon(Icons.computer, size: 16),
          label: Text(entry.key),
          onPressed: () => controller.applyVMPreset(entry.key),
          tooltip: entry.value['description'] as String,
        );
      }).toList();
    } else {
      return CreateContainerController.servicePresets.entries.map((entry) {
        return ActionChip(
          avatar: const Icon(Icons.cloud, size: 16),
          label: Text(entry.key),
          onPressed: () => controller.applyServicePreset(entry.key),
          tooltip: entry.value['description'] as String,
        );
      }).toList();
    }
  }



  Widget _buildAdvancedSettings(ContainerType type, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          type == ContainerType.service
              ? 'Override Settings'
              : 'Advanced Settings',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

         // Boolean flags
         Container(
           decoration: BoxDecoration(
             border: Border.all(color: Colors.grey.shade300),
             borderRadius: BorderRadius.circular(12),
           ),
           child: Column(
             children: [
               Obx(
                 () => CheckboxListTile(
                   title: const Text('TTY'),
                   subtitle: const Text('Allocate TTY devices'),
                   value: controller.tty.value,
                   onChanged: (value) => controller.tty.value = value ?? false,
                   contentPadding: const EdgeInsets.symmetric(
                     horizontal: 16,
                     vertical: 4,
                   ),
                 ),
               ),
               Divider(height: 1, color: Colors.grey.shade300),
               Obx(
                 () => CheckboxListTile(
                   title: const Text('Privileged'),
                   subtitle: const Text('Full system capabilities'),
                   value: controller.privileged.value,
                   onChanged: (value) =>
                       controller.privileged.value = value ?? false,
                   contentPadding: const EdgeInsets.symmetric(
                     horizontal: 16,
                     vertical: 4,
                   ),
                 ),
               ),
                if (type == ContainerType.vm) ...[
                  Divider(height: 1, color: Colors.grey.shade300),
                  // VM-specific note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Note: VM containers typically require TTY and Privileged mode enabled for proper operation.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ] else ...[
                  Divider(height: 1, color: Colors.grey.shade300),
                  // Init Process option for Service Containers
                  ListTile(
                    title: const Text('Init Process'),
                    subtitle: Obx(
                      () => Text(
                        controller.initType.value == 'none'
                            ? 'No init process (default)'
                            : 'Init process to run inside container',
                      ),
                    ),
                    trailing: Obx(
                      () => DropdownButton<String>(
                        value: controller.initType.value,
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('None')),
                          DropdownMenuItem(
                            value: 'systemd',
                            child: Text('systemd'),
                          ),
                          DropdownMenuItem(
                            value: 'init',
                            child: Text('sysvinit'),
                          ),
                          DropdownMenuItem(
                            value: 'openrc',
                            child: Text('OpenRC'),
                          ),
                          DropdownMenuItem(value: 'runit', child: Text('runit')),
                          DropdownMenuItem(value: 'bash', child: Text('Bash')),
                          DropdownMenuItem(value: 'sh', child: Text('Shell')),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Custom'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.initType.value = value;
                          }
                        },
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  // Custom init input (only shown when 'custom' is selected)
                  Obx(
                    () => controller.currentInitType == 'custom'
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: controller.initController,
                              decoration: const InputDecoration(
                                labelText: 'Custom Init Path',
                                hintText: 'e.g., /usr/local/bin/custom-init',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.settings),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
             ],
           ),
          ),

        // Hide No OverlayFS in edit mode (not supported by recreate)
        Obx(
          () => controller.isEditMode.value
              ? const SizedBox.shrink()
              : CheckboxListTile(
                  title: const Text('No OverlayFS'),
                  subtitle: const Text('Disable OverlayFS and copy rootfs'),
                  value: controller.noOverlayfs.value,
                  onChanged: (value) =>
                      controller.noOverlayfs.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
        ),

        const SizedBox(height: 16),

        // Text fields
        TextFormField(
          controller: controller.memoryController,
          decoration: const InputDecoration(
            labelText: 'Memory Limit (Optional)',
            hintText: 'e.g., 512m, 1g, 1073741824',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.memory),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: controller.memorySwapController,
          decoration: const InputDecoration(
            labelText: 'Memory+Swap Limit (Optional)',
            hintText: 'e.g., 1g, 2g',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.swap_horiz),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.cpuSharesController,
                decoration: const InputDecoration(
                  labelText: 'CPU Shares (Optional)',
                  hintText: 'e.g., 1024',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.share),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.cpuQuotaController,
                decoration: const InputDecoration(
                  labelText: 'CPU Quota (Optional)',
                  hintText: 'e.g., 50000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.cpuPeriodController,
                decoration: const InputDecoration(
                  labelText: 'CPU Period (Optional)',
                  hintText: 'e.g., 100000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.blkioWeightController,
                decoration: const InputDecoration(
                  labelText: 'Block I/O Weight (Optional)',
                  hintText: 'e.g., 500',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storage),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: controller.containerConfigController,
          decoration: const InputDecoration(
            labelText: 'Container Config (Optional)',
            hintText: 'Path to container_config.json',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.settings),
          ),
        ),
      ],
    );
  }
}
