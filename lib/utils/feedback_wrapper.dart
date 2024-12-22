import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedbackWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableFeedback;

  const FeedbackWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
        if (enableFeedback) {
          HapticFeedback.lightImpact();
        }
        onTap?.call();
      },
      child: child,
    );
  }
}