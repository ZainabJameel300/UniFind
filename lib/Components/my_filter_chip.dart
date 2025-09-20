import 'package:flutter/material.dart';

class MyFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final void Function(bool)? onSelected;

  const MyFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      showCheckmark: false,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? const Color(0xFF771F98) : Colors.grey[700],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isSelected ? const Color(0xFF771F98) : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
    );
  }
}
