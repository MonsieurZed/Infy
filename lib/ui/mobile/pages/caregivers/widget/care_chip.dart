import 'package:flutter/material.dart';

class ChipCareWidget extends StatelessWidget {
  final String text;

  const ChipCareWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}
