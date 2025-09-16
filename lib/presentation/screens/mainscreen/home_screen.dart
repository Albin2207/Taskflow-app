import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_localization.dart';
import '../../../core/constants.dart';
import '../../bloc/connectivity/connectivity_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/userlist/userlist_bloc.dart';
import '../../bloc/userlist/userlist_event.dart';
import 'dashboard_screen.dart';
import '../profilescreen/profile_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.getSafeLocalizations(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationTapped) {
              _handleNotificationNavigation(state.route, state.data);
            }
          },
        ),
        BlocListener<ConnectivityBloc, ConnectivityState>(
          listener: (context, connectivityState) {
            if (connectivityState is ConnectivityConnected) {
              context.read<NotificationBloc>().add(
                NotificationSendNetworkRestored(),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body:
            isDesktop
                ? _buildDesktopLayout(localizations)
                : _selectedIndex == 0
                ? const DashboardScreen()
                : const ProfileScreen(),
        bottomNavigationBar:
            !isDesktop ? _buildBottomNavigation(localizations, isTablet) : null,
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations localizations) {
    return Row(
      children: [
        // Navigation Rail for desktop
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.home),
              label: Text(localizations.home),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person),
              label: Text(localizations.profile),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Main content
        Expanded(
          child:
              _selectedIndex == 0
                  ? const DashboardScreen()
                  : const ProfileScreen(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(AppLocalizations localizations, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        selectedFontSize: isTablet ? 14 : 12,
        unselectedFontSize: isTablet ? 12 : 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: isTablet ? 28 : 24),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: isTablet ? 28 : 24),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }

  void _handleNotificationNavigation(String route, Map<String, dynamic> data) {
    switch (route) {
      case AppConstants.usersRoute:
        setState(() {
          _selectedIndex = 0;
        });
        context.read<UsersBloc>().add(const LoadUsersEvent(isRefresh: true));
        break;
      case AppConstants.profileRoute:
        setState(() {
          _selectedIndex = 1;
        });
        break;
      case AppConstants.homeRoute:
      default:
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }
}
