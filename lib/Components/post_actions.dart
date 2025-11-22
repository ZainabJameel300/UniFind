import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostActions {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onToggleClaim,
    required VoidCallback onViewMatches,
    required VoidCallback onDeletePost,
    required bool isClaimed,
  }) async {
    // Dynamic height depending on claim_status
    final sheetHeight = isClaimed
        ? MediaQuery.of(context).size.height * 0.23
        : MediaQuery.of(context).size.height * 0.32;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SizedBox(
          height: sheetHeight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Column(
              children: [
                // Grey Bar
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                //  Mark Claimed / Unclaimed
                _bottomOption(
                  icon: Symbols.task_alt,
                  iconcolor: Color(0xFF771F98),
                  label: isClaimed ? "Mark as Unclaimed" : "Mark as Claimed",
                  textcolor: Colors.black87,
                  onTap: () {
                    Navigator.pop(context);
                    onToggleClaim();
                  },
                ),

                SizedBox(height: isClaimed ? 0 : 14),

                //  View Suggested Matches
                if (!isClaimed)
                  _bottomOption(
                    icon: Symbols.search,
                    iconcolor: Color(0xFF771F98),
                    label: "View Suggested Matches",
                    textcolor: Colors.black87,
                    onTap: () {
                      Navigator.pop(context);
                      onViewMatches();
                    },
                  ),

                const SizedBox(height: 14),

                //  Delete Post
                _bottomOption(
                  icon: Symbols.delete,
                  iconcolor: Colors.red,
                  label: "Delete Post",
                  textcolor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    onDeletePost();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _bottomOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconcolor,
    required Color textcolor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Icon(icon, color: iconcolor, size: 26),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textcolor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
