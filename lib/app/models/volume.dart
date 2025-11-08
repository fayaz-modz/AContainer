class VolumeInfo {
  final String name;
  final String driver;
  final String mountpoint;
  final String createdAt;
  final Map<String, String>? labels;
  final Map<String, String>? options;

  VolumeInfo({
    required this.name,
    required this.driver,
    required this.mountpoint,
    required this.createdAt,
    this.labels,
    this.options,
  });

  factory VolumeInfo.fromOutput(String line) {
    // Use a more robust regex that handles variable spacing
    final parts = line.split(RegExp(r'\s{2,}')); // Split on 2+ spaces
    
    List<String> finalParts;
    if (parts.length >= 4) {
      // Format with 4 columns: NAME, DRIVER, MOUNTPOINT, CREATED
      finalParts = parts.take(4).toList();
    } else if (parts.length == 3) {
      // Format with 3 columns: NAME, DRIVER, MOUNTPOINT (no created timestamp)
      finalParts = [
        parts[0], // name
        parts[1], // driver
        parts[2], // mountpoint
        '', // empty created timestamp
      ];
    } else {
      // Try to parse with regex for more complex cases
      final match = RegExp(r'^(\S+)\s+(\S+)\s+(\S+?)\s*(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})?$').firstMatch(line);
      if (match != null) {
        finalParts = [
          match.group(1)!, // name
          match.group(2)!, // driver  
          match.group(3)!, // mountpoint
          match.group(4) ?? '', // createdAt (optional)
        ];
      } else {
        throw FormatException('Invalid volume output format: $line');
      }
    }

    return VolumeInfo(
      name: finalParts[0],
      driver: finalParts[1],
      mountpoint: finalParts[2],
      createdAt: finalParts[3],
    );
  }

  factory VolumeInfo.fromJson(Map<String, dynamic> json) {
    return VolumeInfo(
      name: json['NAME'] ?? '',
      driver: json['DRIVER'] ?? '',
      mountpoint: json['MOUNTPOINT'] ?? '',
      createdAt: json['CREATED'] ?? '',
    );
  }

  @override
  String toString() {
    return 'VolumeInfo(name: $name, driver: $driver, mountpoint: $mountpoint, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VolumeInfo && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}