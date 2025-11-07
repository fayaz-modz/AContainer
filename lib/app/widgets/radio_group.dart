import 'package:flutter/material.dart';

class CustomRadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final List<RadioListTile<T>> children;

  const CustomRadioGroup({
    super.key,
    this.groupValue,
    this.onChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged ?? (T? value) {},
      child: Column(
        children: children.map((e) {
          return RadioListTile<T>(
            title: e.title,
            subtitle: e.subtitle,
            value: e.value,
          );
        }).toList(),
      ),
    );
  }
}
