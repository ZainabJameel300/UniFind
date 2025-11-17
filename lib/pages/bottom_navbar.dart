import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:unifind/Components/badge_icon.dart';
import 'package:unifind/Components/filters/filters_drawer.dart';
import 'package:unifind/pages/home_page.dart';
import 'package:unifind/pages/keepers_page.dart';
import 'package:unifind/pages/report_item_page.dart';
import 'package:unifind/pages/chatrooms_page.dart';
import 'package:unifind/pages/profile_page.dart';
import 'package:unifind/services/chat_service.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final chatService = ChatService();
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const KeepersPage(),
    const ReportItemPage(),
    const ChatroomsPage(),
    const ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const FiltersDrawer(),
      body: pages[selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.08), 
              width: 1,
            ),
          ),
        ),

        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black45,
          showSelectedLabels: false,
          showUnselectedLabels: false,

          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(
                Symbols.home,
                fill: selectedIndex == 0 ? 1 : 0,
                size: 28,
              ),
            ),

            BottomNavigationBarItem(
              label: "Keepers",
              icon: Icon(
                Symbols.location_on,
                fill: selectedIndex == 1 ? 1 : 0,
                size: 28,
              ),
            ),

            BottomNavigationBarItem(
              label: "Add",
              icon: Container(
                width: 40, 
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.06), 
                ),
                child: Center(
                  child: Icon(
                    Symbols.add,
                    size: 28, 
                  ),
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: "Chats",
              icon: BadgeIcon(
                badgeStream: chatService.unreadChatsCount(),
                icon: Icon(
                  Symbols.chat_bubble,
                  fill: selectedIndex == 3 ? 1 : 0,
                  size: 28,
                ),
              ),
            ),

            BottomNavigationBarItem(
              label: "Profile",
              icon: Icon(
                Symbols.person,
                fill: selectedIndex == 4 ? 1 : 0,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
