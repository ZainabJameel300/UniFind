import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart'; 
import 'package:unifind/Components/my_choice_chip.dart';
import 'package:unifind/Components/my_drawer_button.dart';
import 'package:unifind/providers/filter_provider.dart';

class FiltersDrawer extends StatefulWidget {
  const FiltersDrawer({super.key});

  @override
  State<FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends State<FiltersDrawer> {
   final List<String> categories = [
    "Electronics",
    "Charger",
    "Cards",
    "Wallet",
    "Keys",
    "Bags",
    "Accessories",
    "Books",
    "Other",
  ];

  final List<String> locations = [
    "S1-Buissness College",
    "S1-Art College",
    "S18-All Purpose Hall",
    "S20-English Language Center",
    "S20-A",
    "S20-B",
    "S20-C",
    "S22-BTC",
    "S3-Central Library",
    "S37-Registeration",
    "S39-Law College",
    "S4-Food Court",
    "S40-IT College",
    "S41-Science College",
    "S47-Sciance and IT Library",
    "S48-Class Rooms",
    "S50-Khunji Hall",
    "S51-Food Court",
    "S6-Mosque",
    "S27-College of Engineering",
    "College of Health and Sciences",
  ];

  final List<String> dates = [
    "Today", 
    "This week", 
    "This month",
    "Last 3 months",
    "Last 6 months",
  ];

  void closeDrawer() {
    Navigator.of(context).pop();
  }
  void clearFilter() {
    Provider.of<FilterProvider>(context, listen: false).clearFilters(); 
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context); 
    final initialCount = 4;
    final isExpanded = filterProvider.locationExpanded;
    final displayedLocations = isExpanded
        ? locations
        : locations.sublist(0, initialCount);


    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Symbols.close),
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
              const SizedBox(height: 16),

              // filters
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category filter
                      const Text(
                        "Category",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 6, 
                        children: categories.map(
                          (category) => MyChoiceChip(
                            label: category,
                            selected: filterProvider.selectedCategory == category, 
                            onSelected: (bool selected) {
                              filterProvider.setCategory(selected ? category : null);
                            },
                          )
                        ).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Date filter
                      const Text(
                        "Date of Loss",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        children: dates.map(
                          (date) => MyChoiceChip(
                            label: date,
                            selected: filterProvider.selectedDate == date,
                            onSelected: (bool selected) {
                              filterProvider.setDate(selected ? date : null);
                            },
                          ),
                        )
                        .toList(),
                      ),
                      const SizedBox(height: 20),
                                
                      // Location filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Location",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(
                              isExpanded ? Symbols.keyboard_arrow_up : Symbols.keyboard_arrow_down,
                              size: 20,
                            ),
                            onPressed: () => setState(() {
                              filterProvider.toggleLocationExpanded();
                            }),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          ...displayedLocations.map(
                            (location) => MyChoiceChip(
                              label: location,
                              selected: filterProvider.selectedLocation == location,
                              onSelected: (selected) {
                                filterProvider.setLocation(selected ? location : null);
                              },
                            ),
                          ),
                          // show more button
                          if (!isExpanded)
                            GestureDetector(
                              onTap: () => setState(() {
                                filterProvider.toggleLocationExpanded();
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                margin: const EdgeInsets.only(left: 4, top: 4),
                                child: const Text(
                                  "...",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
