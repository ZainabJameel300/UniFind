import 'package:flutter/material.dart';

class PostCardLoading extends StatelessWidget {
  const PostCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // row: avatar + name + type
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // avatar placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),

                // name + time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 10,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ],
                ),
                const Spacer(),

                // type pill
                Container(
                  width: 56,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // image placeholder
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 12),

            // title
            Container(width: 150, height: 14, color: const Color(0xFFE0E0E0)),

            const SizedBox(height: 10),

            // description (2 lines)
            Container(
              width: double.infinity,
              height: 10,
              color: const Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 10,
              color: const Color(0xFFE0E0E0),
            ),

            const SizedBox(height: 16),

            // details row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 70, height: 12, color: Color(0xFFE0E0E0)),
                Container(width: 70, height: 12, color: Color(0xFFE0E0E0)),
                Container(width: 70, height: 12, color: Color(0xFFE0E0E0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
