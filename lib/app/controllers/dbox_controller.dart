import 'dart:io';
import 'package:acontainer/app/controllers/command_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DboxController extends GetxController {
  final box = GetStorage();

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
    final command = 'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox list';

    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to list containers');
      return [];
    }

    final containers = <ContainerInfo>[];
    for (final output in result.outputs) {
      if (output.type == OutputType.stdout) {
        final line = output.line.trim();
        if (line.isNotEmpty &&
            !line.startsWith('CONTAINER_NAME') &&
            !line.startsWith('----')) {
          try {
            containers.add(ContainerInfo.fromOutput(line));
          } catch (e) {
            CommandController.logger.w('Failed to parse container line: $line');
          }
        }
      }
    }

    return containers;
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
    yield* CommandController.runRootStream(command);
  }

  Stream<CommandOutput> recreate(
    String name, {
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
    yield* CommandController.runRootStream(command);
  }

  Stream<CommandOutput> start(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox start $name -d --verbose';
    yield* CommandController.runRootStream(command);
  }

  Stream<CommandOutput> stop(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox stop $name';
    yield* CommandController.runRootStream(command);
  }

  Future<ContainerStatus> status(String name) async {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox status $name';
    final result = await CommandController.runRoot(command);

    if (result.exitCode != 0) {
      CommandController.logger.e('Failed to get container status: $name');
      throw Exception('Container status failed for $name');
    }

    return ContainerStatus.fromOutput(result.outputs);
  }

  Stream<CommandOutput> delete(String name) async* {
    final configPath = getConfigPath();
    final command =
        'DBOX_CONFIG=$configPath ${getRootPath()}/bin/dbox delete $name';
    yield* CommandController.runRootStream(command);
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
    
    Logger().i('Starting PTY with shell command: su -c \\"$command\\"');
    return Pty.start("sh", arguments: ["-c", command]);
  }
}
