import 'package:flutter/material.dart';

class NetworkIconWidget extends StatelessWidget {
  const NetworkIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: const Icon(
              Icons.wifi_off,
              size: 60,
              color: Colors.red,
            ),
          );
        },
      ),
    );
  }
}