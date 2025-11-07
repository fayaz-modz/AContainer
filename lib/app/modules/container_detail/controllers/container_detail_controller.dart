import 'dart:convert';
import 'dart:io';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/controllers/logs_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/controllers/command_controller.dart';

class ContainerDetailController extends GetxController {
  final DboxController dboxController = Get.find<DboxController>();
  final logger = Logger('ContainerDetailController');
  late final LogsController logsController;

  final containerName = ''.obs;
  final containerInfo = Rxn<ContainerInfo>();
  final showCreationLogs = false.obs;
  final containerStatus = Rxn<ContainerStatus>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentView = ContainerView.logs.obs;

  // Track the logs stream process for cleanup
  Process? _logsProcess;

  @override
  Future<void> onInit() async {
    logger.i('ContainerDetailController - onInit: STARTED');
    super.onInit();
    logsController = LogsController();

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    logger.i('ContainerDetailController - Get.arguments: $args');
    logger.i(
      'ContainerDetailController - Get.arguments type: ${Get.arguments.runtimeType}',
    );

    containerName.value = args['containerName'] as String? ?? '';
    containerInfo.value = args['container'] as ContainerInfo?;
    showCreationLogs.value = args['showCreationLogs'] as bool? ?? false;

    // Debug logging
    logger.i('ContainerDetailController - onInit:');
    logger.i('  args: $args');
    logger.i('  containerName: ${containerName.value}');
    logger.i('  containerInfo: ${containerInfo.value}');
    logger.i('  containerInfo.name: ${containerInfo.value?.name}');
    logger.i('  containerInfo.image: ${containerInfo.value?.image}');
    logger.i('  containerInfo.state: ${containerInfo.value?.state}');

    if (showCreationLogs.value) {
      _showCreationCompleteMessage();
    }

    if (containerName.value.isNotEmpty) {
      await loadContainerStatus();

      // Always start logs stream regardless of container state
      final status = containerStatus.value;
      if (status?.status == ContainerState.running) {
        logsController.write(
          '\x1b[32mContainer is running. Streaming logs...\x1b[0m\n',
        );
      } else if (status?.status == ContainerState.creating) {
        logsController.write(
          '\x1b[33mContainer is being created. Streaming creation logs...\x1b[0m\n',
        );
      } else if (status?.status == ContainerState.ready) {
        logsController.write(
          '\x1b[36mContainer is ready. Streaming logs...\x1b[0m\n',
        );
      } else {
        logsController.write(
          '\x1b[33mContainer is ${status?.status.displayName.toLowerCase()}. Showing logs...\x1b[0m\n',
        );
      }
      _startLogsStream();
    }
    logger.i('ContainerDetailController - onInit: COMPLETED');
  }

  @override
  void onClose() {
    killLogsProcess();
    logsController.dispose();
    super.onClose();
  }

  Future<void> killLogsProcess() async {
    logger.i('Killing logs process for container: ${containerName.value}');
    try {
      // Kill the process directly
      _logsProcess?.kill();

      // Also try to kill any remaining dbox logs processes using su
      await Process.run('su', [
        '-c',
        'pkill -f "dbox logs -f ${containerName.value}"',
      ]);

      logger.i('Logs process killed successfully');
    } catch (e) {
      logger.e('Failed to kill logs process: $e');
    } finally {
      _logsProcess = null;
    }
  }

  void _showCreationCompleteMessage() {
    logsController.terminal.write(
      '\x1b[32mContainer "${containerName.value}" created successfully!\x1b[0m\n',
    );
    logsController.terminal.write(
      'You can now start the container and monitor its status.\n',
    );
    logsController.terminal.write('\n');
  }

  Future<void> loadContainerStatus() async {
    if (containerName.value.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final status = await dboxController.status(containerName.value);
      containerStatus.value = status;
    } catch (e) {
      errorMessage.value = 'Failed to load container status: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStatus() async {
    if (containerName.value.isEmpty) return;

    // Stop any existing log processes
    await killLogsProcess();

    // Clear and reset the terminal
    logsController.clear();
    logsController.write(
      '\x1b[H\x1b[2J',
    ); // Reset cursor position and clear screen
    logsController.write('\x1b[32mRefreshing container status...\x1b[0m\n');

    // Load the status
    await loadContainerStatus();

    // Always start logs stream regardless of container state
    final status = containerStatus.value;
    if (status?.status == ContainerState.running) {
      logsController.write(
        '\x1b[32mContainer is running. Streaming logs...\x1b[0m\n',
      );
    } else if (status?.status == ContainerState.creating) {
      logsController.write(
        '\x1b[33mContainer is being created. Streaming creation logs...\x1b[0m\n',
      );
    } else if (status?.status == ContainerState.ready) {
      logsController.write(
        '\x1b[36mContainer is ready. Streaming logs...\x1b[0m\n',
      );
    } else {
      logsController.write(
        '\x1b[33mContainer is ${status?.status.displayName.toLowerCase()}. Showing logs...\x1b[0m\n',
      );
    }
    _startLogsStream();
  }

  Future<void> startContainer() async {
    if (containerName.value.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      logsController.clear();

      // Track if the start command succeeded (exit code 0)
      bool startSucceeded = false;

      final startStream = dboxController.start(containerName.value);

      // Listen to the start command stream directly
      startStream.listen(
        (output) {
          String line = output.line;

          if (output.type == OutputType.stdout) {
            // Write stdout normally
            logsController.write('$line\n');
          } else if (output.type == OutputType.stderr) {
            // Write stderr in red color
            logsController.write('\x1b[31m$line\x1b[0m\n');
          } else if (output.type == OutputType.exitCode) {
            final exitCode = int.tryParse(output.line) ?? -1;
            startSucceeded = (exitCode == 0);

            if (startSucceeded) {
              logsController.write(
                '\x1b[32mContainer started successfully. Streaming logs...\x1b[0m\n',
              );
            } else {
              logsController.write(
                '\x1b[31mContainer failed to start with exit code: $exitCode\x1b[0m\n',
              );
            }
          }
        },
        onError: (error) {
          errorMessage.value = 'Error: $error';
          logsController.write('\x1b[31mError: $error\x1b[0m\n');
          isLoading.value = false;
        },
        onDone: () {
          isLoading.value = false;
          logsController.write(
            '\x1b[32m--- Start command completed ---\x1b[0m\n',
          );

          // Refresh container status when start command completes
          loadContainerStatus();

          // If start succeeded, begin streaming logs
          if (startSucceeded) {
            _startLogsStream();
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to start container: $e';
      isLoading.value = false;
    }
  }

  void _startLogsStream() async {
    try {
      // Kill any existing logs process
      await killLogsProcess();

      // Start new logs process manually to track it
      _startLogsProcessManually();
    } catch (e) {
      logsController.write('\x1b[31mFailed to start logs stream: $e\x1b[0m\n');
    }
  }

  void _startLogsProcessManually() async {
    try {
      final configPath = dboxController.getConfigPath();
      final command =
          'DBOX_CONFIG=$configPath exec ${dboxController.getRootPath()}/bin/dbox logs -f ${containerName.value}';

      logger.i('Starting logs process: $command');

      _logsProcess = await Process.start('su', ['-c', command]);

      // Handle stdout
      _logsProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            logsController.write('$line\n');
          });

      // Handle stderr
      _logsProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            logsController.write('\x1b[31m$line\x1b[0m\n');
          });

      // Handle process exit
      _logsProcess!.exitCode.then((code) {
        logger.i('Logs process exited with code: $code');
        _logsProcess = null;
        logsController.write(
          '\x1b[33m--- Logs stream ended (exit code: $code) ---\x1b[0m\n',
        );
      });

      logsController.write('\x1b[32m--- Logs stream started ---\x1b[0m\n');
    } catch (e) {
      logger.e('Failed to start logs process: $e');
      logsController.write('\x1b[31mFailed to start logs stream: $e\x1b[0m\n');
      _logsProcess = null;
    }
  }

  Future<void> stopContainer() async {
    if (containerName.value.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      logsController.clear();
      logsController.startCommandStream(
        dboxController.stop(containerName.value),
        onDone: () {
          // Refresh container status when stop command completes
          loadContainerStatus();
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to stop container: $e';
      isLoading.value = false;
    }
  }

  Future<void> deleteContainer() async {
    if (containerName.value.isEmpty) return;

    // Show confirmation dialog
    bool confirmed = false;
    await Get.dialog(
      AlertDialog(
        title: const Text('Delete Container'),
        content: Text(
          'Are you sure you want to delete the container "${containerName.value}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              confirmed = true;
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!confirmed) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      logsController.clear();
      logsController.write(
        '\x1b[33mDeleting container "${containerName.value}"...\x1b[0m\n',
      );

      bool deleteSucceeded = false;

      final deleteStream = dboxController.delete(containerName.value);

      deleteStream.listen(
        (output) {
          String line = output.line;

          if (output.type == OutputType.stdout) {
            logsController.write('$line\n');
          } else if (output.type == OutputType.stderr) {
            logsController.write('\x1b[31m$line\x1b[0m\n');
          } else if (output.type == OutputType.exitCode) {
            final exitCode = int.tryParse(output.line) ?? -1;
            deleteSucceeded = (exitCode == 0);

            if (deleteSucceeded) {
              logsController.write(
                '\x1b[32mContainer deleted successfully.\x1b[0m\n',
              );
            } else {
              logsController.write(
                '\x1b[31mContainer failed to delete with exit code: $exitCode\x1b[0m\n',
              );
            }
          }
        },
        onError: (error) {
          errorMessage.value = 'Error: $error';
          logsController.write('\x1b[31mError: $error\x1b[0m\n');
          isLoading.value = false;
        },
        onDone: () {
          isLoading.value = false;
          logsController.write(
            '\x1b[32m--- Delete command completed ---\x1b[0m\n',
          );

          // If delete succeeded, go back to home screen after a short delay
          if (deleteSucceeded) {
            Future.delayed(const Duration(seconds: 2), () {
              Get.back(); // Go back to home screen
            });
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to delete container: $e';
      isLoading.value = false;
    }
  }

  Future<void> recreateContainer() async {
    if (containerName.value.isEmpty) return;

    // Show confirmation dialog
    bool confirmed = false;
    await Get.dialog(
      AlertDialog(
        title: const Text('Recreate Container'),
        content: Text(
          'Are you sure you want to recreate the container "${containerName.value}"? This will delete and recreate the container with the same configuration.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              confirmed = true;
              Get.back();
            },
            child: const Text('Recreate'),
          ),
        ],
      ),
    );

    if (!confirmed) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      logsController.clear();
      logsController.write(
        '\x1b[33mRecreating container "${containerName.value}"...\x1b[0m\n',
      );

      bool recreateSucceeded = false;

      final recreateStream = dboxController.recreate(containerName.value);

      recreateStream.listen(
        (output) {
          String line = output.line;

          if (output.type == OutputType.stdout) {
            logsController.write('$line\n');
          } else if (output.type == OutputType.stderr) {
            logsController.write('\x1b[31m$line\x1b[0m\n');
          } else if (output.type == OutputType.exitCode) {
            final exitCode = int.tryParse(output.line) ?? -1;
            recreateSucceeded = (exitCode == 0);

            if (recreateSucceeded) {
              logsController.write(
                '\x1b[32mContainer recreated successfully.\x1b[0m\n',
              );
            } else {
              logsController.write(
                '\x1b[31mContainer failed to recreate with exit code: $exitCode\x1b[0m\n',
              );
            }
          }
        },
        onError: (error) {
          errorMessage.value = 'Error: $error';
          logsController.write('\x1b[31mError: $error\x1b[0m\n');
          isLoading.value = false;
        },
        onDone: () {
          isLoading.value = false;
          logsController.write(
            '\x1b[32m--- Recreate command completed ---\x1b[0m\n',
          );

          // Refresh container status when recreate command completes
          loadContainerStatus();

          // If recreate succeeded, start logs stream if container is running/creating/ready
          if (recreateSucceeded) {
            Future.delayed(const Duration(milliseconds: 500), () {
              final status = containerStatus.value;
              if (status?.status == ContainerState.running) {
                logsController.write(
                  '\x1b[32mContainer is running. Streaming logs...\x1b[0m\n',
                );
                _startLogsStream();
              } else if (status?.status == ContainerState.creating) {
                logsController.write(
                  '\x1b[33mContainer is being created. Streaming creation logs...\x1b[0m\n',
                );
                _startLogsStream();
              } else if (status?.status == ContainerState.ready) {
                logsController.write(
                  '\x1b[36mContainer is ready. Streaming logs...\x1b[0m\n',
                );
                _startLogsStream();
              }
            });
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to recreate container: $e';
      isLoading.value = false;
    }
  }

  void editContainer() {
    if (containerName.value.isEmpty) return;

    // Navigate to edit container page
    Get.toNamed(
      '/edit-container',
      arguments: {'containerName': containerName.value},
    );
  }

  void setView(ContainerView view) {
    currentView.value = view;
  }
}

enum ContainerView { logs, status, actions }
