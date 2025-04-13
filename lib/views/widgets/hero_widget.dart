import 'package:flutter/material.dart';
import 'package:infy/data/constants.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, required this.title, this.nextpage});

  final String title;
  final Widget? nextpage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (nextpage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextpage!),
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: 'hero1',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                ImageString.bg,
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.1,
                color: Colors.teal,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
          FittedBox(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 50,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
