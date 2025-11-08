import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/views/creation_logs_view.dart';
import 'package:acontainer/app/controllers/command_controller.dart';
import 'package:acontainer/app/models/volume.dart';

enum ContainerType { service, vm }

class CreateContainerController extends GetxController {
  final serviceFormKey = GlobalKey<FormState>();
  final vmFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final imageController = TextEditingController();
  final customNetworkController = TextEditingController();

  // Advanced settings
  final initController = TextEditingController();
  final memoryController = TextEditingController();
  final memorySwapController = TextEditingController();
  final cpuSharesController = TextEditingController();
  final cpuQuotaController = TextEditingController();
  final cpuPeriodController = TextEditingController();
  final blkioWeightController = TextEditingController();
  final containerConfigController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final showAdvanced = true.obs;
  final containerType = ContainerType.service.obs;
  final networkType = 'host'.obs; // 'host' or 'custom'
  final initType = 'none'.obs; // predefined init types
  final vmInitType = 'none'.obs; // separate init type for VM containers

  // Edit mode
  final isEditMode = false.obs;
  final originalContainerName = ''.obs;

  // Environment variables as key-value pairs
  final envVars = <Map<String, String>>[].obs;

  // Volumes as key-value pairs (host_path:container_path)
  final volumes = <Map<String, String>>[].obs;

  // Boolean flags
  final tty = false.obs;
  final privileged = false.obs;
  final noOverlayfs = false.obs;

  final DboxController dboxController = Get.find<DboxController>();

  @override
  void onInit() {
    super.onInit();

    // Check if we're in edit mode
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final containerName = args['containerName'] as String?;
    if (containerName != null) {
      isEditMode.value = true;
      originalContainerName.value = containerName;
      _loadContainerData(containerName);
    }

    // Set default values for VM container
    ever(containerType, (ContainerType type) {
      if (type == ContainerType.vm) {
        privileged.value = true;
        tty.value = true;
        networkType.value = 'host';
        // Set VM-specific init type, but don't affect service init type
        if (vmInitType.value == 'none') {
          vmInitType.value = 'systemd'; // default for VM
        }
      } else {
        networkType.value = 'host';
        // Always reset service container init to 'none' when switching to service
        initType.value = 'none';
        // Don't force reset tty and privileged - let user override these settings
      }
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    imageController.dispose();
    customNetworkController.dispose();
    initController.dispose();
    memoryController.dispose();
    memorySwapController.dispose();
    cpuSharesController.dispose();
    cpuQuotaController.dispose();
    cpuPeriodController.dispose();
    blkioWeightController.dispose();
    containerConfigController.dispose();
    super.onClose();
  }

  void addEnvVar() {
    envVars.add({'key': '', 'value': ''});
  }

  void removeEnvVar(int index) {
    envVars.removeAt(index);
  }

  void updateEnvKey(int index, String value) {
    if (index < envVars.length) {
      envVars[index]['key'] = value;
    }
  }

  void updateEnvValue(int index, String value) {
    if (index < envVars.length) {
      envVars[index]['value'] = value;
    }
  }

  void addVolume() {
    volumes.add({'host': '', 'container': ''});
  }

  void removeVolume(int index) {
    volumes.removeAt(index);
  }

  void updateVolumeHost(int index, String value) {
    if (index < volumes.length) {
      volumes[index]['host'] = value;
    }
  }

  void updateVolumeContainer(int index, String value) {
    if (index < volumes.length) {
      volumes[index]['container'] = value;
    }
  }

  // Predefined init options
  static const Map<String, String> predefinedInits = {
    'none': '',
    'systemd': '/lib/systemd/systemd',
    'init': '/sbin/init',
    'openrc': '/sbin/openrc-init',
    'runit': '/sbin/runit-init',
    'bash': '/bin/bash',
    'sh': '/bin/sh',
    'custom': '',
  };

  // Common container presets
  static const Map<String, Map<String, dynamic>> vmPresets = {
    'ubuntu': {
      'image': 'ubuntu:22.04',
      'init': 'systemd',
      'description': 'Ubuntu 22.04 with systemd',
    },
    'debian': {
      'image': 'debian:12',
      'init': 'systemd',
      'description': 'Debian 12 with systemd',
    },
    'fedora': {
      'image': 'fedora:39',
      'init': 'systemd',
      'description': 'Fedora 39 with systemd',
    },
    'arch': {
      'image': 'archlinux:latest',
      'init': 'systemd',
      'description': 'Arch Linux with systemd',
    },
    'alpine': {
      'image': 'alpine:latest',
      'init': 'openrc',
      'description': 'Alpine Linux with OpenRC',
    },
    'kali': {
      'image': 'kalilinux/kali-rolling:latest',
      'init': 'systemd',
      'description': 'Kali Linux with systemd',
    },
  };

  static const Map<String, Map<String, dynamic>> servicePresets = {
    'nginx': {'image': 'nginx:latest', 'description': 'Nginx web server'},
    'apache': {'image': 'httpd:latest', 'description': 'Apache HTTP server'},
    'mysql': {'image': 'mysql:8.0', 'description': 'MySQL database server'},
    'postgres': {
      'image': 'postgres:15',
      'description': 'PostgreSQL database server',
    },
    'redis': {
      'image': 'redis:7-alpine',
      'description': 'Redis in-memory database',
    },
    'node': {'image': 'node:18-alpine', 'description': 'Node.js runtime'},
    'python': {
      'image': 'python:3.11-alpine',
      'description': 'Python 3.11 runtime',
    },
    'wordpress': {'image': 'wordpress:latest', 'description': 'WordPress CMS'},
  };

  String getInitValue() {
    // Use appropriate init type based on container type
    final currentInitType = containerType.value == ContainerType.vm
        ? vmInitType.value
        : initType.value;

    if (currentInitType == 'custom') {
      return initController.text.trim();
    }
    return predefinedInits[currentInitType] ?? '';
  }

  // Get current init type based on container type
  String get currentInitType {
    return containerType.value == ContainerType.vm
        ? vmInitType.value
        : initType.value;
  }

  void applyVMPreset(String presetName) {
    final preset = vmPresets[presetName];
    if (preset != null) {
      imageController.text = preset['image'] as String;
      vmInitType.value = preset['init'] as String;
    }
  }

  void applyServicePreset(String presetName) {
    final preset = servicePresets[presetName];
    if (preset != null) {
      imageController.text = preset['image'] as String;
      // Ensure service container always has init set to 'none' unless explicitly changed
      if (containerType.value == ContainerType.service) {
        initType.value = 'none';
      }
    }
  }

  Future<void> createContainer() async {
    final currentFormKey = containerType.value == ContainerType.service
        ? serviceFormKey
        : vmFormKey;
    if (!currentFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final name = isEditMode.value
          ? originalContainerName.value
          : nameController.text.trim();
      final image = isEditMode.value ? null : imageController.text.trim();

      // Parse environment variables
      final envList = <String>[];
      for (final env in envVars) {
        final key = env['key']?.trim();
        final value = env['value']?.trim();
        if (key?.isNotEmpty == true && value?.isNotEmpty == true) {
          envList.add('$key=$value');
        }
      }

      // Parse volumes
      final volumeList = <String>[];
      for (final volume in volumes) {
        final hostPath = volume['host']?.trim();
        final containerPath = volume['container']?.trim();
        if (hostPath?.isNotEmpty == true && containerPath?.isNotEmpty == true) {
          volumeList.add('$hostPath:$containerPath');
        }
      }

      // Set DNS servers (hardcoded)
      final dnsServers = ['8.8.8.8', '1.1.1.1'];

      // Get network value
      String? network;
      if (networkType.value == 'host') {
        network = 'host';
      } else if (networkType.value == 'custom') {
        network = customNetworkController.text.trim().isEmpty
            ? null
            : customNetworkController.text.trim();
      }

      // Get init process value (only pass if not 'none')
      final initProcessValue = getInitValue();
      final initProcess = initProcessValue.isEmpty ? null : initProcessValue;

      // Parse numeric values
      final memory = memoryController.text.trim().isEmpty
          ? null
          : _parseMemory(memoryController.text.trim());
      final memorySwap = memorySwapController.text.trim().isEmpty
          ? null
          : _parseMemory(memorySwapController.text.trim());
      final cpuShares = cpuSharesController.text.trim().isEmpty
          ? null
          : int.tryParse(cpuSharesController.text.trim());
      final cpuQuota = cpuQuotaController.text.trim().isEmpty
          ? null
          : int.tryParse(cpuQuotaController.text.trim());
      final cpuPeriod = cpuPeriodController.text.trim().isEmpty
          ? null
          : int.tryParse(cpuPeriodController.text.trim());
      final blkioWeight = blkioWeightController.text.trim().isEmpty
          ? null
          : int.tryParse(blkioWeightController.text.trim());

      Stream<CommandOutput> createStream;

      if (isEditMode.value) {
        // Recreate container using dbox (image is optional override)
        createStream = dboxController.recreate(
          name,
          image: image, // Can be null to keep original image
          tty: tty.value,
          privileged: privileged.value,
          net: network,
          memory: memory,
          memorySwap: memorySwap,
          cpuShares: cpuShares,
          cpuQuota: cpuQuota,
          cpuPeriod: cpuPeriod,
          blkioWeight: blkioWeight,
          init: initProcess,
          containerConfig: containerConfigController.text.trim().isEmpty
              ? null
              : containerConfigController.text.trim(),
          env: envList.isEmpty ? null : envList,
          dns: dnsServers,
        );
      } else {
        // Create container using dbox
        createStream = dboxController.create(
          name: name,
          image: image!,
          tty: tty.value,
          privileged: privileged.value,
          net: network,
          memory: memory,
          memorySwap: memorySwap,
          cpuShares: cpuShares,
          cpuQuota: cpuQuota,
          cpuPeriod: cpuPeriod,
          blkioWeight: blkioWeight,
          init: initProcess,
          containerConfig: containerConfigController.text.trim().isEmpty
              ? null
              : containerConfigController.text.trim(),
          noOverlayfs: noOverlayfs.value,
          env: envList.isEmpty ? null : envList,
          dns: dnsServers,
          volumes: volumeList.isEmpty ? null : volumeList,
        );
      }

      // Navigate to creation logs page immediately
      Get.to(
        () =>
            CreationLogsView(containerName: name, creationStream: createStream),
      );
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  int? _parseMemory(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue.endsWith('g')) {
      final gb = double.tryParse(
        lowerValue.substring(0, lowerValue.length - 1),
      );
      return gb != null ? (gb * 1024 * 1024 * 1024).toInt() : null;
    } else if (lowerValue.endsWith('m')) {
      final mb = double.tryParse(
        lowerValue.substring(0, lowerValue.length - 1),
      );
      return mb != null ? (mb * 1024 * 1024).toInt() : null;
    } else if (lowerValue.endsWith('k')) {
      final kb = double.tryParse(
        lowerValue.substring(0, lowerValue.length - 1),
      );
      return kb != null ? (kb * 1024).toInt() : null;
    } else {
      return int.tryParse(value);
    }
  }

  Future<void> _loadContainerData(String containerName) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Get container info using dbox info command
      final infoOutput = await dboxController.getContainerInfo(containerName);

      // Parse the info output to populate form fields
      _parseContainerInfo(infoOutput);
    } catch (e) {
      errorMessage.value = 'Failed to load container data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _parseContainerInfo(Map<String, dynamic> infoOutput) {
    // Parse basic info from JSON
    final currentImage = infoOutput['image'] as String?;
    final currentInit = infoOutput['init_process'] as String?;
    final currentPrivileged = infoOutput['privileged'] as bool? ?? false;
    final currentNetwork = infoOutput['network_namespace'] as String?;
    final currentTTY = infoOutput['tty'] as bool? ?? false;
    final currentVolumes = infoOutput['volumes'] as List<dynamic>? ?? [];

    // Determine container type based on settings
    if (currentPrivileged && currentTTY) {
      containerType.value = ContainerType.vm;
    } else {
      containerType.value = ContainerType.service;
    }

    // Populate form fields
    if (currentImage != null) {
      imageController.text = currentImage;
    }

    privileged.value = currentPrivileged;
    tty.value = currentTTY;

    if (currentNetwork != null) {
      if (currentNetwork == 'host') {
        networkType.value = 'host';
      } else {
        networkType.value = 'custom';
        customNetworkController.text = currentNetwork;
      }
    }

    if (currentInit != null) {
      initController.text = currentInit;
      // Try to match with predefined init types
      bool foundMatch = false;
      for (final entry in predefinedInits.entries) {
        if (entry.value == currentInit) {
          if (containerType.value == ContainerType.vm) {
            vmInitType.value = entry.key;
          } else {
            initType.value = entry.key;
          }
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        if (containerType.value == ContainerType.vm) {
          vmInitType.value = 'custom';
        } else {
          initType.value = 'custom';
        }
      }
    } else {
      // If no init process in info, set to 'none'
      if (containerType.value == ContainerType.vm) {
        vmInitType.value = 'none';
      } else {
        initType.value = 'none';
      }
    }

    // Parse volumes
    volumes.clear();
    for (final volume in currentVolumes) {
      if (volume is String) {
        // Parse volume string in format "host_path:container_path" or "volume_name:container_path"
        final parts = volume.split(':');
        if (parts.length >= 2) {
          volumes.add({
            'host': parts[0],
            'container': parts[1],
          });
        }
      }
    }
  }

  void clearForm() {
    nameController.clear();
    imageController.clear();
    customNetworkController.clear();
    initController.clear();
    memoryController.clear();
    memorySwapController.clear();
    cpuSharesController.clear();
    cpuQuotaController.clear();
    cpuPeriodController.clear();
    blkioWeightController.clear();
    containerConfigController.clear();
    errorMessage.value = '';
    envVars.clear();
    volumes.clear();
    showAdvanced.value = true;
    networkType.value = 'host';
    initType.value = 'none';
    vmInitType.value = 'none';
    isEditMode.value = false;
    originalContainerName.value = '';

    // Reset boolean flags
    tty.value = false;
    privileged.value = false;
    noOverlayfs.value = false;

    // Reset form states
    serviceFormKey.currentState?.reset();
    vmFormKey.currentState?.reset();
  }

  Future<void> refreshVolumes() async {
    await dboxController.listVolumes();
  }

  List<VolumeInfo> get availableVolumes {
    return dboxController.volumes;
  }

  void addCustomVolume() {
    volumes.add({'host': '', 'container': ''});
  }

  void addNamedVolume(String volumeName) {
    volumes.add({'host': volumeName, 'container': ''});
  }
}
