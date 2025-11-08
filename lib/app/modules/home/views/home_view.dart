import 'dart:math';

import 'package:acontainer/app/routes/app_pages.dart';
import 'package:acontainer/app/controllers/terminal_session_controller.dart';
import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/modules/terminal/controllers/terminal_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/environment_status_widget.dart';
import '../widgets/container_card_widget.dart';
import '../widgets/volume_card_widget.dart';
import '../widgets/terminal_tab_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sessionController = Get.put(TerminalSessionController());
    final dboxController = Get.find<DboxController>();
    final pageController = PageController(
      initialPage: controller.currentBottomNavIndex.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AContainer'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed(Routes.SETTINGS);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed environment status
          Container(
            width: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: Obx(
              () => EnvironmentStatusWidget(isOk: controller.envOk.value),
            ),
          ),
          // Tabbed view content
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) =>
                  controller.currentBottomNavIndex.value = index,
              children: [
                _buildContainersTab(context, theme, colorScheme),
                _buildSessionsTab(
                  context,
                  theme,
                  colorScheme,
                  sessionController,
                ),
                _buildVolumesTab(context, theme, colorScheme, dboxController),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentBottomNavIndex.value,
          onTap: (index) {
            controller.currentBottomNavIndex.value = index;
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Containers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.terminal),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage),
              label: 'Volumes',
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.currentBottomNavIndex.value == 0) {
          // Containers tab FAB
          return FloatingActionButton(
            onPressed: () {
              controller.logger.d(controller.envOk);
              if (!controller.envOk.value) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Error'),
                    content: const Text(
                      'Make sure you have root and dbox installed',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              Get.toNamed(Routes.CREATE_CONTAINER);
            },
            child: const Icon(Icons.add),
          );
        } else if (controller.currentBottomNavIndex.value == 2) {
          // Volumes tab FAB
          return FloatingActionButton(
            onPressed: () {
              controller.logger.d(controller.envOk);
              if (!controller.envOk.value) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Error'),
                    content: const Text(
                      'Make sure you have root and dbox installed',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              _showCreateVolumeDialog(context, dboxController);
            },
            child: const Icon(Icons.add),
          );
        } else if (controller.currentBottomNavIndex.value == 1) {
          // Sessions tab FAB - Connect to system shell
          return FloatingActionButton(
            tooltip: 'Connect to System Shell',
            onPressed: () {
              controller.logger.d(controller.envOk);
              if (!controller.envOk.value) {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Error'),
                    content: const Text(
                      'Make sure you have root and dbox installed',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }

              // Create a new terminal session for system shell
              final terminalController = TerminalController();
              terminalController.closeOnPageClose.value = false;
              terminalController.onInit();

              // Set empty container name for system shell
              terminalController.containerName.value = '';

              // Set the PTY command to /system/bin/sh
              terminalController.pty.value = '/system/bin/sh';

              // Create a session with a dummy container for system shell
              final systemContainer = ContainerInfo(
                name: 'System Shell',
                image: 'system',
                state: ContainerState.running,
                created: DateTime.now().toIso8601String(),
              );

              final session = TerminalSession(
                id: Random().nextInt(256),
                container: systemContainer,
                controller: terminalController,
              );

              // Add to sessions and navigate to terminal
              sessionController.sessions[session.id] = session;

              Get.toNamed(
                Routes.TERMINAL,
                arguments: {'controller': terminalController},
              );
            },
            child: const Icon(Icons.terminal),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildContainersTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      if (controller.loading.value) {
        return Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        );
      }

      return Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Containers',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshPage,
              child: controller.containers.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Center(
                          child: Text(
                            'No containers found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: controller.containers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return ContainerCardWidget(
                          container: controller.containers[index],
                        );
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSessionsTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TerminalSessionController sessionController,
  ) {
    return Obx(() {
      final sessions = sessionController.sessions.values.toList();

      return Column(
        children: [
          // Sessions header
          Container(
            width: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Sessions',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.terminal_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Sessions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Open a terminal from a container to start',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return TerminalTabWidget(
                        session: session,
                        onClose: () => sessionController.removeTerminal(
                          sessionController.sessions.keys.firstWhere(
                            (key) => sessionController.sessions[key] == session,
                          ),
                        ),
                        onAttach: () {
                          Get.toNamed(
                            Routes.TERMINAL,
                            arguments: {'controller': session.controller},
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildVolumesTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DboxController dboxController,
  ) {
    return Obx(() {
      final volumes = dboxController.volumes;

      return Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Volumes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await dboxController.listVolumes();
              },
              child: volumes.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storage_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No volumes found',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create volumes from the container creation screen',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: volumes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final volume = volumes[index];
                        return VolumeCardWidget(volume: volume);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }

  void _showCreateVolumeDialog(
    BuildContext context,
    DboxController dboxController,
  ) {
    final nameController = TextEditingController();
    final driverController = TextEditingController(text: 'local');
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;
    final errorMessage = ''.obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.storage,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create Volume',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // Form Content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Volume Name Field
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Volume Name',
                            hintText: 'my-volume',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.storage),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a volume name';
                            }
                            if (value.trim().length < 2) {
                              return 'Volume name must be at least 2 characters';
                            }
                            if (!RegExp(
                              r'^[a-zA-Z0-9_-]+$',
                            ).hasMatch(value.trim())) {
                              return 'Only letters, numbers, underscores, and hyphens';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _createVolume(
                            nameController,
                            driverController,
                            formKey,
                            isLoading,
                            errorMessage,
                            dboxController,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Driver Field
                        TextFormField(
                          controller: driverController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Driver',
                            hintText: 'local',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.settings),
                            helperText:
                                'Currently only "local" driver is supported',
                            helperStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error Message
                        Obx(() {
                          if (errorMessage.value.isNotEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage.value,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading.value ? null : () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                      () => ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () => _createVolume(
                                nameController,
                                driverController,
                                formKey,
                                isLoading,
                                errorMessage,
                                dboxController,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _createVolume(
    TextEditingController nameController,
    TextEditingController driverController,
    GlobalKey<FormState> formKey,
    RxBool isLoading,
    RxString errorMessage,
    DboxController dboxController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await dboxController.createVolume(
        nameController.text.trim(),
        driverController.text.trim(),
      );

      if (result.exitCode == 0) {
        Get.back();
        Get.snackbar(
          'Success',
          'Volume "${nameController.text.trim()}" created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh the volumes list
        await dboxController.listVolumes();
      } else {
        errorMessage.value = result.outputs.map((o) => o.line).join(' ');
      }
    } catch (e) {
      errorMessage.value = 'Failed to create volume: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
