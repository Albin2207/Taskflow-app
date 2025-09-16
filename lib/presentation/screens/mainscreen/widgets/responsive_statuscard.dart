import 'package:flutter/material.dart';

class ResponsiveStatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const ResponsiveStatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.isLarge,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isLarge ? 24.0 : 20.0;
    final iconSize = isLarge ? 24.0 : 20.0;
    final countFontSize = isLarge ? 28.0 : 24.0;
    final titleFontSize = isLarge ? 16.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 20 : 16),
          Text(
            count,
            style: TextStyle(
              fontSize: countFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}