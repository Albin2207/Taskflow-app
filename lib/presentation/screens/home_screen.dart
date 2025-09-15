import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/api_user_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/userlist/userlist_bloc.dart';
import '../bloc/userlist/userlist_event.dart';
import '../bloc/userlist/userlist_state.dart';
import 'apidebug_screen.dart';
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
    return MultiBlocListener(
      listeners: [
        // Listen to notification navigation
        BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationTapped) {
              _handleNotificationNavigation(state.route, state.data);
            }
          },
        ),
        // Listen to connectivity changes
        BlocListener<ConnectivityBloc, ConnectivityState>(
          listener: (context, connectivityState) {
            if (connectivityState is ConnectivityConnected) {
              // Show network restored notification
              context.read<NotificationBloc>().add(
                NotificationSendNetworkRestored(),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body:
            _selectedIndex == 0
                ? const DashboardScreen()
                : const ProfileScreen(),
        bottomNavigationBar: Container(
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
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationNavigation(String route, Map<String, dynamic> data) {
    switch (route) {
      case '/users':
        // Navigate to users tab and refresh data
        setState(() {
          _selectedIndex = 0;
        });
        context.read<UsersBloc>().add(const LoadUsersEvent(isRefresh: true));
        break;
      case '/profile':
        setState(() {
          _selectedIndex = 1;
        });
        break;
      case '/home':
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
    // Load users when screen initializes
    context.read<UsersBloc>().add(const LoadUsersEvent());

    // Show welcome notification on first load
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
    // Only show welcome notification if this is the first time loading
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    state.user.name.isEmpty
                        ? 'User'
                        : state.user.name.split(' ').first,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
            return const Text('TaskFlow');
          },
        ),
        actions: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, connectivityState) {
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
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
          // Test notification button
          IconButton(
            icon: const Icon(Icons.notifications_active),
            color: const Color(0xFF1E88E5),
            onPressed: () {
              context.read<NotificationBloc>().add(NotificationSendTest());
            },
            tooltip: 'Test Notification',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated && state.user.photoUrl != null) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(state.user.photoUrl!),
                  );
                }
                return const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1E88E5),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApiDebugScreen()),
              );
            },
          ),
        ],
      ),
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
                      padding: const EdgeInsets.all(16),
                      child: _buildStatsSection(state),
                    ),
                  ),

                  // Users List Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Users',
                            style: TextStyle(
                              fontSize: 20,
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
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Refresh'),
                              );
                            },
                          ),
                        ],
                      ),
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                              16,
                              index == 0 ? 8 : 4,
                              16,
                              index == state.users.length - 1 ? 16 : 4,
                            ),
                            child: _buildUserCard(user),
                          );
                        },
                        childCount:
                            state.users.length + (state.isLoadingMore ? 1 : 0),
                      ),
                    )
                  else if (state is UsersError)
                    SliverToBoxAdapter(child: _buildErrorState(state.message))
                  else
                    SliverToBoxAdapter(child: _buildEmptyState()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsSection(UsersState state) {
    int totalUsers = 0;
    int currentPage = 1;

    if (state is UsersLoaded) {
      totalUsers = state.users.length;
      currentPage = state.currentPage;
    }

    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            title: 'Total Users',
            count: totalUsers.toString(),
            icon: Icons.people,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatsCard(
            title: 'Current Page',
            count: currentPage.toString(),
            icon: Icons.pages,
            color: const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(ApiUserEntity user) {
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
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(user.avatar),
          backgroundColor: Colors.grey[300],
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ID: ${user.id}',
                style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontSize: 12,
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
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('View'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading users',
              style: TextStyle(
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add your first user',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  label: const Text('Add User'),
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
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete User'),
            content: Text('Are you sure you want to delete ${user.fullName}?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<UsersBloc>().add(DeleteUserEvent(user.id));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showOfflineMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This action is not available offline'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
