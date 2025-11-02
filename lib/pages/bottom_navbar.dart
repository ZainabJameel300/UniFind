import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/filters/filters_drawer.dart';
import 'package:unifind/pages/home_page.dart';
import 'package:unifind/pages/keepers_page.dart';
import 'package:unifind/pages/chatrooms_page.dart';
import 'package:unifind/pages/profile_page.dart';
import 'package:unifind/pages/report_item_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const KeepersPage(),
    const ReportItemPage(),
    ChatroomsPage(),
    const ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() => selectedIndex = index);
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(),
        child: Icon(
          icon,
          fill: isSelected ? 1 : 0,
          color: isSelected ? Colors.black : Colors.black45,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: selectedIndex == 0 ? const FiltersDrawer() : null,
      backgroundColor: Colors.white,
      body: pages[selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF771F98),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          onTabTapped(2);
        },
        child: const Icon(Symbols.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color(0xFFF1F1F1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Symbols.home, 0),
            _buildNavItem(Symbols.location_on, 1),

            const SizedBox(width: 40),

            _buildNavItem(Symbols.chat_bubble, 3),
            _buildNavItem(Symbols.person, 4),
          ],
        ),
      ),
    );
  }
}
