import 'package:flutter/material.dart';

class RefreshableScrollView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final ScrollPhysics? physics;

  const RefreshableScrollView({
    super.key,
    required this.onRefresh,
    required this.children,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
