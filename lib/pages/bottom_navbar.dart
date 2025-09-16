import 'package:flutter/material.dart';
import 'package:unifind/pages/home_page.dart';
import 'package:unifind/pages/keepers_page.dart';
import 'package:unifind/pages/chatRooms_page.dart';
import 'package:unifind/pages/profile_page.dart';
import 'package:unifind/pages/report_item_page.dart';


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const KeepersPage(),
    const ReportItemPage(), 
    const ChatRoomsPage(),
    const ProfilePage(),
  ];

  void onTabTapped(int index) {
      setState(() => selectedIndex = index);
  }

  Widget _buildNavItem(IconData selectedicon, IconData notselectedicon, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
        ),
        child: Icon(
          isSelected ? selectedicon : notselectedicon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: const Color(0xFFF1F1F1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, Icons.home_outlined, 0),
            _buildNavItem(Icons.location_on, Icons.location_on_outlined, 1),
        
            const SizedBox(width: 40),
        
            _buildNavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline, 3),
            _buildNavItem(Icons.person, Icons.person_outlined, 4),
          ],
        ),
      ),
    );
  }
}
