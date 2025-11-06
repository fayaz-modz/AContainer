import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_theme_controller.dart';

class ThemeWrapper extends StatelessWidget {
  final Widget child;

  const ThemeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}