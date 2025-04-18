import 'package:flutter/material.dart';

class WebLogoWidget extends StatelessWidget {
  final double size;

  const WebLogoWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'app_logo',
      child: Image.asset(
        'assets/images/icon-full.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
