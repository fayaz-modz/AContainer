import 'dart:math' as math;
import 'package:acontainer/app/theme/app_themes.dart';
import 'package:acontainer/app/theme/terminal_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart' as xterm;

class TerminalSettingsView extends StatelessWidget {
  const TerminalSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final terminalThemeController = TerminalThemeController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Terminal Theme'),
          _buildTerminalThemeSelector(context, terminalThemeController),
          const SizedBox(height: 24),

          _buildSectionTitle('Custom Terminal Theme'),
          _buildCustomThemeSection(context, terminalThemeController),
          const SizedBox(height: 24),

          _buildSectionTitle('Preview'),
          _buildTerminalPreview(context, terminalThemeController),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTerminalThemeSelector(
    BuildContext context,
    TerminalThemeController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.terminal_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Terminal Theme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...AppThemes.allThemes.map((theme) {
                    final isSelected =
                        controller.currentThemeName == theme.name;
                    return FilterChip(
                      label: Text(
                        theme.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.setTheme(theme.name);
                        }
                      },
                    );
                  }),
                  FilterChip(
                    label: Text(
                      'Custom',
                      style: TextStyle(
                        color: controller.currentThemeName == 'custom'
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: controller.currentThemeName == 'custom',
                    onSelected: (selected) {
                      if (selected) {
                        controller.setTheme('custom');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomThemeSection(
    BuildContext context,
    TerminalThemeController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => controller.resetToDefault(),
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => _showLoadFromThemeDialog(controller),
                  child: const Text('Load from Theme'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: [
                  _buildColorRow(
                    context,
                    'Background',
                    controller.terminalTheme.background,
                    (color) => controller.updateCustomTheme(background: color),
                  ),
                  _buildColorRow(
                    context,
                    'Foreground',
                    controller.terminalTheme.foreground,
                    (color) => controller.updateCustomTheme(foreground: color),
                  ),
                  _buildColorRow(
                    context,
                    'Cursor',
                    controller.terminalTheme.cursor,
                    (color) => controller.updateCustomTheme(cursor: color),
                  ),
                  _buildColorRow(
                    context,
                    'Selection',
                    controller.terminalTheme.selection,
                    (color) => controller.updateCustomTheme(selection: color),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ANSI Colors',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildColorRow(
                    context,
                    'Black',
                    controller.terminalTheme.black,
                    (color) => controller.updateCustomTheme(black: color),
                  ),
                  _buildColorRow(
                    context,
                    'Red',
                    controller.terminalTheme.red,
                    (color) => controller.updateCustomTheme(red: color),
                  ),
                  _buildColorRow(
                    context,
                    'Green',
                    controller.terminalTheme.green,
                    (color) => controller.updateCustomTheme(green: color),
                  ),
                  _buildColorRow(
                    context,
                    'Yellow',
                    controller.terminalTheme.yellow,
                    (color) => controller.updateCustomTheme(yellow: color),
                  ),
                  _buildColorRow(
                    context,
                    'Blue',
                    controller.terminalTheme.blue,
                    (color) => controller.updateCustomTheme(blue: color),
                  ),
                  _buildColorRow(
                    context,
                    'Magenta',
                    controller.terminalTheme.magenta,
                    (color) => controller.updateCustomTheme(magenta: color),
                  ),
                  _buildColorRow(
                    context,
                    'Cyan',
                    controller.terminalTheme.cyan,
                    (color) => controller.updateCustomTheme(cyan: color),
                  ),
                  _buildColorRow(
                    context,
                    'White',
                    controller.terminalTheme.white,
                    (color) => controller.updateCustomTheme(white: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(
    BuildContext context,
    String label,
    Color color,
    Function(Color) onColorChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.colorize_outlined),
            onPressed: () =>
                _showColorPicker(context, label, color, onColorChanged),
            tooltip: 'Change color',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalPreview(
    BuildContext context,
    TerminalThemeController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Terminal Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: controller.terminalTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: xterm.TerminalView(
                    xterm.Terminal(
                      maxLines: 100,
                      platform: xterm.TerminalTargetPlatform.linux,
                    )..write(
                      '\x1b[0m\x1b[1mTerminal Preview\x1b[0m\r\n'
                      '\x1b[32m\$ \x1b[0mecho "Hello, World!"\r\n'
                      'Hello, World!\r\n'
                      '\x1b[32m\$ \x1b[0m\x1b[31mls -la\x1b[0m\r\n'
                      '\x1b[34mtotal 16\x1b[0m\r\n'
                      '\x1b[32mdrwxr-xr-x\x1b[0m  3 user user 4096 Nov  5 12:00 \x1b[34m.\x1b[0m\r\n'
                      '\x1b[32mdrwxr-xr-x\x1b[0m 10 user user 4096 Nov  5 11:00 \x1b[34m..\x1b[0m\r\n'
                      '\x1b[33m-rw-r--r--\x1b[0m  1 user user  220 Nov  5 10:30 config.txt\r\n'
                      '\x1b[33m-rwxr-xr-x\x1b[0m  1 user user 1024 Nov  5 09:15 script.sh\r\n'
                      '\x1b[32m\$ \x1b[0m',
                    ),
                    theme: controller.terminalTheme,
                    hardwareKeyboardOnly: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Choose $label Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showLoadFromThemeDialog(TerminalThemeController controller) {
    showDialog(
      context: Get.context!,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Load from Theme'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppThemes.allThemes.length,
            itemBuilder: (context, index) {
              final theme = AppThemes.allThemes[index];
              return ListTile(
                title: Text(theme.displayName),
                onTap: () {
                  controller.loadFromAppTheme(theme.name);
                  controller.setTheme('custom');
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color color;
  final Function(Color) onColorChanged;

  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 200,
          child: HueRingPicker(
            color: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              widget.onColorChanged(color);
            },
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Hex Color',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text:
                '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
          ),
          onChanged: (value) {
            if (value.startsWith('#') && value.length == 7) {
              try {
                final color = Color(
                  int.parse(value.substring(1), radix: 16) + 0xFF000000,
                );
                setState(() {
                  _selectedColor = color;
                });
                widget.onColorChanged(color);
              } catch (e) {
                // Invalid hex color
              }
            }
          },
        ),
      ],
    );
  }
}

class HueRingPicker extends StatelessWidget {
  final Color color;
  final Function(Color) onColorChanged;

  const HueRingPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HueRingPainter(color: color, onColorChanged: onColorChanged),
      child: Container(),
    );
  }
}

class HueRingPainter extends CustomPainter {
  final Color color;
  final Function(Color) onColorChanged;

  HueRingPainter({required this.color, required this.onColorChanged});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw hue ring
    final hueRingPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          const Color(0xFFFF00FF), // magenta
          Colors.red,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, hueRingPaint);

    // Draw inner circle (saturation/lightness)
    final innerRadius = radius * 0.7;
    final saturationPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          HSLColor.fromColor(color).withSaturation(1.0).toColor(),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));

    canvas.drawCircle(center, innerRadius, saturationPaint);

    // Draw color indicator
    final hslColor = HSLColor.fromColor(color);
    final angle = hslColor.hue * math.pi / 180;
    final indicatorOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(indicatorOffset, 8, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
