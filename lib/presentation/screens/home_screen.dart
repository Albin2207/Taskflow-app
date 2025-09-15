import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_localization.dart';
import '../../core/constants.dart';
import '../../domain/entities/api_user_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/userlist/userlist_bloc.dart';
import '../bloc/userlist/userlist_event.dart';
import '../bloc/userlist/userlist_state.dart';
import 'profile_screen.dart';
import 'no_network_screen.dart';
import 'user_details_screen.dart';
import 'users_form_screen.dart';

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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UsersBloc>().add(const LoadUsersEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeNotificationOnFirstLoad();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showWelcomeNotificationOnFirstLoad() {
    final currentState = context.read<UsersBloc>().state;
    if (currentState is UsersInitial) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.read<NotificationBloc>().add(NotificationSendWelcome());
        }
      });
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UsersBloc>().add(LoadMoreUsersEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.getSafeLocalizations(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    // Responsive padding
    final horizontalPadding =
        isDesktop
            ? 32.0
            : isTablet
            ? 24.0
            : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildResponsiveAppBar(localizations, isTablet, isDesktop),
      body: BlocListener<ConnectivityBloc, ConnectivityState>(
        listener: (context, connectivityState) {
          if (connectivityState is ConnectivityDisconnected) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NoNetworkScreen()));
          }
        },
        child: BlocConsumer<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state is UsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is UsersOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<UsersBloc>().add(
                  const LoadUsersEvent(isRefresh: true),
                );
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Stats Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: _buildResponsiveStatsSection(
                        state,
                        localizations,
                        isTablet,
                        isDesktop,
                      ),
                    ),
                  ),

                  // Users List Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: _buildUsersListHeader(localizations, isTablet),
                    ),
                  ),

                  // Users List
                  if (state is UsersLoading && state is! UsersLoaded)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (state is UsersLoaded)
                    _buildResponsiveUsersList(
                      state,
                      localizations,
                      isTablet,
                      isDesktop,
                      horizontalPadding,
                    )
                  else if (state is UsersError)
                    SliverToBoxAdapter(
                      child: _buildErrorState(state.message, localizations),
                    )
                  else
                    SliverToBoxAdapter(child: _buildEmptyState(localizations)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(
    AppLocalizations localizations,
    bool isTablet,
    bool isDesktop,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: isTablet ? 72 : 56,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.welcomeBack,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  state.user.name.isEmpty
                      ? localizations.user
                      : state.user.name.split(' ').first,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }
          return Text(
            localizations.taskFlow,
            style: TextStyle(fontSize: isTablet ? 22 : 18),
          );
        },
      ),
      actions: [
        BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return IconButton(
              icon: const Icon(Icons.add_circle_outline),
              iconSize: isTablet ? 48 : 40,
              color:
                  connectivityState is ConnectivityConnected
                      ? const Color(0xFF1E88E5)
                      : Colors.grey,
              onPressed:
                  connectivityState is ConnectivityConnected
                      ? () => _navigateToUserForm(context)
                      : () => _showOfflineMessage(context),
            );
          },
        ),
        Container(
          margin: EdgeInsets.only(right: isTablet ? 24 : 16),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final radius = isTablet ? 24.0 : 18.0;
              final iconSize = isTablet ? 24.0 : 18.0;

              if (state is AuthAuthenticated && state.user.photoUrl != null) {
                return CircleAvatar(
                  radius: radius,
                  backgroundImage: NetworkImage(state.user.photoUrl!),
                );
              }
              return CircleAvatar(
                radius: radius,
                backgroundColor: const Color(0xFF1E88E5),
                child: Icon(Icons.person, color: Colors.white, size: iconSize),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveStatsSection(
    UsersState state,
    AppLocalizations localizations,
    bool isTablet,
    bool isDesktop,
  ) {
    int totalUsers = 0;
    int currentPage = 1;

    if (state is UsersLoaded) {
      totalUsers = state.users.length;
      currentPage = state.currentPage;
    }

    if (isDesktop) {
      // Desktop: 4 columns or more stats
      return Row(
        children: [
          Expanded(
            child: _ResponsiveStatsCard(
              title: localizations.totalUsers,
              count: totalUsers.toString(),
              icon: Icons.people,
              color: const Color(0xFF4CAF50),
              isLarge: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _ResponsiveStatsCard(
              title: localizations.currentPage,
              count: currentPage.toString(),
              icon: Icons.pages,
              color: const Color(0xFF2196F3),
              isLarge: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _ResponsiveStatsCard(
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
            child: _ResponsiveStatsCard(
              title: localizations.totalUsers,
              count: totalUsers.toString(),
              icon: Icons.people,
              color: const Color(0xFF4CAF50),
              isLarge: true,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _ResponsiveStatsCard(
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
            child: _ResponsiveStatsCard(
              title: localizations.totalUsers,
              count: totalUsers.toString(),
              icon: Icons.people,
              color: const Color(0xFF4CAF50),
              isLarge: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ResponsiveStatsCard(
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

  Widget _buildUsersListHeader(AppLocalizations localizations, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.users,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return TextButton.icon(
              onPressed:
                  connectivityState is ConnectivityConnected
                      ? () => context.read<UsersBloc>().add(
                        const LoadUsersEvent(isRefresh: true),
                      )
                      : null,
              icon: Icon(Icons.refresh, size: isTablet ? 20 : 18),
              label: Text(
                localizations.refresh,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveUsersList(
    UsersLoaded state,
    AppLocalizations localizations,
    bool isTablet,
    bool isDesktop,
    double horizontalPadding,
  ) {
    if (isDesktop) {
      // Desktop: Grid layout
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= state.users.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildResponsiveUserCard(
              state.users[index],
              localizations,
              isTablet,
              isDesktop,
            );
          }, childCount: state.users.length + (state.isLoadingMore ? 1 : 0)),
        ),
      );
    } else {
      // Mobile & Tablet: List layout
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= state.users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = state.users[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              index == 0 ? 8 : 4,
              horizontalPadding,
              index == state.users.length - 1 ? 16 : 4,
            ),
            child: _buildResponsiveUserCard(
              user,
              localizations,
              isTablet,
              isDesktop,
            ),
          );
        }, childCount: state.users.length + (state.isLoadingMore ? 1 : 0)),
      );
    }
  }

  Widget _buildResponsiveUserCard(
    ApiUserEntity user,
    AppLocalizations localizations,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding =
        isDesktop
            ? 20.0
            : isTablet
            ? 18.0
            : 16.0;
    final avatarRadius =
        isDesktop
            ? 35.0
            : isTablet
            ? 32.0
            : 30.0;
    final titleFontSize =
        isDesktop
            ? 18.0
            : isTablet
            ? 17.0
            : 16.0;
    final subtitleFontSize =
        isDesktop
            ? 15.0
            : isTablet
            ? 14.0
            : 14.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(cardPadding),
        leading: CircleAvatar(
          radius: avatarRadius,
          backgroundImage: NetworkImage(user.avatar),
          backgroundColor: Colors.grey[300],
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: titleFontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey, fontSize: subtitleFontSize),
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${localizations.id}: ${user.id}',
                style: TextStyle(
                  color: const Color(0xFF1E88E5),
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return PopupMenuButton<String>(
              enabled: connectivityState is ConnectivityConnected,
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: const Icon(Icons.visibility),
                        title: Text(localizations.view),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: const Icon(Icons.edit),
                        title: Text(localizations.edit),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          localizations.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
              onSelected: (value) {
                if (connectivityState is ConnectivityDisconnected) {
                  _showOfflineMessage(context);
                  return;
                }

                switch (value) {
                  case 'view':
                    _navigateToUserDetail(context, user);
                    break;
                  case 'edit':
                    _navigateToUserForm(context, user: user);
                    break;
                  case 'delete':
                    _showDeleteDialog(context, user);
                    break;
                }
              },
            );
          },
        ),
        onTap: () => _navigateToUserDetail(context, user),
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              localizations.errorLoadingUsers,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UsersBloc>().add(const LoadUsersEvent());
              },
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              localizations.noUsersFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.addFirstUser,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ConnectivityBloc, ConnectivityState>(
              builder: (context, connectivityState) {
                return ElevatedButton.icon(
                  onPressed:
                      connectivityState is ConnectivityConnected
                          ? () => _navigateToUserForm(context)
                          : () => _showOfflineMessage(context),
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addUser),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToUserDetail(BuildContext context, ApiUserEntity user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)));
  }

  void _navigateToUserForm(BuildContext context, {ApiUserEntity? user}) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UserFormScreen(user: user)));
  }

  void _showDeleteDialog(BuildContext context, ApiUserEntity user) {
    final localizations = AppLocalizations.getSafeLocalizations(context);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(localizations.deleteUser),
            content: Text(localizations.deleteUserConfirmation(user.fullName)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<UsersBloc>().add(DeleteUserEvent(user.id));
                },
                child: Text(
                  localizations.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showOfflineMessage(BuildContext context) {
    final localizations = AppLocalizations.getSafeLocalizations(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.offlineActionNotAvailable),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class _ResponsiveStatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _ResponsiveStatsCard({
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
