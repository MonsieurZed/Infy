import 'package:flutter/material.dart';
import 'package:infy/data/contants/constants.dart';

class LogoHeroWidget extends StatefulWidget {
  const LogoHeroWidget({super.key, this.width});
  final double? width;

  @override
  State<LogoHeroWidget> createState() => _LogoHeroWidgetState();
}

class _LogoHeroWidgetState extends State<LogoHeroWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'hero1',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              ImageString.logoFull,
              fit: BoxFit.fill,
              width: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
