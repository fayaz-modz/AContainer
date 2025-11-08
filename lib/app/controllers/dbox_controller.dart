import 'dart:convert';
import 'dart:io';
import 'package:acontainer/app/controllers/command_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/models/volume.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DboxController extends GetxController {
  final box = GetStorage();
  RxList<ContainerInfo> containers = <ContainerInfo>[].obs;
  RxList<VolumeInfo> volumes = <VolumeInfo>[].obs;

  String getRootPath() {
    return box.read("root_path") ?? "/data/acontainer";
  }

  String getConfigPath() {
    final rootPath = getRootPath();
    return box.read("config_path") ?? "$rootPath/config.yaml";
  }

  Future<bool> envCheck() async {
    final filesToCheck = [
      '/data/acontainer/bin/dbox',
      '/data/acontainer/bin/crun',
      '/data/acontainer/config.yaml',
    ];

    for (final file in filesToCheck) {
      final result = await CommandController.runRoot('test -f $file');

      if (result.exitCode != 0) {
        CommandController.logger.w('Missing required file: $file');
        return false;
      }
    }

    return true;
  }

  Future<List<ContainerInfo>> list() async {
    final configPath = getConfigPath();
    final command = 'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox list --json';

    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to list containers');
      return [];
    }

    final containerList = <ContainerInfo>[];
    try {
      final outputLines = result.outputs
          .where((output) => output.type == OutputType.stdout)
          .map((output) => output.line)
          .join('\n');
      
      if (outputLines.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(outputLines);
        for (final item in jsonList) {
          if (item is Map<String, dynamic>) {
            containerList.add(ContainerInfo.fromJson(item));
          }
        }
      }
    } catch (e) {
      CommandController.logger.e('Failed to parse JSON container list: $e');
    }

    containers.value = containerList;
    return containerList;
  }

  Future<List<VolumeInfo>> listVolumes() async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox volume ls --json';

    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to list volumes');
      return [];
    }

    final volumeList = <VolumeInfo>[];
    try {
      final outputLines = result.outputs
          .where((output) => output.type == OutputType.stdout)
          .map((output) => output.line)
          .join('\n');
      
      if (outputLines.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(outputLines);
        for (final item in jsonList) {
          if (item is Map<String, dynamic>) {
            volumeList.add(VolumeInfo.fromJson(item));
          }
        }
      }
    } catch (e) {
      CommandController.logger.e('Failed to parse JSON volume list: $e');
    }

    volumes.value = volumeList;
    return volumeList;
  }

  Future<void> refreshAll() async {
    await Future.wait([list(), listVolumes()]);
  }

  Stream<CommandOutput> create({
    String? name,
    String? image,
    bool? tty,
    bool? privileged,
    String? net,
    int? memory,
    int? memorySwap,
    int? cpuShares,
    int? cpuQuota,
    int? cpuPeriod,
    int? blkioWeight,
    String? init,
    String? containerConfig,
    bool? noOverlayfs,
    List<String>? env,
    List<String>? dns,
    List<String>? volumes,
  }) async* {
    final configPath = getConfigPath();
    final commandParts = [
      'DBOX_CONFIG=$configPath',
      '${getRootPath()}/bin/dbox',
      'create',
    ];

    if (name != null) commandParts.addAll(['--name', name]);
    if (image != null) commandParts.addAll(['--image', image]);
    if (tty == true) commandParts.add('--tty');
    if (privileged == true) commandParts.add('--privileged');
    if (net != null) commandParts.addAll(['--net', net]);
    if (memory != null) commandParts.addAll(['--memory', memory.toString()]);
    if (memorySwap != null) {
      commandParts.addAll(['--memory-swap', memorySwap.toString()]);
    }
    if (cpuShares != null) {
      commandParts.addAll(['--cpu-shares', cpuShares.toString()]);
    }
    if (cpuQuota != null) {
      commandParts.addAll(['--cpu-quota', cpuQuota.toString()]);
    }
    if (cpuPeriod != null) {
      commandParts.addAll(['--cpu-period', cpuPeriod.toString()]);
    }
    if (blkioWeight != null) {
      commandParts.addAll(['--blkio-weight', blkioWeight.toString()]);
    }
    if (init != null) commandParts.addAll(['--init', init]);
    if (containerConfig != null) {
      commandParts.addAll(['--container-config', containerConfig]);
    }
    if (noOverlayfs == true) commandParts.add('--no-overlayfs');

    for (final envVar in env ?? []) {
      commandParts.addAll(['--env', envVar]);
    }

    for (final dnsServer in dns ?? []) {
      commandParts.addAll(['--dns', dnsServer]);
    }

    for (final volume in volumes ?? []) {
      commandParts.addAll(['--volume', volume]);
    }

    final command = commandParts.join(' ');
    yield* CommandController.runRootStream(command).map((output) {
      if (output.type == OutputType.exitCode && output.line == '0') {
        // Operation succeeded, refresh list to include new container
        refreshAll().then(
          (_) {},
          onError: (e) => CommandController.logger.w(
            'Failed to refresh lists after create: $e',
          ),
        );
      }
      return output;
    });
  }

  Stream<CommandOutput> recreate(
    String name, {
    String? image,
    bool? tty,
    bool? privileged,
    String? net,
    int? memory,
    int? memorySwap,
    int? cpuShares,
    int? cpuQuota,
    int? cpuPeriod,
    int? blkioWeight,
    String? init,
    String? containerConfig,
    List<String>? env,
    List<String>? dns,
    List<String>? volumes,
  }) async* {
    final configPath = getConfigPath();
    final commandParts = [
      'DBOX_CONFIG=$configPath',
      '${getRootPath()}/bin/dbox',
      'recreate',
      name,
    ];

    if (image != null) commandParts.addAll(['--image', image]);
    if (tty == true) commandParts.add('--tty');
    if (privileged == true) commandParts.add('--privileged');
    if (net != null) commandParts.addAll(['--net', net]);
    if (memory != null) commandParts.addAll(['--memory', memory.toString()]);
    if (memorySwap != null) {
      commandParts.addAll(['--memory-swap', memorySwap.toString()]);
    }
    if (cpuShares != null) {
      commandParts.addAll(['--cpu-shares', cpuShares.toString()]);
    }
    if (cpuQuota != null) {
      commandParts.addAll(['--cpu-quota', cpuQuota.toString()]);
    }
    if (cpuPeriod != null) {
      commandParts.addAll(['--cpu-period', cpuPeriod.toString()]);
    }
    if (blkioWeight != null) {
      commandParts.addAll(['--blkio-weight', blkioWeight.toString()]);
    }
    if (init != null) commandParts.addAll(['--init', init]);
    if (containerConfig != null) {
      commandParts.addAll(['--container-config', containerConfig]);
    }

    for (final envVar in env ?? []) {
      commandParts.addAll(['--env', envVar]);
    }

    for (final dnsServer in dns ?? []) {
      commandParts.addAll(['--dns', dnsServer]);
    }

    for (final volume in volumes ?? []) {
      commandParts.addAll(['--volume', volume]);
    }

    final command = commandParts.join(' ');
    yield* CommandController.runRootStream(command).map((output) {
      if (output.type == OutputType.exitCode && output.line == '0') {
        // Operation succeeded, refresh status to update list
        refreshAll().then(
          (_) {},
          onError: (e) => CommandController.logger.w(
            'Failed to refresh lists after recreate: $e',
          ),
        );
      }
      return output;
    });
  }

  Stream<CommandOutput> start(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox start $name -d --verbose';
    yield* CommandController.runRootStream(command).map((output) {
      if (output.type == OutputType.exitCode && output.line == '0') {
        // Operation succeeded, refresh status to update list
        refreshAll().then(
          (_) {},
          onError: (e) => CommandController.logger.w(
            'Failed to refresh lists after start: $e',
          ),
        );
      }
      return output;
    });
  }

  Stream<CommandOutput> stop(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox stop $name';
    yield* CommandController.runRootStream(command).map((output) {
      if (output.type == OutputType.exitCode && output.line == '0') {
        // Operation succeeded, refresh status to update list
        refreshAll().then(
          (_) {},
          onError: (e) => CommandController.logger.w(
            'Failed to refresh lists after stop: $e',
          ),
        );
      }
      return output;
    });
  }

  Future<ContainerStatus> status(String name) async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox status $name --json';
    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to get container status: $name');
      throw Exception('Container status failed for $name');
    }

    try {
      final outputLines = result.outputs
          .where((output) => output.type == OutputType.stdout)
          .map((output) => output.line)
          .join('\n');
      
      if (outputLines.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(outputLines);
        final status = ContainerStatus.fromJson(jsonMap);

        // Update the container in the list if it exists
        final index = containers.indexWhere((c) => c.name == name);
        if (index != -1) {
          final updatedContainer = ContainerInfo(
            name: containers[index].name,
            image: containers[index].image,
            state: status.status,
            created: containers[index].created,
          );
          containers[index] = updatedContainer;
        }

        return status;
      }
    } catch (e) {
      CommandController.logger.e('Failed to parse JSON container status: $e');
    }

    throw Exception('Failed to parse container status for $name');
  }

  Future<Map<String, dynamic>> getContainerInfo(String name) async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox info $name --json';
    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to get container info: $name');
      throw Exception('Container info failed for $name');
    }

    try {
      final outputLines = result.outputs
          .where((output) => output.type == OutputType.stdout)
          .map((output) => output.line)
          .join('\n');
      
      if (outputLines.isNotEmpty) {
        return jsonDecode(outputLines);
      }
    } catch (e) {
      CommandController.logger.e('Failed to parse JSON container info: $e');
    }

    throw Exception('Failed to parse container info for $name');
  }

  Stream<CommandOutput> delete(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox delete $name';
    yield* CommandController.runRootStream(command).map((output) {
      if (output.type == OutputType.exitCode && output.line == '0') {
        // Operation succeeded, remove from list
        containers.removeWhere((c) => c.name == name);
        // Also refresh volumes in case any volumes were cleaned up
        listVolumes().then(
          (_) {},
          onError: (e) => CommandController.logger.w(
            'Failed to refresh volumes after delete: $e',
          ),
        );
      }
      return output;
    });
  }

  Future<CommandResult> logs(String name) async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox logs $name';
    return await CommandController.runRoot(command);
  }

  Stream<CommandOutput> logsStream(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath exec ${getRootPath()}/bin/dbox logs -f $name';
    yield* CommandController.runRootStream(command);
  }

  Pty? attach(String name, {String? shell}) {
    final configPath = getConfigPath();
    String command;

    if (shell != null) {
      if (name.isNotEmpty) {
        // Execute shell inside container
        command =
            'su -c "DBOX_CONFIG=$configPath exec ${getRootPath()}/bin/dbox exec $name -- $shell"';
      } else {
        // Execute shell directly with dbox environment
        final binPath = '${getRootPath()}/bin';
        final currentPath = Platform.environment['PATH'] ?? '';
        command =
            'su -c "PATH=$currentPath:$binPath DBOX_CONFIG=$configPath exec $shell"';
      }
    } else {
      // Attach to container
      command =
          'su -c "DBOX_CONFIG=$configPath exec ${getRootPath()}/bin/dbox attach $name"';
    }

    Logger().i('Starting PTY with shell command: $command');
    return Pty.start("su", arguments: ["-c", command]);
  }



  Future<CommandResult> createVolume(
    String name, [
    String driver = 'local',
  ]) async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox volume create --driver $driver $name';
    final result = await CommandController.runRoot(command);

    if (result.exitCode == 0) {
      CommandController.logger.i('Successfully created volume: $name');
      // Refresh volumes list after successful creation
      listVolumes().then(
        (_) {},
        onError: (e) => CommandController.logger.w(
          'Failed to refresh volumes after create: $e',
        ),
      );
    } else {
      CommandController.logger.e('Failed to create volume: $name');
    }

    return result;
  }

  Future<CommandResult> removeVolume(String name, {bool force = false}) async {
    final configPath = getConfigPath();
    final forceFlag = force ? ' -f' : '';
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox volume remove$forceFlag $name';
    final result = await CommandController.runRoot(command);

    if (result.exitCode == 0) {
      // Remove from local list and refresh
      volumes.removeWhere((v) => v.name == name);
    }

    return result;
  }

  Future<Map<String, dynamic>> inspectVolume(String name) async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox volume inspect $name --json';
    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to inspect volume: $name');
      throw Exception('Volume inspect failed for $name');
    }

    try {
      final outputLines = result.outputs
          .where((output) => output.type == OutputType.stdout)
          .map((output) => output.line)
          .join('\n');
      
      if (outputLines.isNotEmpty) {
        return jsonDecode(outputLines);
      }
    } catch (e) {
      CommandController.logger.e('Failed to parse JSON volume inspect: $e');
    }

    throw Exception('Failed to parse volume inspect for $name');
  }

  Future<Map<String, dynamic>> getSystemInfo() async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox info --json';
    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to get system info');
      throw Exception('System info failed');
    }

    try {
      final outputLines = result.outputs
          .where((output) => output.type == OutputType.stdout)
          .map((output) => output.line)
          .join('\n');
      
      if (outputLines.isNotEmpty) {
        return jsonDecode(outputLines);
      }
    } catch (e) {
      CommandController.logger.e('Failed to parse JSON system info: $e');
    }

    throw Exception('Failed to parse system info');
  }
}
