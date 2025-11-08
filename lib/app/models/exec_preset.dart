class ExecPreset {
  final String name;
  final String command;
  final String description;

  ExecPreset({
    required this.name,
    required this.command,
    this.description = '',
  });

  factory ExecPreset.fromJson(Map<String, dynamic> json) {
    return ExecPreset(
      name: json['name'] as String,
      command: json['command'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'command': command,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExecPreset &&
        other.name == name &&
        other.command == command &&
        other.description == description;
  }

  @override
  int get hashCode => name.hashCode ^ command.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'ExecPreset(name: $name, command: $command, description: $description)';
  }
}