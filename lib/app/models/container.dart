import 'package:acontainer/app/controllers/command_controller.dart';

enum ContainerState {
  creating,
  ready,
  created,
  running,
  stopped,
  exited,
  unknown;

  String get displayName {
    switch (this) {
      case creating:
        return 'CREATING';
      case ready:
        return 'READY';
      case created:
        return 'CREATED';
      case running:
        return 'RUNNING';
      case stopped:
        return 'STOPPED';
      case exited:
        return 'EXITED';
      case unknown:
        return 'UNKNOWN';
    }
  }
}

class ContainerInfo {
  final String name;
  final String image;
  final ContainerState state;
  final String created;

  ContainerInfo({
    required this.name,
    required this.image,
    required this.state,
    required this.created,
  });

  factory ContainerInfo.fromOutput(String line) {
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 4) {
      throw FormatException('Invalid container output format: $line');
    }

    return ContainerInfo(
      name: parts[0],
      image: parts[1],
      state: parseStatus(parts[2]),
      created: parts[3],
    );
  }

  factory ContainerInfo.fromJson(Map<String, dynamic> json) {
    return ContainerInfo(
      name: json['container_name'] ?? '',
      image: json['image'] ?? '',
      state: parseStatus(json['status'] ?? ''),
      created: json['created'] ?? '',
    );
  }

  static parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'creating':
        return ContainerState.creating;
      case 'ready':
        return ContainerState.ready;
      case 'created':
        return ContainerState.created;
      case 'running':
        return ContainerState.running;
      case 'stopped':
        return ContainerState.stopped;
      default:
        return ContainerState.unknown;
    }
  }
}

class ContainerStatus {
  final String name;
  final ContainerState status;
  final String? image;
  final String? logFile;
  final String? logDescription;
  final List<String> commands;

  ContainerStatus({
    required this.name,
    required this.status,
    this.image,
    this.logFile,
    this.logDescription,
    this.commands = const [],
  });

  factory ContainerStatus.fromOutput(List<CommandOutput> outputs) {
    String? name;
    ContainerState? status;
    String? image;
    String? logFile;

    for (final output in outputs) {
      if (output.type != OutputType.stdout) continue;

      final line = output.line.trim();

      if (line.startsWith('Container: ')) {
        name = line.substring(11);
      } else if (line.startsWith('Status: ')) {
        status = ContainerInfo.parseStatus(line.substring(8));
      } else if (line.startsWith('Image: ')) {
        image = line.substring(7);
      } else if (line.startsWith('Unified log file: ')) {
        logFile = line.substring(18);
      }
    }

    if (name == null || status == null) {
      throw FormatException('Missing required container name or status');
    }

    return ContainerStatus(
      name: name,
      status: status,
      image: image,
      logFile: logFile,
    );
  }

  factory ContainerStatus.fromJson(Map<String, dynamic> json) {
    return ContainerStatus(
      name: json['container'] ?? '',
      status: ContainerInfo.parseStatus(json['status'] ?? ''),
      image: json['image'],
      logFile: json['log_file'],
    );
  }
}
