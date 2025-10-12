import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  String postType = "All";
  String? selectedCategory;
  String? selectedDate;
  String? selectedLocation;
  bool locationExpanded = false;


  // set post type
  void setType(String type) {
    postType = type;
    notifyListeners();
  }

  // set category
  void setCategory(String? category) {
    selectedCategory = category;
    notifyListeners();
  }

  // set date
  void setDate(String? date) {
    selectedDate = date;
    notifyListeners();
  }

  // set location
  void setLocation(String? location) {
    selectedLocation = location;
    notifyListeners();
  }
  void toggleLocationExpanded() {
    locationExpanded = !locationExpanded;
  }

  // clear drawer filters
  void clearFilters() {
    bool changed = false;

    if (selectedCategory != null) {
      selectedCategory = null;
      changed = true;
    }
    if (selectedDate != null) {
      selectedDate = null;
      changed = true;
    }
    if (selectedLocation != null) {
      selectedLocation = null;
      changed = true;
    }

    if (changed) notifyListeners();
  }

  bool get hasAnyFilter{
    return selectedCategory != null  || selectedDate != null || selectedLocation != null;
  }
}

