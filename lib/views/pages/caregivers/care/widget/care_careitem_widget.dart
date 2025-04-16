import 'package:flutter/material.dart';

class CareItemsWidget extends StatelessWidget {
  final String careType;
  final List<dynamic> items;
  final List<String> selectedCareItems;
  final Function(String) onItemSelected;

  const CareItemsWidget({
    super.key,
    required this.careType,
    required this.items,
    required this.selectedCareItems,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          careType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children:
              items.map((careItem) {
                final isSelected = selectedCareItems.contains(
                  careItem.documentId,
                );
                return SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => onItemSelected(careItem.documentId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                      padding: EdgeInsets.zero,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        careItem.name,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
