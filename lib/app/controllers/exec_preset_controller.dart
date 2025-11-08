import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:acontainer/app/models/exec_preset.dart';
import 'package:acontainer/app/utils/logger.dart';

class ExecPresetController extends GetxController {
  final Logger _logger = Logger('ExecPresetController');
  final box = GetStorage();

  final RxList<ExecPreset> presets = <ExecPreset>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  static const String _storageKey = 'exec_presets';

  @override
  void onInit() {
    super.onInit();
    _loadPresets();
    _addDefaultPresetsIfEmpty();
  }

  void _loadPresets() {
    try {
      final List<dynamic> storedPresets = box.read(_storageKey) ?? [];
      presets.value = storedPresets
          .map((json) => ExecPreset.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.i('Loaded ${presets.length} exec presets');
    } catch (e) {
      _logger.e('Failed to load exec presets: $e');
      errorMessage.value = 'Failed to load presets: $e';
    }
  }

  void _addDefaultPresetsIfEmpty() {
    if (presets.isEmpty) {
      _addDefaultPresets();
    }
  }

  void _addDefaultPresets() {
    final defaultPresets = [
      ExecPreset(
        name: 'Login Shell',
        command: 'login',
        description: 'Login to Alpine Linux shell',
      ),
      ExecPreset(
        name: 'Bash Shell',
        command: '/bin/bash',
        description: 'Start bash shell',
      ),
      ExecPreset(
        name: 'Sh Shell',
        command: '/bin/sh',
        description: 'Start sh shell',
      ),
      ExecPreset(
        name: 'System Info',
        command: 'uname -a',
        description: 'Show system information',
      ),
      ExecPreset(
        name: 'Process List',
        command: 'ps aux',
        description: 'Show running processes',
      ),
      ExecPreset(
        name: 'Network Info',
        command: 'ip addr show',
        description: 'Show network interface information',
      ),
      ExecPreset(
        name: 'Environment Variables',
        command: 'env',
        description: 'Show environment variables',
      ),
    ];

    presets.addAll(defaultPresets);
    _savePresets();
  }

  void _savePresets() {
    try {
      final List<Map<String, dynamic>> presetsJson = presets
          .map((preset) => preset.toJson())
          .toList();
      box.write(_storageKey, presetsJson);
      _logger.i('Saved ${presets.length} exec presets');
    } catch (e) {
      _logger.e('Failed to save exec presets: $e');
      errorMessage.value = 'Failed to save presets: $e';
    }
  }

  void addPreset(ExecPreset preset) {
    if (preset.name.trim().isEmpty || preset.command.trim().isEmpty) {
      errorMessage.value = 'Name and command are required';
      return;
    }

    // Check for duplicate names
    if (presets.any((p) => p.name.toLowerCase() == preset.name.toLowerCase())) {
      errorMessage.value = 'A preset with this name already exists';
      return;
    }

    presets.add(preset);
    _savePresets();
    errorMessage.value = '';
  }

  void updatePreset(int index, ExecPreset preset) {
    if (index < 0 || index >= presets.length) return;

    if (preset.name.trim().isEmpty || preset.command.trim().isEmpty) {
      errorMessage.value = 'Name and command are required';
      return;
    }

    // Check for duplicate names (excluding current preset)
    if (presets.any(
      (p) =>
          p.name.toLowerCase() == preset.name.toLowerCase() &&
          presets.indexOf(p) != index,
    )) {
      errorMessage.value = 'A preset with this name already exists';
      return;
    }

    presets[index] = preset;
    _savePresets();
    errorMessage.value = '';
  }

  void deletePreset(int index) {
    if (index < 0 || index >= presets.length) return;

    final preset = presets[index];
    presets.removeAt(index);
    _savePresets();
    _logger.i('Deleted preset: ${preset.name}');
  }

  void movePreset(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= presets.length ||
        newIndex < 0 ||
        newIndex >= presets.length) {
      return;
    }

    final preset = presets.removeAt(oldIndex);
    presets.insert(newIndex, preset);
    _savePresets();
  }

  void clearError() {
    errorMessage.value = '';
  }
}

