import 'package:flutter/material.dart';

class MyChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function(bool)? onSelected;

  const MyChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11,
        color: selected ? const Color(0xFF771F98) : Colors.grey[700],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: selected ? const Color(0xFF771F98) : Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      visualDensity: VisualDensity.compact, 
    );
  }
}
