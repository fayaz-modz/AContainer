import 'package:acontainer/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/environment_status_widget.dart';
import '../widgets/container_card_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AContainer'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal),
            onPressed: () {
              Get.toNamed(Routes.TERMINAL, arguments: {
                'containerName': '',
                'pty': '/system/bin/sh',
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        return Column(
          children: [
            // Fixed header section
            Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  EnvironmentStatusWidget(isOk: controller.envOk.value),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Scrollable content
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
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.CREATE_CONTAINER);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
