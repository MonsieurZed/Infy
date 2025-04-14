import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';

class HeroWidget extends StatefulWidget {
  const HeroWidget({super.key, this.width});
  final double? width;

  @override
  State<HeroWidget> createState() => _HeroWidgetState();
}

class _HeroWidgetState extends State<HeroWidget> {
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
