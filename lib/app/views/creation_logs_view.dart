import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:acontainer/app/controllers/logs_controller.dart';
import 'package:acontainer/app/controllers/command_controller.dart';
import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/views/logs_view.dart';

class CreationLogsView extends StatefulWidget {
  final String containerName;
  final Stream<CommandOutput>? creationStream;
  final Pty? creationPty;

  const CreationLogsView({
    super.key,
    required this.containerName,
    this.creationStream,
    this.creationPty,
  });

  @override
  State<CreationLogsView> createState() => _CreationLogsViewState();
}

class _CreationLogsViewState extends State<CreationLogsView> {
  late final LogsController logsController;
  late final DboxController dboxController;
  bool isCompleted = false;
  bool isCancelled = false;
  bool isInBackground = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    logsController = LogsController();
    dboxController = Get.find<DboxController>();

    // Start listening to the creation stream or PTY with completion and error callbacks
    if (widget.creationStream != null) {
      logsController.startCommandStream(
        widget.creationStream!,
        onDone: () {
          if (mounted) {
            setState(() {
              isCompleted = true;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              errorMessage = error;
            });
          }
        },
      );
    } else if (widget.creationPty != null) {
      logsController.startPty(
        widget.creationPty!,
        onDone: () {
          if (mounted) {
            setState(() {
              isCompleted = true;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              errorMessage = error;
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    logsController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!isCompleted && !isCancelled && !isInBackground) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Container Creation Options'),
          content: Text(
            'Container "${widget.containerName}" is still being created. '
            'What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue Watching'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await _cancelCreation();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Creation'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  Future<void> _cancelCreation() async {
    try {
      setState(() {
        isCancelled = true;
      });

      logsController.write(
        '\x1b[33m--- Cancelling container creation ---\x1b[0m\n',
      );

      // Kill PTY to stop creation process immediately
      logsController.killPty();

      logsController.write(
        '\x1b[32m--- Container creation cancelled ---\x1b[0m\n',
      );

      // Navigate back immediately after cancellation
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      logsController.write('\x1b[31mError cancelling creation: $e\x1b[0m\n');
      // Still navigate back on error
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (!isCompleted && !isCancelled && !isInBackground) ...[
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: _cancelCreation,
                tooltip: 'Cancel Creation',
              ),
            ],
            if (isCompleted)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // Clear all routes and navigate to home, then to container details
                  // This ensures back button goes to home, not exit app
                  Get.offAllNamed('/home');
                  Future.delayed(const Duration(milliseconds: 50), () {
                    Get.toNamed(
                      '/container-detail',
                      arguments: {
                        'containerName': widget.containerName,
                        'showCreationLogs': false,
                      },
                    );
                  });
                },
                tooltip: 'View Container Details',
              ),
          ],
        ),
        body: Column(
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                border: Border(
                  bottom: BorderSide(color: _getStatusBorderColor()),
                ),
              ),
              child: Row(
                children: [
                  _getStatusIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getStatusTextColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error message if any
            if (errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              ),

            // Terminal view using LogsView
            Expanded(
              child: LogsView(
                customController: logsController,
                showAppBar:
                    false, // Hide app bar since CreationLogsView has its own
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (isCancelled) return 'Cancelled - ${widget.containerName}';
    if (isInBackground) return 'Background - ${widget.containerName}';
    if (isCompleted) return 'Created - ${widget.containerName}';
    return 'Creating ${widget.containerName}';
  }

  Color _getStatusColor() {
    if (isCancelled) return Colors.red.shade50;
    if (isInBackground) return Colors.orange.shade50;
    if (isCompleted) return Colors.green.shade50;
    if (errorMessage != null) return Colors.red.shade50;
    return Colors.blue.shade50;
  }

  Color _getStatusBorderColor() {
    if (isCancelled) return Colors.red.shade200;
    if (isInBackground) return Colors.orange.shade200;
    if (isCompleted) return Colors.green.shade200;
    if (errorMessage != null) return Colors.red.shade200;
    return Colors.blue.shade200;
  }

  Widget _getStatusIcon() {
    if (isCancelled) {
      return Icon(Icons.cancel, color: Colors.red.shade600);
    }
    if (isInBackground) {
      return Icon(Icons.play_arrow, color: Colors.orange.shade600);
    }
    if (isCompleted) {
      return Icon(Icons.check_circle, color: Colors.green.shade600);
    }
    if (errorMessage != null) {
      return Icon(Icons.error, color: Colors.red.shade600);
    }
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
      ),
    );
  }

  String _getStatusText() {
    if (isCancelled) {
      return 'Container "${widget.containerName}" creation cancelled';
    }
    if (isInBackground) {
      return 'Container "${widget.containerName}" creation continuing in background';
    }
    if (isCompleted) {
      return 'Container "${widget.containerName}" created successfully!';
    }
    if (errorMessage != null) return 'Error creating container: $errorMessage';
    return 'Creating container "${widget.containerName}"...';
  }

  Color _getStatusTextColor() {
    if (isCancelled) return Colors.red.shade800;
    if (isInBackground) return Colors.orange.shade800;
    if (isCompleted) return Colors.green.shade800;
    if (errorMessage != null) return Colors.red.shade800;
    return Colors.blue.shade800;
  }
}
