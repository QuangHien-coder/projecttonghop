import 'package:flutter/material.dart';
import '../models/category.dart';

// Widget StatelessWidget hien thi luoi cac danh muc de nguoi dung chon
class CategoryPicker extends StatelessWidget {
  final Category selectedCategory;
  final ValueChanged<Category> onSelected;

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Category.values.map((cat) {
        final isSelected = cat == selectedCategory;
        return ChoiceChip(
          avatar: Icon(
            cat.icon,
            size: 18,
            color: isSelected ? Colors.white : cat.color,
          ),
          label: Text(cat.label),
          selected: isSelected,
          selectedColor: cat.color,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (val) {
            if (val) onSelected(cat);
          },
        );
      }).toList(),
    );
  }
}

