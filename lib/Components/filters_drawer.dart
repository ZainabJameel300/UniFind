import 'package:flutter/material.dart';
import 'package:unifind/Components/my_filter_chip.dart';
import 'package:unifind/Components/my_drawer_button.dart';

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

  Set<String> selectedStatuses = {};
  Set<String> selectedCategories = {};

  void applyFilter() {
    Navigator.of(context).pop(); 
    print("Statuses: $selectedStatuses, Categories: $selectedCategories");
  }

  void clearFilter() {
    setState(() {
      selectedStatuses.clear();
      selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),

              // Status filter
              const Text("Status", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: statuses.map((status) {
                  return MyFilterChip(
                    label: status,
                    isSelected: selectedStatuses.contains(status),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedStatuses.add(status);
                        } else {
                          selectedStatuses.remove(status);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Category filter
              const Text("Category", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: categories.map((category) {
                  return MyFilterChip(
                    label: category,
                    isSelected: selectedCategories.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),

              // buttons row
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
                    onTap: applyFilter
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
