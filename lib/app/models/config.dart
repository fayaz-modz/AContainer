import 'package:yaml_writer/yaml_writer.dart';
import 'package:yaml/yaml.dart';

class Config {
  final String runtime;
  final String runpath;
  final String containersPath;
  final Map<String, String> registries;

  Config({
    required this.runtime,
    required this.runpath,
    required this.containersPath,
    required this.registries,
  });

  factory Config.fromYaml(String yamlString) {
    final yamlMap = loadYaml(yamlString) as YamlMap;
    return Config(
      runtime: yamlMap['runtime'] as String,
      runpath: yamlMap['runpath'] as String,
      containersPath: yamlMap['containers_path'] as String,
      registries: Map<String, String>.from(yamlMap['registries'] as Map),
    );
  }

  String toYaml() {
    final writer = YamlWriter();
    return writer.write({
      'runtime': runtime,
      'runpath': runpath,
      'containers_path': containersPath,
      'registries': registries,
    });
  }
}
