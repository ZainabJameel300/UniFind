import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:unifind/Components/my_filter_chip.dart';
import 'package:unifind/Components/my_drawer_button.dart';
import 'package:unifind/providers/filter_provider.dart';

class FiltersDrawer extends StatefulWidget {
  const FiltersDrawer({super.key});

  @override
  State<FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends State<FiltersDrawer> {
  final List<String> statuses = ["Claimed", "Unclaimed"];
  final List<String> categories = [
    "Electronics",
    "Wallets",
    "Keys",
    "Bags",
    "Accessories",
    "Books",
    "Other",
  ];

  void filterStatus(String status) {
    Provider.of<FilterProvider>(context, listen: false).filterStatus(status);
  }
  void filterCategory(String category) {
    Provider.of<FilterProvider>(context, listen: false).filterCategory(category); 
  }

  void closeDrawer() {
    Navigator.of(context).pop();
  }
  void clearFilter() {
    Provider.of<FilterProvider>(context, listen: false).clearFilters(); 
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context); 

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: closeDrawer,
                  ),
                  Expanded(
                    child: Center(
                      child: const Text(
                        "Filter",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status filter
              const Text(
                "Status",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: statuses.map(
                  (status) => MyFilterChip(
                    label: status,
                    isSelected: filterProvider.selectedStatuses.contains(status),
                    onSelected: (_) => filterStatus(status),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),

              // Category filter
              const Text(
                "Category",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: categories.map(
                  (category) => MyFilterChip(
                    label: category,
                    isSelected: filterProvider.selectedCategories.contains(category),
                    onSelected: (_) => filterCategory(category),
                  ),
                ).toList(),
              ),
              const Spacer(),

              // buttons 
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyDrawerButton(
                    text: "Clear",
                    onTap: clearFilter, 
                  ),
                  const SizedBox(width: 10),
                  MyDrawerButton(
                    text: "Apply",
                    onTap: closeDrawer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
