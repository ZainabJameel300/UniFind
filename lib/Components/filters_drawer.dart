import 'package:flutter/material.dart';
import 'package:unifind/Components/app_button.dart';

class FiltersDrawer extends StatelessWidget {
  const FiltersDrawer({super.key});

  void applyFilter() {
    // get filtters
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            ListTile(title: Text("Filters",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),

            // status filter 
            ListTile(title: Text("Status")),

            // category filter
            ListTile(title: Text("Category")),

            Spacer(),

            // apply filter button 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AppButton(
                text: "Apply", 
                onTap: applyFilter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
