import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  Set<String> selectedStatuses = {};
  Set<String> selectedCategories = {};
  String? postType;

  // filter status
  void filterStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
    notifyListeners();
  }

  // filter category
  void filterCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    notifyListeners();
  }

  // set post type
  void setType(String? type) {
    postType = type;
    notifyListeners();
  }

  // clear drawer filters
  void clearFilters() {
    selectedStatuses.clear();
    selectedCategories.clear();
    notifyListeners();
  }
}

