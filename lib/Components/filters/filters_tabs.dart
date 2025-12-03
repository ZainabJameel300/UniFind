import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unifind/providers/filter_provider.dart';

class FiltersTabs extends StatefulWidget {
  const FiltersTabs({super.key});

  @override
  State<FiltersTabs> createState() => _FiltersTabsState();
}

class _FiltersTabsState extends State<FiltersTabs> {
  List<bool> selections = [true, false, false];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filterProvider = Provider.of<FilterProvider>(context);
    final type = filterProvider.postType;

    // update selections according to provider
    setState(() {
      selections = [type == "All", type == "Lost", type == "Found"];
    });
  }

  void changeType(int index) {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    if (index == 0) {
      filterProvider.setType("All");
    } else if (index == 1) {
      filterProvider.setType("Lost");
    } else if (index == 2) {
      filterProvider.setType("Found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: selections,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < selections.length; i++) {
            selections[i] = i == index;
          }
        });
        // update provider type filter
        changeType(index);
      },
      renderBorder: false,
      color: Colors.black45,
      selectedColor: const Color(0xFF771F98),
      fillColor: Colors.white,
      splashColor: Colors.transparent,
      children: List.generate(selections.length, (index) {
        final labels = ["All", "Lost", "Found"];
        final isSelected = selections[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFF1F1F1)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(labels[index], style: const TextStyle(fontSize: 20.0)),
        );
      }),
    );
  }
}
