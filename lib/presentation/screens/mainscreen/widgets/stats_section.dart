import 'package:flutter/material.dart';

import '../../../../core/app_localization.dart';
import '../../../bloc/userlist/userlist_state.dart';
import 'responsive_statuscard.dart';


class StatsSectionWidget extends StatelessWidget {
  final UsersState state;
  final AppLocalizations localizations;
  final bool isTablet;
  final bool isDesktop;

  const StatsSectionWidget({
    super.key,
    required this.state,
    required this.localizations,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    int totalUsers = 0;
    int? currentPage = 1;

    if (state is UsersLoaded) {
      totalUsers = state.users.length;
      currentPage = state.currentPage;
    }

    if (isDesktop) {
      // Desktop: 4 columns or more stats
      return Row(
        children: [
          Expanded(
            child: ResponsiveStatsCard(
              title: localizations.totalUsers,
              count: totalUsers.toString(),
              icon: Icons.people,
              color: const Color(0xFF4CAF50),
              isLarge: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ResponsiveStatsCard(
              title: localizations.currentPage,
              count: currentPage.toString(),
              icon: Icons.pages,
              color: const Color(0xFF2196F3),
              isLarge: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ResponsiveStatsCard(
              title: "Online",
              count: "Yes",
              icon: Icons.wifi,
              color: const Color(0xFF4CAF50),
              isLarge: true,
            ),
          ),
        ],
      );
    } else if (isTablet) {
      // Tablet: 2 columns with larger cards
      return Row(
        children: [
          Expanded(
            child: ResponsiveStatsCard(
              title: localizations.totalUsers,
              count: totalUsers.toString(),
              icon: Icons.people,
              color: const Color(0xFF4CAF50),
              isLarge: true,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ResponsiveStatsCard(
              title: localizations.currentPage,
              count: currentPage.toString(),
              icon: Icons.pages,
              color: const Color(0xFF2196F3),
              isLarge: true,
            ),
          ),
        ],
      );
    } else {
      // Mobile: 2 columns with smaller cards
      return Row(
        children: [
          Expanded(
            child: ResponsiveStatsCard(
              title: localizations.totalUsers,
              count: totalUsers.toString(),
              icon: Icons.people,
              color: const Color(0xFF4CAF50),
              isLarge: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ResponsiveStatsCard(
              title: localizations.currentPage,
              count: currentPage.toString(),
              icon: Icons.pages,
              color: const Color(0xFF2196F3),
              isLarge: false,
            ),
          ),
        ],
      );
    }
  }
}