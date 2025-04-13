import 'package:flutter/material.dart';
import 'package:infy/data/style.dart';

class ContainerWidget extends StatefulWidget {
  const ContainerWidget({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  State<ContainerWidget> createState() => _ContainerWidgetState();
}

class _ContainerWidgetState extends State<ContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: KTextStylesCustom.titleTeal),
              Text(widget.description, style: KTextStylesCustom.descBasic),
            ],
          ),
        ),
      ), // Placeholder for the card widget'')])),
    );
  }
}
