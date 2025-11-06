import 'package:acontainer/app/routes/app_pages.dart';
import 'package:acontainer/app/controllers/terminal_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/environment_status_widget.dart';
import '../widgets/container_card_widget.dart';
import '../widgets/terminal_tab_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sessionController = Get.put(TerminalSessionController());
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
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.currentBottomNavIndex.value == 0) {
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
}

